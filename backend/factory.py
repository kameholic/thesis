import os
from flask import Flask
from flask_restful import Resource, Api, reqparse
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager, jwt_required, get_jwt_identity
from controllers import auth, user_info
from controllers.response import Response
from model.database import db
from generator import generator


def create_response(resp):
    if len(resp.errors) == 0:
        return {'message': resp.message}, 200
    else:
        return {'message': resp.errors}, 400


auth_parser = reqparse.RequestParser()
auth_parser.add_argument('email', type=str, required=True)
auth_parser.add_argument('password', type=str, required=True)


def create_app(config=None):
    app = Flask(__name__)

    if config is None:
        config = os.environ.get('FLASK_CONFIG')
        if config is None:
            config = 'DevConfig'
    config_path = 'config.' + config
    try:
        app.config.from_object(config_path)
    except ImportError:
        print('Unknown config, running with DevConfig')
        config_path = 'config.DevConfig'
    finally:
        app.config.from_object(config_path)

    db.init_app(app)
    jwt = JWTManager(app)
    api = Api(app)
    migrate = Migrate(app, db)

    class RegisterUser(Resource):
        def post(self):
            args = auth_parser.parse_args()
            resp = auth.register_user(db, args)
            return create_response(resp)

    class LoginUser(Resource):
        def post(self):
            args = auth_parser.parse_args()
            resp = auth.login_user(db, args)
            return create_response(resp)

    class UserInfos(Resource):
        def __init__(self):
            self.parser = reqparse.RequestParser()
            self.parser.add_argument('gender',
                                     choices=('male', 'female'),
                                     required=True)
            self.parser.add_argument('age', type=int, required=True)
            self.parser.add_argument('weight', type=float, required=True)
            self.parser.add_argument('lifestyle',
                                     choices=('sitting', 'normal', 'active'),
                                     required=True)
            self.parser.add_argument('allergies',
                                     type=list,
                                     location='json',
                                     required=True)

        @jwt_required
        def get(self):
            user_id = get_jwt_identity()
            resp = user_info.get_user_infos(db, user_id)
            return create_response(resp)

        @jwt_required
        def post(self):
            user_id = get_jwt_identity()
            args = self.parser.parse_args()
            print(args)
            resp = user_info.save_user_infos(db, user_id, args)
            return create_response(resp)

    class Generate(Resource):
        def __init__(self):
            self.parser = reqparse.RequestParser()
            self.parser.add_argument('diet_type',
                                     choices=('standard', 'paleo', 'keto'),
                                     required=True)
            self.parser.add_argument('goal',
                                     choices=('lose', 'maintain', 'gain'),
                                     required=True)

        @jwt_required
        def post(self):
            user_id = get_jwt_identity()
            args = self.parser.parse_args()
            all_allergies = generator.get_allergies()
            resp = generator.generate_diet(db,
                                           user_id,
                                           args['diet_type'],
                                           args['goal'])
            return create_response(resp)

    class Allergies(Resource):
        def get(self):
            resp = Response()
            allergies = generator.get_allergies()
            resp.message = {'allergies': allergies}
            return create_response(resp)


    api.add_resource(RegisterUser, '/register')
    api.add_resource(LoginUser, '/login')
    api.add_resource(UserInfos, '/user_infos')
    api.add_resource(Generate, '/generate_diet')
    api.add_resource(Allergies, '/allergies')

    return app
