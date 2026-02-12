import sys
sys.path.append("/var/www/irama1asia")
bind = "127.0.0.1:8000"
workers = 4
worker_class = "uvicorn.workers.UvicornWorker"
timeout = 300
