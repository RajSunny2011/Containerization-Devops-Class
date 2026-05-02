from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    # return "Hello from CI/CD Pipeline!"
    return "Hello from CI/CD Pipeline!, my sapid is 500119624"

app.run(host="0.0.0.0", port=8000)
