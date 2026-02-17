FROM python:3.11.14-alpine3.23
WORKDIR /home
RUN pip install flask
CMD ["python","./app.py"]
