from flask import Flask
import time

app = Flask(__name__)

@app.route("/")
def home():
    return "App running under normal load"

@app.route("/load")
def load():
    # CPU stress for 5 seconds
    end = time.time() + 5
    while time.time() < end:
        x = 9999 * 8888
    return "High CPU load generated"

@app.route("/health")
def health():
    return "OK", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
