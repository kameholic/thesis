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

    payload = {
        'gender': 'male',
        'age': 20,
        'weight': 65,
        'height': 175,
        'lifestyle': 'sitting',
        'allergies': [1000, 1001]
    }
    response = post_json(client,
                         '/user_infos',
                         payload)

    return client


def test_diet_format(test_client):
    client_ = test_client
    response = post_json(client_, '/generate_diet',
                         {'goal': 'maintain', 'diet_type': 'standard'})
    assert(response.status_code == 200)
    message = response_message(response)
    diet = message
    assert 'diet' in message
    assert(len(message['diet']) == 7)
    for day in message['diet']:
        assert('breakfast' in day)
        assert('lunch' in day)
        assert('dinner' in day)

    response = client_.get('/generate_diet')
    message = response_message(response)
    assert(message == diet)
