# 베이스 이미지로 Python 3.9 사용
FROM python:3.9

# 작업 디렉토리 설정
WORKDIR /app

# 필요 패키지 설치를 위해 pip 업그레이드
RUN pip install --upgrade pip

# 필요한 패키지 설치
RUN pip install scikit-learn coremltools numpy

RUN pip install protobuf

RUN pip install --upgrade coremltools

# 현재 디렉토리의 모든 파일을 컨테이너의 작업 디렉토리에 복사
COPY . /app

# 모델 학습 및 CoreML 변환 스크립트 실행
CMD ["python", "train_and_convert.py"]