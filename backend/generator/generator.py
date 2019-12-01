from controllers.response import Response
from model.user import User
from model.diet import Recipe, DietDay, Diet
import csv
from random import randrange


def list_to_str(values):
    return ','.join(str(val) for val in values)


def str_to_list(values):
    if values == '':
        return []
    return [int(val) for val in values.split(',')]


def get_allergies():
    allergies = {}
    with open('generator/myfooddata.csv') as csvfile:
        reader = csv.reader(csvfile, delimiter=',', quotechar='\"')
        for row in reader:
            allergies[int(row[0])] = row[2]
    return allergies


def get_recipes():
    recipes = []
    with open('generator/recipes.csv') as csvfile:
        reader = csv.reader(csvfile, delimiter=',', quotechar='\"')
        for row in reader:
            recipe = Recipe()
            recipe.id = int(row[0])
            recipe.name = row[1]
            recipe.protein = float(row[2])
            recipe.fat = float(row[3])
            recipe.carb = float(row[4])
            recipe.calories = float(row[5])
            recipe.type = row[6]
            recipe.description = row[7]
            recipe.allergies = str_to_list(row[8])
            recipes.append(recipe)
    return recipes


def load_diet(db, user_id):
    resp = Response()
    diet = Diet.query.filter_by(id=user_id).first()
    if diet is None:
        resp.message = {'diet': None}
        return resp

    is_complex = diet.days[0].is_complex
    days = []

    if is_complex:
        recipes = get_recipes()

        for day in diet.days:
            day_ = {
                'breakfast': [],
                'lunch': [],
                'dinner': []
            }
            for dine_type in ['breakfast', 'lunch', 'dinner']:
                recipe_list = str_to_list(getattr(day, dine_type))
                portion = getattr(day, '{}_portion'.format(dine_type))
                assert(len(recipe_list) == 1)

                for recipe_id in recipe_list:
                    recipe = next((x for x in recipes if x.id == recipe_id),
                                  None)
                    day_[dine_type] = {
                        'id': recipe_id,
                        'name': recipe.name,
                        'portion': portion,
                        'description': recipe.description
                    }
            days.append(day_)
    else:
        raise NotImplementedError()

    resp.message = {
        'diet': days
    }
    return resp


def save_diet(db, user_id, diet, is_complex):
    print('Saving diet')
    db_diet = Diet.query.filter_by(id=user_id).first()
    if db_diet is None:
        db_diet = Diet()
    else:
        DietDay.query.filter_by(diet_id=db_diet.id).delete()
    db_diet.user_id = user_id
    db_diet.days = []
    for day in diet:
        if is_complex:
            breakfast = day['breakfast']['id']
            lunch = day['lunch']['id']
            dinner = day['dinner']['id']
            db_day = DietDay(True, breakfast, lunch, dinner)
            db_day.breakfast_portion = day['breakfast']['portion']
            db_day.lunch_portion = day['lunch']['portion']
            db_day.dinner_portion = day['dinner']['portion']
            db_diet.days.append(db_day)
            db.session.add(db_day)
        else:
            raise NotImplementedError()
    db.session.add(db_diet)
    db.session.commit()


def generate_diet(db, user_id, diet_type, goal):
    resp = Response()

    user = User.query.filter_by(id=user_id).first()
    if user is None:
        resp.add_error('user_id', 'not found')
        return resp

    recipes = get_recipes()
    allergies = str_to_list(user.allergies)
    calories = 0
    W = user.weight
    H = user.height
    A = user.age

    mult = 0
    if user.lifestyle == 'sitting':
        mult = 1.2
    elif user.lifestyle == 'normal':
        mult = 1.3
    else:
        mult = 1.7

    if user.gender == 'male':
        calories = 66.5 + (13.8 * W) + (5.0 * H) - (6.8 * A)
    else:
        calories = 655 + (9.6 * W) + (1.9 * H) - (4.7 * A)
    calories = mult * calories
    if goal == 'lose':
        calories -= 300
    elif goal == 'gain':
        calories += 300

    r_carb = 0.4
    r_fat = 0.3
    r_protein = 0.3

    carb = (r_carb * calories) / 4
    fat = (r_fat * calories) / 9
    protein = (r_protein * calories) / 4

    def contains_allergy(recipe, user_allergies):
        for x in recipe.allergies:
            if x in user_allergies:
                return True
        return False

    possible_recipes = {}
    unused = {}

    # Filter recipes for each dine type
    for dine_type in ['breakfast', 'lunch', 'dinner']:
        filtered = [recipe
                    for recipe
                    in recipes
                    if recipe.type == dine_type and not
                    contains_allergy(recipe, allergies)]
        if len(filtered) == 0:
            resp.add_error(dine_type, 'every recipe was filtered out')
            return resp
        possible_recipes[dine_type] = filtered
        unused[dine_type] = [v for v in filtered]

    r_calories = {
        'breakfast': 0.25 * calories,
        'lunch': 0.375 * calories,
        'dinner': 0.375 * calories
    }

    result = []
    for day in range(0, 7):
        result.append({})
        for dine_type in ['breakfast', 'lunch', 'dinner']:
            if len(unused[dine_type]) == 0:
                unused[dine_type] = possible_recipes[dine_type]
            u = unused[dine_type]
            x = randrange(len(u))
            portion = r_calories[dine_type] / u[x].calories
            portion = float('{:0.1f}'.format(portion))
            result[day][dine_type] = {
                'id': u[x].id,
                'name': u[x].name,
                'portion': portion,
                'description': u[x].description
            }
            del u[x]

    resp.message = {'diet': result}

    save_diet(db, user_id, result, True)

    return resp
