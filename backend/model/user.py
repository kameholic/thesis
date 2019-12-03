from model.database import db


class User(db.Model):
    """User

    Attributes:
        email (str): email of the user
        password (str): password of the user
        gender (str): male or female
        age (int): age of the person
        weight (float): weight in kilograms
        lifestyle (str): sitting, normal or active
        allergies (str): csv string of allergies
    """
    __tablename__ = 'user'

    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(128))
    password = db.Column(db.String(128))
    confirmed = db.Column(db.Boolean)
    gender = db.Column(db.String(128))
    age = db.Column(db.Integer)
    weight = db.Column(db.Float)
    height = db.Column(db.Float)
    lifestyle = db.Column(db.String())
    allergies = db.Column(db.String())

    def __init__(self, email, password):
        self.email = email
        self.password = password
        self.confirmed = False
        self.gender = None
        self.age = None
        self.weight = None
        self.height = None
        self.lifestyle = None
        self.allergies = ''
