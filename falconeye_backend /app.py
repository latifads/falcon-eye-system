from flask import Flask, request, jsonify, Response
from ultralytics import YOLO
import numpy as np
import cv2
import redis
import json
import threading
import time

from algorithm import *

# ==========================================
# FLASK APP
# ==========================================

app = Flask(__name__)

# ==========================================
# REDIS
# ==========================================

redis_client = redis.Redis(
    host='localhost',
    port=6379,
    decode_responses=True
)

# ==========================================
# YOLO MODEL
# ==========================================

model = YOLO("runs/detect/train4/weights/best.pt")

# ==========================================
# GLOBAL VARIABLES
# ==========================================

latest_frame = None
latest_detections = []
latest_direction = "SEARCHING"

fake_lat = 26.4207
fake_lng = 50.0888

# ==========================================
# START MISSION API
# ==========================================

@app.route("/start_mission", methods=["POST"])
def start_mission():

    data = request.json

    print("\n========== MISSION DATA ==========")
    print(data)
    print("==================================\n")

    mission_data = {

        "gender":
            data.get("gender"),

        "age_range":
            data.get("age_range"),

        "days_missing":
            data.get("days_missing"),

        "vehicle":
            data.get("vehicle"),

        "clothing_color":
            data.get("clothing_color"),

        "clothing_type":
            data.get("clothing_type"),

        "last_seen_location":
          data.get("last_seen_location"),
    }
    print("LAST SEEN LOCATION =", mission_data["last_seen_location"])

    # ======================================
    # CONVERT DAYS
    # ======================================

    days_map = {

        "1 day": 24,
        "2 days": 48,
        "3+ days": 72,
        "unknown": 24
    }

    hours_missing = days_map.get(
        mission_data["days_missing"].lower(),
        24
    )
    print("STEP 1")

    # ======================================
    # COMPUTE SEARCH RADIUS
    # ======================================

    radius = compute_search_radius(

        hours_missing,

        mission_data["age_range"],

        mission_data["gender"],

        mission_data["vehicle"]
    )

    print("STEP 2")

    # ======================================
    # CREATE GRID
    # ======================================

    grid, grid_w, grid_h = create_grid(radius)

    print("STEP 3")

    mission_data["radius"] = radius
    mission_data["grid_width"] = grid_w
    mission_data["grid_height"] = grid_h
    mission_data["grid"] = grid

    # ======================================
    # STORE IN REDIS
    # ======================================

    redis_client.set(
        "current_mission",
        json.dumps(mission_data)
    )

    print("Mission saved to Redis")

    test = redis_client.get(
        "current_mission"
    )

    print("REDIS TEST:")

    return jsonify({

        "message":
            "Mission started",

        "radius":
            radius,

        "grid_width":
            grid_w,

        "grid_height":
            grid_h
    })

# ==========================================
# ANALYZE FRAME API
# ==========================================

@app.route("/analyze_frame", methods=["POST"])
def analyze_frame():

    global latest_frame

    file = request.files.get("file")

    if file is None:

        return jsonify({
            "error": "No image uploaded"
        }), 400

    # ======================================
    # LOAD MISSION
    # ======================================

    mission_json = redis_client.get(
        "current_mission"
    )

    if mission_json is None:

        return jsonify({
            "error": "No active mission"
        }), 400

    mission_data = json.loads(
        mission_json
    )

    print("\n===== ACTIVE MISSION =====")
    print("Mission loaded")
    print("==========================\n")

    # ======================================
    # READ IMAGE
    # ======================================

    file_bytes = np.frombuffer(
        file.read(),
        np.uint8
    )

    frame = cv2.imdecode(
        file_bytes,
        cv2.IMREAD_COLOR
    )

    if frame is None:

        return jsonify({
            "error": "Invalid image"
        }), 400

    # ======================================
    # YOLO DETECTION
    # ======================================

    results = model(frame)

    annotated_frame = results[0].plot()

    latest_frame = annotated_frame
    global latest_detections

    detections = []

    for r in results:

        for box in r.boxes:

            cls = int(box.cls[0])

            label = model.names[cls]

            confidence = float(box.conf[0])

            detections.append({

                "label": label,

                "confidence":
                    round(confidence, 2)
            })
    latest_detections = detections

    print("\n===== DETECTIONS =====")
    print(detections)
    print("======================\n")

    return jsonify({

        "message":
            "Frame analyzed",

        "detections":
            detections
    })

