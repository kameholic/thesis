class Recipe(object):
    def __init__(self):
        self.name = ''
        self.protein = 0
        self.fat = 0
        self.carb = 0
        self.calories = 0
        self.type = ''
        self.description = ''
        self.allergies = []
        

# Each day is a list of recipes
class Diet(object):
    def __init__(self):
        self.days = []
