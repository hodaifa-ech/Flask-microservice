FROM python:3.9-slim


WORKDIR /app



COPY ./requirements.txt /app/requirements.txt


RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


COPY ./auth_app /app/auth_app
COPY ./server.py /app/server.py


EXPOSE 5001


CMD ["gunicorn", "--bind", "0.0.0.0:5001", "server:app"]