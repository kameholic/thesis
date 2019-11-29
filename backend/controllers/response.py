class Response(object):

    """Response

    Attributes:
        errors (dict): dict of errors
        message (str): status message
    """

    def __init__(self):
        self.message = ''
        self.errors = {}

    def add_error(self, key, val):
        if key not in self.errors:
            self.errors[key] = val

    def __bool__(self):
        return len(self.errors) == 0

    def as_dict(self):
        return {
            'message': self.message,
            'errors': self.errors
        }
