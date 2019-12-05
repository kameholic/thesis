from tests.utils import *


def test_first_register_succeeds(client):
    response = post_json(client, '/register',
                         {'email': 'test', 'password': 'test'})
    assert(response.status_code == 200)
    assert(response_json(response) == {
        'message': 'Successfully registered, please confirm in your e-mail'
    })


def test_second_register_fails(client):
    response = post_json(client, '/register',
                         {'email': 'test', 'password': 'test'})
    assert(response.status_code == 200)
    response = post_json(client, '/register',
                         {'email': 'test', 'password': 'test123'})
    assert(response_message(response) == {
        'email': 'email is already taken'
    })


def test_login_before_register_fails(client):
    response = post_json(client, '/login',
                         {'email': 'test', 'password': 'test'})
    assert(response.status_code == 400)
    assert(response_message(response) == {
        'password': 'email or password does not match'
    })


def test_login_after_register_succeeds(client):
    response = post_json(client, '/register',
                         {'email': 'test', 'password': 'test'})
    response = post_json(client, '/login',
                         {'email': 'test', 'password': 'test'})
    assert(response.status_code == 200)
    response = response_json(response)
    assert('access_token' in response['message'])


def test_login_or_register_missing_values(client):
    endpoints = ['/register', '/login']
    for endpoint in endpoints:
        response = post_json(client, endpoint, {})
        assert(response.status_code == 400)
        assert('email' in response_message(response))
        response = post_json(client, endpoint,
                             {'email': 'test'})
        assert('password' in response_message(response))
        response = post_json(client, endpoint,
                             {'password': 'test'})
        assert('email' in response_message(response))
