#!/usr/bin/env python3

from flask import Flask, render_template, jsonify
import json
from decouple import config
app = Flask(__name__)
app.secret_key = config("SECRET_KEY")

@app.route("/api")
def home():
    with open("srv/static/caesar_part_1.json") as fn:
        text = json.load(fn)
    return render_template("index.html",text=text)


if __name__ == "__main__":
    app.run()



