from controllers.response import Response


def test_init_resp():
    resp = Response()
    assert(resp.message == '')
    assert(resp.errors == {})


def test_add_error():
    resp = Response()
    resp.add_error('test', 'error')
    assert(resp.errors == {'test': 'error'})
    resp.add_error('another', 'error')
    assert(resp.errors == {
        'test': 'error',
        'another': 'error'
    })
    assert(resp.message == '')


def test_message_without_error():
    resp = Response()
    resp.message = 'some message'
    assert(resp.errors == {})
    assert(resp.message == 'some message')
