#!/usr/bin/env python3

from flask import Flask, render_template, jsonify
import json
from decouple import config
from flask_cors import CORS
app = Flask(__name__)
app.secret_key = config("SECRET_KEY")

CORS(app)

@app.route("/api")
def api():
    with open("srv/static/caesar_part_1.json") as fn:
        text = json.load(fn)
    return jsonify(text)
@app.route("/")
def home():
    return render_template("Caesar.html")


if __name__ == "__main__":
    app.run()



