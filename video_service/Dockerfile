FROM python:3.9-slim

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY ./video_app /app/video_app
COPY ./server.py /app/server.py

EXPOSE 5002


CMD ["gunicorn", "--bind", "0.0.0.0:5002", "server:app"]