from flask_script import Manager
from flask_migrate import MigrateCommand
from factory import create_app
from model.database import db

manager = Manager(create_app)
manager.add_command('db', MigrateCommand)
manager.add_option('-c', '--config', dest='config', required=False,
    help='CONFIG: ProdConfig, DevConfig, or TestConfig')

if __name__ == '__main__':
    manager.run()
