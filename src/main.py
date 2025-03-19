import os
import numpy as np
import time
import json
import logging
import google.cloud.logging
import google.cloud.pubsub
from flask import Flask


SENSOR_ID = os.environ["SENSOR_ID"]
TOPIC_PATH = os.environ["TOPIC_PATH"]
# The following envar API_KEY is not actually used in the code
API_KEY = os.environ["API_KEY"]

app = Flask(__name__)
publish_client = google.cloud.pubsub.PublisherClient()
client = google.cloud.logging.Client()
client.setup_logging()


@app.route("/")
def index():
    return f"AVI Aircraft Sensor, Aviatar, id={SENSOR_ID}"


@app.route("/send_report")
def send_report():
    report = get_report()
    logging.info(f"Received sensor report: {report}")
    publish_client.publish(TOPIC_PATH, json.dumps(report).encode('utf-8'))
    return "Report sent successfully"


@app.route("/report")
def get_report():
    return {
        "timestamp": time.time(),
        "sensor_id": SENSOR_ID,
        "temp_num": np.random.normal(90, 5)
    }


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
