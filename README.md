# Backend futtatása lokálisan

cd backend
(opcionálisan: virtualenv létrehozása, aktiválása)
pip3 install -r requirements_dev.txt
(első alkalommal kell migrálni)
python manage.py db init
python manage.py db migrate
python manage.py db upgrade

Futtatjuk a szervert:

python manage.py runserver

Ahhoz, hogy a frontend a lokális szerverhez csatlakozzon a Heroku-ra telepített helyett, át kell írni a frontend/thesis/Utility/REST.swift backendURL függvényt, hogy a http://127.0.0.1:5000/ URL-t adja vissza.
