import pytest
from tests.utils import *


@pytest.fixture
def test_client(client):
    post_json(client, '/register',
              {'email': 'test', 'password': 'test'})
    response = post_json(client, '/login',
                         {'email': 'test', 'password': 'test'})
    message = response_message(response)
    access = message['access_token']
    client.environ_base['HTTP_AUTHORIZATION'] = 'Bearer ' + access
    return client


def test_save_and_get_user_info(test_client):
    client_ = test_client
    payload = {
        'gender': 'male',
        'age': 20,
        'weight': 65,
        'height': 175,
        'lifestyle': 'sitting',
        'allergies': [1000, 1001]
    }
    response = post_json(client_,
                         '/user_infos',
                         payload)
    assert(response.status_code == 200)
    response = client_.get('/user_infos')
    message = response_message(response)
    assert(message == payload)


def test_default_user_info(test_client):
    client_ = test_client
    response = client_.get('/user_infos')
    assert(response.status_code == 200)
    message = response_message(response)
    assert(message == {
        'gender': None,
        'age': None,
        'weight': None,
        'height': None,
        'lifestyle': None,
        'allergies': []
    })


def test_without_auth_headers_fails(test_client):
    client_ = test_client
    del client_.environ_base['HTTP_AUTHORIZATION']
    payload = {
        'gender': 'male',
        'age': 20,
        'weight': 65,
        'height': 65,
        'lifestyle': 'sitting',
        'allergies': [1000, 1001]
    }
    response = post_json(client_,
                         '/user_infos',
                         payload)
    assert(response.status_code == 401)
    message = response_message(response)
    assert(message == 'Missing Authorization Header')

    response = client_.get('/user_infos')
    assert(response.status_code == 401)
    message = response_message(response)
    assert(message == 'Missing Authorization Header')


def test_save_bad_params(test_client):
    client_ = test_client
    payload = {
        'gender': 'bad',
        'age': -10,
        'weight': -30,
        'height': -30,
        'lifestyle': 'bad',
        'allergies': 100
    }
    response = post_json(client_,
                         '/user_infos',
                         payload)
    message = response_message(response)
    assert(response.status_code == 400)
    assert('gender' in message)
    assert('lifestyle' in message)
    payload = {
        'gender': 'male',
        'age': -10,
        'weight': -30,
        'height': -30,
        'lifestyle': 'sitting',
        'allergies': 100
    }
    response = post_json(client_,
                         '/user_infos',
                         payload)
    message = response_message(response)
    assert(response.status_code == 400)
    assert('age' in message)
    assert('weight' in message)
    assert('height' in message)
    assert('allergies' in message)
