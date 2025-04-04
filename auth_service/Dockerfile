
FROM python:3.9-slim


WORKDIR /app


COPY ./auth_service/requirements.txt /app/


RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


COPY ./auth_service /app/auth_service
COPY ./auth_service/server.py /app/server.py


EXPOSE 5001


ENV FLASK_APP=server.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=5001



CMD ["flask", "run"]