from ultralytics import YOLO
import os

MODEL_PATH = "runs/detect/train2/weights/best.pt"
IMAGES_DIR = "dataset/images/val"
LABELS_DIR = "dataset/labels/val"
IOU_THRESHOLD = 0.5
IMG_SIZE = 640

def iou(box1, box2):
    xA = max(box1[0], box2[0])
    yA = max(box1[1], box2[1])
    xB = min(box1[2], box2[2])
    yB = min(box1[3], box2[3])

    inter = max(0, xB - xA) * max(0, yB - yA)
    area1 = (box1[2] - box1[0]) * (box1[3] - box1[1])
    area2 = (box2[2] - box2[0]) * (box2[3] - box2[1])
    union = area1 + area2 - inter

    return inter / union if union != 0 else 0

model = YOLO(MODEL_PATH)

total = 0
correct = 0

for img_name in os.listdir(IMAGES_DIR):
    if not img_name.endswith((".jpg", ".png")):
        continue

    img_path = os.path.join(IMAGES_DIR, img_name)
    label_path = os.path.join(
        LABELS_DIR,
        img_name.replace(".jpg", ".txt").replace(".png", ".txt")
    )

    if not os.path.exists(label_path):
        continue

    gt_boxes = []
    with open(label_path) as f:
        for line in f:
            parts = list(map(float, line.split()))
            cls = int(parts[0])
            coords = parts[1:]

            xs = coords[0::2]
            ys = coords[1::2]

            x1 = min(xs) * IMG_SIZE
            y1 = min(ys) * IMG_SIZE
            x2 = max(xs) * IMG_SIZE
            y2 = max(ys) * IMG_SIZE

            gt_boxes.append((cls, [x1, y1, x2, y2]))

    results = model(img_path)[0]

    for cls_gt, gt_box in gt_boxes:
        total += 1
        found = False

        for box, cls_pred in zip(results.boxes.xyxy, results.boxes.cls):
            if int(cls_pred) == cls_gt:
                if iou(gt_box, box.tolist()) >= IOU_THRESHOLD:
                    found = True
                    break

        if found:
            correct += 1

accuracy = correct / total if total > 0 else 0
print(f"Accuracy: {accuracy:.2f} ({correct}/{total})")