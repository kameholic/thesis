from model.user import User


class Database(object):
    def __init__(self):
        self.users = {}

    def clear(self):
        self.users = {}

    def get_user_by_id(self, user_id):
        return self.users.get(user_id, None)

    def get_user_by_email(self, email):
        for user in self.users.values():
            if user.email == email:
                return user
        return None

    def create_user(self, email, hash_pw):
        user_id = str(len(self.users))
        self.users[user_id] = User(user_id, email, hash_pw)
