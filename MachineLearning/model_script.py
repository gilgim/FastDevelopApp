import tensorflow as tf
from tensorflow.keras import layers
import numpy as np

# 모델 정의
def build_model():
    model = tf.keras.Sequential([
        # 입력: 4개의 특성 (repeatCount, memoryLevelNormalized, ageNormalized, repeatEffect)
        layers.Input(shape=(4,)),

        layers.Dense(16, activation='relu'),
        layers.Dense(8, activation='relu'),
        layers.Dense(1, activation='linear')  # 출력: k 값
    ])
    return model

# 모델 생성
model = build_model()

# 가상의 데이터로 학습
X_train = np.random.rand(100, 4)  # 100개의 샘플, 4개의 특성
y_train = np.random.rand(100, 1)  # 100개의 출력 k 값

model.compile(optimizer='adam', loss='mse')
model.fit(X_train, y_train, epochs=10)

# TensorFlow Lite 변환
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# 모델 저장
with open("model.tflite", "wb") as f:
    f.write(tflite_model)

print("Updated Model Create Complete")