# ==========================================
# VIDEO STREAM
# ==========================================

def generate_frames():

    global latest_frame

    while True:

        if latest_frame is None:
            continue

        _, buffer = cv2.imencode(
            '.jpg',
            latest_frame
        )

        frame_bytes = buffer.tobytes()

        yield (
            b'--frame\r\n'
            b'Content-Type: image/jpeg\r\n\r\n'
            + frame_bytes +
            b'\r\n'
        )

@app.route('/video_feed')
def video_feed():

    return Response(

        generate_frames(),

        mimetype=
        'multipart/x-mixed-replace; boundary=frame'
    )

@app.route("/latest_frame")
def latest_frame_endpoint():

    global latest_frame

    if latest_frame is None:
        return "No frame", 404

    _, buffer = cv2.imencode(
        ".jpg",
        latest_frame
    )

    return Response(
        buffer.tobytes(),
        mimetype="image/jpeg"
    )

# ==========================================
# GET GRID
# ==========================================

@app.route("/get_grid")
def get_grid():

    mission_json = redis_client.get(
        "current_mission"
    )

    print("MISSION JSON:")

    if mission_json is None:

        return jsonify({
            "error": "No active mission"
        }), 400

    mission_data = json.loads(
        mission_json
    )

    return jsonify({

        "grid":
            mission_data["grid"],

        "grid_width":
            mission_data["grid_width"],

        "grid_height":
            mission_data["grid_height"],

        "radius":
            mission_data["radius"],

        "last_seen_location":
            mission_data.get("last_seen_location"),
    })



# ==========================================
# FAKE DRONE LOCATION
# ==========================================

@app.route("/drone_location")
def drone_location():

    global fake_lat
    global fake_lng

    # simulate movement

    fake_lat += 0.0001
    fake_lng += 0.0001

    return jsonify({

        "lat": fake_lat,

        "lng": fake_lng
    })

@app.route("/detections")
def get_detections():

    global latest_detections

    return jsonify({
        "detections": latest_detections
    })


@app.route("/direction")
def get_direction():

    global latest_direction

    return jsonify({
        "direction": latest_direction
    })
# ==========================================
# VIDEO SIMULATION
# ==========================================

video_capture = cv2.VideoCapture(
    "drone_feed.mp4"
)


def process_video():

    global latest_frame
    global latest_detections
    global latest_direction

    while True:

        success, frame = video_capture.read()

        if not success:

            video_capture.set(
                cv2.CAP_PROP_POS_FRAMES,
                0
            )

            continue

        results = model(
            frame,
            verbose=False
        )

        annotated_frame = results[0].plot()

        latest_frame = annotated_frame

        detections = []

        direction = "SEARCHING"

        for r in results:

            for box in r.boxes:

                cls = int(box.cls[0])

                label = model.names[cls]

                confidence = float(box.conf[0])

                detections.append({
                    "label": label,
                    "confidence": round(confidence, 2)
                })

                if label == "person":

                    x1, y1, x2, y2 = box.xyxy[0]

                    center_x = (x1 + x2) / 2

                    frame_center = frame.shape[1] / 2

                    if center_x < frame_center - 100:
                        direction = "LEFT"

                    elif center_x > frame_center + 100:
                        direction = "RIGHT"

                    else:
                        direction = "FORWARD"

        latest_detections = detections
        latest_direction = direction

        time.sleep(0.03)

# ==========================================
# RUN SERVER
# ==========================================

if __name__ == "__main__":

    threading.Thread(
        target=process_video,
        daemon=True
    ).start()

    app.run(
        host="0.0.0.0",
        port=5001,
        debug=True
    )