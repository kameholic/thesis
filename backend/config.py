import os
from datetime import timedelta


APP_DIR = os.path.abspath(os.path.dirname(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(APP_DIR, os.pardir))


class Config(object):
    """Base configuration."""
    BUNDLE_ERRORS = True
    JWT_SECRET_KEY = 'super-secret'
    SECRET_KEY = 'super-secret'
    JWT_ERROR_MESSAGE_KEY = 'message'
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(days=7)
    PROPAGATE_EXCEPTIONS = True
    # E-mail confirmation settings
    EMAIL_HOST = 'smtp.gmail.com'
    EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER')
    EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD')
    EMAIL_USE_TLS = True
    EMAIL_PORT = 587


class ProdConfig(Config):
    """Production configuration."""
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'postgresql://localhost/prosys'


class DevConfig(Config):
    """Development configuration."""
    SQLALCHEMY_TRACK_MODIFICATIONS = True
    DEVDB = 'dev.db'
    DEVDB_PATH = "./{}".format(DEVDB)
    DEV_DATABASE_URI = 'sqlite:///' + DEVDB_PATH
    SQLALCHEMY_DATABASE_URI = DEV_DATABASE_URI
    DEBUG = True


class TestConfig(Config):
    """Test configuration."""
    SQLALCHEMY_TRACK_MODIFICATIONS = True
    TESTDB = 'test.db'
    TESTDB_PATH = "./{}".format(TESTDB)
    TEST_DATABASE_URI = 'sqlite:///' + TESTDB_PATH
    SQLALCHEMY_DATABASE_URI = TEST_DATABASE_URI
    TESTING = True
    CONFIRM_REQUIRED = False
