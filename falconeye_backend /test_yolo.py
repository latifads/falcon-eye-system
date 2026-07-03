from ultralytics import YOLO
import cv2

# تحميل الموديل
model = YOLO("yolov8n.pt")

# قراءة الصورة
image_path = "test.jpg"
image = cv2.imread(image_path)

# تشغيل YOLO
results = model(image_path)

for r in results:
    for box in r.boxes:
        # الإحداثيات
        x1, y1, x2, y2 = map(int, box.xyxy[0])

        # نسبة الثقة
        confidence = float(box.conf[0])

      
        cv2.rectangle(
            image,
            (x1, y1),
            (x2, y2),
            (0, 255, 255), 
            2
        )

        label = f"Person {confidence:.2f}"
        cv2.putText(
            image,
            label,
            (x1, y1 - 10),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.6,
            (0, 255, 255),
            2
        )

cv2.imwrite("output.jpg", image)

print("Saved output.jpg with bounding boxes")