FROM python:3.9-slim

WORKDIR /app

COPY ./video_service/requirements.txt /app/

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY ./video_service /app/video_service
COPY ./video_service/server.py /app/server.py

EXPOSE 5002 

ENV FLASK_APP=server.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=5002


CMD ["flask", "run"] 