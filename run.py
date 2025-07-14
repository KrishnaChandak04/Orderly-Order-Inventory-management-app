
print("Starting flask app")
from app import create_app, socketio, db

app = create_app()



if __name__ == '__main__':
    socketio.run(app, debug=True)