from controllers.response import Response
from model.user import User
from model.diet import Recipe, Ingredient, DietDay, Diet
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
    with open('generator/allergens.csv') as csvfile:
        reader = csv.reader(csvfile, delimiter=',', quotechar='\"')
        for row in reader:
            allergies[int(row[0])] = row[1]
    return allergies


def get_ingredients():
    ingredients = {}
    with open('generator/myfooddata.csv') as csvfile:
        reader = csv.reader(csvfile, delimiter=',', quotechar='\"')
        for row in reader:
            ingredient = Ingredient()
            ingredient.id = int(row[0])
            ingredient.group = row[1]
            ingredient.name = row[2]
            ingredient.protein = float(row[3])
            ingredient.fat = float(row[4])
            ingredient.carb = float(row[5])
            ingredient.calories = float(row[6])
            ingredient.allergies = str_to_list(row[7])
            ingredients[ingredient.id] = ingredient
    return ingredients


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
            recipe.allergies = str_to_list(row[7])
            recipe.description = row[8]
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
                    day_[dine_type] = [{
                        'id': recipe_id,
                        'name': recipe.name,
                        'portion': float(portion),
                        'description': recipe.description
                    }]
            days.append(day_)
    else:
        ingredients = get_ingredients()

        for day in diet.days:
            day_ = {
                'breakfast': [],
                'lunch': [],
                'dinner': []
            }
            for dine_type in ['breakfast', 'lunch', 'dinner']:
                ing_list = str_to_list(getattr(day, dine_type))
                portion_list = str_to_list(
                    getattr(day, '{}_portion'.format(dine_type)))
                assert(len(ing_list) == len(portion_list))

                for i in range(0, len(ing_list)):
                    ing_id = ing_list[i]
                    portion = portion_list[i]
                    ing = next((x for x in ingredients.values()
                                if x.id == ing_id),
                               None)
                    day_[dine_type].append({
                        'id': ing_id,
                        'name': '{} grams or ml {}'.format(portion, ing.name),
                        '_portion': portion,
                        'portion': 1,
                        'description': ''
                    })
            days.append(day_)

    resp.message = {
        'diet': days
    }
    return resp


def save_diet(db, user_id, diet, is_complex):
    db_diet = Diet.query.filter_by(id=user_id).first()
    if db_diet is None:
        db_diet = Diet()
    else:
        DietDay.query.filter_by(diet_id=db_diet.id).delete()
    db_diet.user_id = user_id
    db_diet.days = []
    for day in diet:
        portion_name = 'portion' if is_complex else '_portion'
        breakfast = list_to_str([x['id'] for x in day['breakfast']])
        lunch = list_to_str([x['id'] for x in day['lunch']])
        dinner = list_to_str([x['id'] for x in day['dinner']])
        db_day = DietDay(is_complex, breakfast, lunch, dinner)
        if is_complex:
            db_day.breakfast_portion = str(day['breakfast'][0][portion_name])
            db_day.lunch_portion = str(day['lunch'][0][portion_name])
            db_day.dinner_portion = str(day['dinner'][0][portion_name])
        else:
            db_day.breakfast_portion = list_to_str(x[portion_name]
                                                   for x
                                                   in day['breakfast'])
            db_day.lunch_portion = list_to_str(x[portion_name]
                                               for x
                                               in day['lunch'])
            db_day.dinner_portion = list_to_str(x[portion_name]
                                                for x
                                                in day['dinner'])
        db_diet.days.append(db_day)
        db.session.add(db_day)
    db.session.add(db_diet)
    db.session.commit()


def contains_allergy(recipe, user_allergies):
    for x in recipe.allergies:
        if x in user_allergies:
            return True
    return False


def generate_complex_diet(resp, calories, allergies):
    recipes = get_recipes()

    # r_carb = 0.4
    # r_fat = 0.3
    # r_protein = 0.3

    # carb = (r_carb * calories) / 4
    # fat = (r_fat * calories) / 9
    # protein = (r_protein * calories) / 4

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

    result = []
    for day in range(0, 7):
        result.append({})
        for dine_type in ['breakfast', 'lunch', 'dinner']:
            if len(unused[dine_type]) == 0:
                unused[dine_type] = [v for v in possible_recipes[dine_type]]
            u = unused[dine_type]
            x = randrange(len(u))
            portion = calories[dine_type] / u[x].calories
            portion = float('{:0.1f}'.format(portion))
            result[day][dine_type] = [{
                'id': u[x].id,
                'name': u[x].name,
                'portion': portion,
                'description': u[x].description
            }]
            del u[x]

    return result


