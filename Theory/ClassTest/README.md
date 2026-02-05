**Objective:** Create a Docker file to run a python script, with pip dependencies

Dockerfile
```Dockerfile
FROM python:3.11.14-alpine3.23
WORKDIR /home
COPY app.py .
RUN pip install numpy
CMD ["python","./app.py"]
```


App.py
```Python
import numpy as np  # dependency for learning purpose

stored_sapid = "500119624"
while (True):
    user_sapid = input("Enter your SAP ID: ")
    if user_sapid == stored_sapid:
        print("Matched")
    else:
        print("Not Matched")
```

To build and run the Container
```Bash
docker build -t python-app:1.0 .
docker run -rm -it --name python-test python-app:1.0
```