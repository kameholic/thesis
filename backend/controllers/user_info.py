from controllers.response import Response
from model.user import User


def list_to_str(values: list):
    return ','.join(str(val) for val in values)


def str_to_list(values: str):
    if values == '':
        return []
    return [int(val) for val in values.split(',')]


def get_user_infos(db, user_id):
    resp = Response()
    user = User.query.filter_by(id=user_id).first()
    if user is None:
        resp.add_error('user_id', 'not found')
        return resp
    resp.message = {
        'gender': user.gender,
        'age': user.age,
        'weight': user.weight,
        'height': user.height,
        'lifestyle': user.lifestyle,
        'allergies': str_to_list(user.allergies)
    }
    return resp


def save_user_infos(db, user_id, infos):
    resp = Response()
    user = User.query.filter_by(id=user_id).first()
    if user is None:
        resp.add_error('user_id', 'not found')
    if infos['age'] < 0:
        resp.add_error('age', 'cannot be negative')
    if infos['weight'] < 0:
        resp.add_error('weight', 'cannot be negative')
    if infos['height'] < 0:
        resp.add_error('height', 'cannot be negative')
    if not isinstance(infos['allergies'], list):
        resp.add_error('allergies', 'has to be a list of int')
    else:
        for val in infos['allergies']:
            if not isinstance(val, int):
                resp.add_error('allergies', 'has to be a list of int')
                break
    if not resp:
        return resp
    user.gender = infos['gender']
    user.age = infos['age']
    user.weight = infos['weight']
    user.height = infos['height']
    user.lifestyle = infos['lifestyle']
    user.allergies = list_to_str(infos['allergies'])
    db.session.add(user)
    db.session.commit()
    resp.message = 'User infos saved'
    return resp
