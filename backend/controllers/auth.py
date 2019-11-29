from flask_jwt_extended import create_access_token
from werkzeug.security import generate_password_hash, check_password_hash
from controllers.response import Response
from model.user import User


def hash_password(password):
    return generate_password_hash(password)


def check_password(pw_hash, password):
    return check_password_hash(pw_hash, password)


def register_user(db, args):
    resp = Response()
    email = args.get('email', None)
    password = args.get('password', None)
    user = User.query.filter_by(email=email).first()
    if user is not None:
        resp.add_error('email', 'email is already taken')
        return resp
    user = User(email, hash_password(password))
    db.session.add(user)
    db.session.commit()
    resp.message = 'Successfully registered'
    return resp


def login_user(db, args):
    resp = Response()
    email = args.get('email', None)
    password = args.get('password', None)
    user = User.query.filter_by(email=email).first()
    if user is None:
        resp.add_error('password', 'email or password does not match')
        return resp
    if check_password(user.password, password):
        access_token = create_access_token(identity=user.id)
        resp.message = {'access_token': access_token}
    else:
        resp.add_error('password', 'email or password does not match')
    return resp
