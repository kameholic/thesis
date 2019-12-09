from model.database import db


class Recipe(object):
    def __init__(self):
        self.id = ''
        self.name = ''
        self.protein = 0
        self.fat = 0
        self.carb = 0
        self.calories = 0
        self.type = ''
        self.description = ''
        self.allergies = []


class Ingredient(object):
    def __init__(self):
        self.id = ''
        self.group = ''
        self.name = ''
        self.protein = 0
        self.fat = 0
        self.carb = 0
        self.calories = 0
        self.allergies = []


class DietDay(db.Model):
    __tablename__ = 'diet_day'

    id = db.Column(db.Integer, primary_key=True)
    diet_id = db.Column(db.Integer, db.ForeignKey('diet.id'))
    is_complex = db.Column(db.Boolean)
    breakfast = db.Column(db.String(128))
    lunch = db.Column(db.String(128))
    dinner = db.Column(db.String(128))
    breakfast_portion = db.Column(db.String(128))
    lunch_portion = db.Column(db.String(128))
    dinner_portion = db.Column(db.String(128))

    def __init__(self, is_complex, breakfast, lunch, dinner):
        self.is_complex = is_complex
        self.breakfast = breakfast
        self.lunch = lunch
        self.dinner = dinner


# Each day is a dict of recipes
class Diet(db.Model):
    __tablename__ = 'diet'

    id = db.Column(db.Integer, primary_key=True)
    days = db.relationship("DietDay")
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
