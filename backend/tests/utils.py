import json


def post_json(client, url, json_dict):
    return client.post(
        url,
        data=json.dumps(json_dict),
        content_type='application/json')


def response_json(response):
    return json.loads(response.data.decode('utf8'))


def response_message(response):
    return json.loads(response.data.decode('utf8'))['message']
