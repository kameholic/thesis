from controllers.response import Response
from model.user import User
from model.diet import Recipe
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
    H = 175
    A = user.age

    if user.gender == 'male':
        calories = 10 * W + 6.25 * H - 5 * A + 5
    else:
        calories = 10 * W + 6.25 * H - 5 * A - 161

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

    result = []
    for day in range(0, 7):
        result.append({})
        for dine_type in ['breakfast', 'lunch', 'dinner']:
            if len(unused[dine_type]) == 0:
                unused[dine_type] = possible_recipes[dine_type]
            u = unused[dine_type]
            x = randrange(len(u))
            result[day][dine_type] = {
                'name': u[x].name,
                'description': u[x].description
            }
            del u[x]

    resp.message = {'diet': result}
    return resp