def generate_simple_diet(resp, calories, allergies):
    ingredients = get_ingredients()

    class Option():
        def __init__(self, group, num):
            self.group = group
            self.num = num

    req_groups = {
        'breakfast': [
            (0.25, [Option('Dairy', 2)]),
            (0.25, [Option('Vegetables', 3)]),
            (0.5, [Option('Fruits', 2)])
        ],
        'lunch': [
            (0.5, [
                Option('Poultry', 1),
                Option('Fish', 1),
                Option('Egg Products', 1)
            ]),
            (0.3, [Option('Cereal Grains and Pasta', 1)]),
            (0.2, [Option('Vegetables', 3)])
        ],
        'dinner': [
            (0.4, [Option('Dairy', 1)]),
            (0.6, [Option('Vegetables', 4)])
        ]
    }

    def filtered_group(ingredients, allergies, group):
        return [ingredient
                for ingredient
                in ingredients
                if ingredient.group == group and
                not contains_allergy(ingredient, allergies)]

    # Filter ingredients for each dine type
    filtered_groups = {}
    for dine_type in ['breakfast', 'lunch', 'dinner']:
        for req_group in req_groups[dine_type]:
            for option in req_group[1]:
                if option.group not in filtered_groups:
                    g = filtered_group(ingredients.values(),
                                       allergies,
                                       option.group)
                    filtered_groups[option.group] = g

    result = []
    for day in range(0, 7):
        result.append({})
        for dine_type in ['breakfast', 'lunch', 'dinner']:
            result[day][dine_type] = []
            for req_group in req_groups[dine_type]:
                possible_opts = []
                for idx, opt in enumerate(req_group[1]):
                    if len(filtered_groups[opt.group]) > 0:
                        possible_opts.append(idx)

                x = randrange(len(possible_opts))
                opt = possible_opts[x]
                group = req_group[1][opt].group
                num = req_group[1][opt].num
                cal = calories[dine_type] * req_group[0]
                unused = []
                for i in range(0, num):
                    if len(unused) == 0:
                        unused = [ing for ing in filtered_groups[group]]
                    y = randrange(len(unused))
                    ing = unused[y]
                    portion = int((100 * (cal / num)) / ing.calories)
                    result[day][dine_type].append({
                        'id': ing.id,
                        'name': '{} grams or ml {}'.format(portion, ing.name),
                        '_portion': portion,
                        'portion': 1,
                        'description': ''
                    })
                    del unused[y]

    return result


def generate_diet(db, user_id, diet_type, goal, is_complex):
    resp = Response()

    user = User.query.filter_by(id=user_id).first()
    if user is None:
        resp.add_error('user_id', 'not found')
        return resp

    if user.gender is None:
        resp.add_error('gender', 'is not set')
    if user.age is None:
        resp.add_error('age', 'is not set')
    if user.weight is None:
        resp.add_error('weight', 'is not set')
    if user.height is None:
        resp.add_error('height', 'is not set')
    if user.lifestyle is None:
        resp.add_error('lifestyle', 'is not set')
    if len(resp.errors) > 0:
        return resp

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
        calories = 66 + (13.7 * W) + (5.0 * H) - (6.8 * A)
    else:
        calories = 655 + (9.6 * W) + (1.8 * H) - (4.7 * A)
    calories = mult * calories
    if goal == 'lose':
        calories -= 300
    elif goal == 'gain':
        calories += 300

    r_calories = {
        'breakfast': 0.35 * calories,
        'lunch': 0.4 * calories,
        'dinner': 0.25 * calories
    }

    result = None
    if is_complex:
        result = generate_complex_diet(resp, r_calories, allergies)
    else:
        result = generate_simple_diet(resp, r_calories, allergies)

    if len(resp.errors) == 0:
        save_diet(db, user_id, result, is_complex)
        resp.message = {'diet': result}
    return resp
