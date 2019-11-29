from controllers.response import Response
from model.user import User
import csv


def get_allergies():
    allergies = {}
    with open('generator/myfooddata.csv') as csvfile:
        reader = csv.reader(csvfile, delimiter=',', quotechar='\"')
        for row in reader:
            allergies[row[0]] = row[2]
    return allergies


def generate_diet(db, user_id, diet_type, goal, allergies: list):
    resp = Response()
    user = User.query.filter_by(id=user_id).first()
    if user is None:
        resp.add_error('user_id', 'not found')
        return resp
    return resp
