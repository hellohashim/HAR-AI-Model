# 🏃‍♂️ Human Activity Recognition (HAR) & Fall Detection on Mobile Edge

> A real-time, privacy-focused mobile application for Human Activity Recognition and Fall Detection using 1D-Convolutional Neural Networks (1D-CNN) and TensorFlow Lite.

![Project Status](https://img.shields.io/badge/Status-Completed-success)
![Tech Stack](https://img.shields.io/badge/Stack-Flutter%20%7C%20TensorFlow%20%7C%20Python-blue)
![Accuracy](https://img.shields.io/badge/Validation%20Accuracy-99.01%25-brightgreen)

## 📖 Overview
This project presents a solution for continuous, unobtrusive monitoring of physical activities and emergency fall detection. Unlike cloud-based solutions that suffer from latency and privacy issues, this system performs **on-device inference** using a lightweight 1D-CNN model deployed via TensorFlow Lite on a Flutter application.

The system is capable of recognizing **5 distinct classes**:
* 🚶 **Walking**
* 🏃 **Jogging**
* 🪑 **Sitting**
* 🧍 **Standing**
* 🚨 **Falling** (Critical Alert)

## 🚀 Key Features
* [cite_start]**Edge Computing:** Zero dependency on internet connectivity; all processing happens locally on the device[cite: 22].
* [cite_start]**Real-Time Inference:** Low-latency predictions suitable for immediate fall alerts[cite: 17].
* [cite_start]**High Accuracy:** Achieved **99.01% validation accuracy** using a custom 1D-CNN architecture[cite: 9].
* [cite_start]**False Positive Reduction:** Integrates a physics-based heuristic (Acceleration > 1.8G) to distinguish actual falls from abrupt sitting actions[cite: 199].
* [cite_start]**Background Monitoring:** Runs as a continuous background service in the mobile app "Fiter AI"[cite: 197].

## 🛠️ Tech Stack & Methodology

### 🧠 Machine Learning Pipeline
* **Frameworks:** Python, TensorFlow/Keras, Scikit-learn, NumPy.
* **Model Architecture:**
    * **Input:** 128 timesteps × 8 features (Accelerometer, Gyroscope, Orientation).
    * [cite_start]**Layers:** BatchNormalization → Conv1D (64 filters) → Conv1D (64 filters) → Dropout (50%) → MaxPooling1D → Dense (100) → Softmax Output [cite: 84-89].
    * [cite_start]**Optimization:** Adam Optimizer, Categorical Crossentropy loss[cite: 105].

### 📱 Mobile Application
* **Framework:** Flutter (Dart).
* **Inference Engine:** `tflite_flutter` plugin.
* [cite_start]**Sensor Handling:** Streams accelerometer and gyroscope data at ~50Hz, creating a sliding window of 2.56 seconds with 78% overlap[cite: 50, 51].

## 📊 Dataset & Results
[cite_start]The model was trained on a dataset comprising **6,042 instances** of segmented time-series data[cite: 8].

| Metric | Value |
| :--- | :--- |
| **Training Accuracy** | 98.61% |
| **Validation Accuracy** | 99.01% |
| **Training Loss** | 0.0343 |
| **Validation Loss** | 0.0455 |

**Confusion Matrix:**
The model demonstrates high precision and recall across all classes, specifically effectively isolating the "Falling" class with minimal confusion.

## ⚙️ Installation & Setup

### Prerequisites
* Flutter SDK installed.
* Python 3.8+ (for model retraining).

### Running the App
1.  Clone the repo:
    ```bash
    git clone [https://github.com/hellohashim/HAR-AI-Model.git](https://github.com/hellohashim/HAR-AI-Model.git)
    ```
2.  Navigate to the app directory:
    ```bash
    cd mobile_app
    ```
3.  Install dependencies:
    ```bash
    flutter pub get
    ```
4.  Run on a physical device (Emulators may not support all sensors):
    ```bash
    flutter run
    ```

## 🔮 Future Work
* [cite_start]**Quantization:** Implementing 8-bit quantization to further reduce model size (currently 1.1MB)[cite: 297].
* [cite_start]**Health API Integration:** Syncing data with Google Fit/Apple Health[cite: 310].
* [cite_start]**Cross-Subject Testing:** Expanding the dataset to include more diverse device placements[cite: 293].

## 👥 Authors
* **Muhammad Hashim Nazir**
---
*Based on the research paper: "Human Activity Recognition and Fall Detection on Mobile Devices"*
