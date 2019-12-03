from flask_jwt_extended import create_access_token
from flask import url_for, current_app
from werkzeug.security import generate_password_hash, check_password_hash
from itsdangerous import URLSafeTimedSerializer
import smtplib
from controllers.response import Response
from model.user import User


def hash_password(password):
    return generate_password_hash(password)


def check_password(pw_hash, password):
    return check_password_hash(pw_hash, password)


def generate_url(endpoint, token):
    return url_for(endpoint, token=token, _external=True)


def encode_token(email):
    serializer = URLSafeTimedSerializer(current_app.config['SECRET_KEY'])
    return serializer.dumps(email, salt='email-confirm-salt')


def decode_token(token, expiration=3600):
    serializer = URLSafeTimedSerializer(current_app.config['SECRET_KEY'])
    try:
        email = serializer.loads(
            token,
            salt='email-confirm-salt',
            max_age=expiration
        )
        return email
    except Exception:
        return False


def send_email(email):
    token = encode_token(email)
    confirm_url = generate_url('confirm', token)
    print(confirm_url)

    from email.mime.multipart import MIMEMultipart
    from email.mime.text import MIMEText

    host = current_app.config['EMAIL_HOST']
    port = current_app.config['EMAIL_PORT']
    host_user = current_app.config['EMAIL_HOST_USER']
    host_password = current_app.config['EMAIL_HOST_PASSWORD']

    msg = MIMEMultipart()
    msg['From'] = host_user
    msg['To'] = email
    msg['Subject'] = "Diet generator: confirm your e-mail"
    msg.attach(MIMEText('Follow the link {}'.format(confirm_url)))

    mailServer = smtplib.SMTP(host, port)
    mailServer.ehlo()
    mailServer.starttls()
    mailServer.ehlo()
    mailServer.login(host_user, host_password)
    mailServer.sendmail(host_user, email, msg.as_string())
    mailServer.close()


def register_user(db, args):
    resp = Response()
    email = args.get('email', None)
    password = args.get('password', None)
    user = User.query.filter_by(email=email).first()
    if user is not None:
        resp.add_error('email', 'email is already taken')
        return resp
    user = User(email, hash_password(password))
    try:
        send_email(email)
    except smtplib.SMTPRecipientsRefused:
        resp.add_error('email', '%s is not a valid address' % email)
        return resp
    db.session.add(user)
    db.session.commit()
    resp.message = 'Successfully registered, please confirm in your e-mail'
    return resp


def login_user(db, args):
    resp = Response()
    email = args.get('email', None)
    password = args.get('password', None)
    user = User.query.filter_by(email=email).first()
    if user is None or not user.confirmed:
        resp.add_error('password', 'email or password does not match')
        return resp
    if check_password(user.password, password):
        access_token = create_access_token(identity=user.id)
        resp.message = {'access_token': access_token}
    else:
        resp.add_error('password', 'email or password does not match')
    return resp
