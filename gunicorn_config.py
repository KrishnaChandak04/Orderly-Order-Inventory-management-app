bind = "0.0.0.0:8000"
workers = 4  # Adjust based on your server's CPU cores
accesslog = '-'  # Log to stdout
errorlog = '-'   # Log to stderr
loglevel = 'info'
chdir = '/app' # Change to the application directory inside the container