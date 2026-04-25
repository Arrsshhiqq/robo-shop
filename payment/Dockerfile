FROM python:3.9-slim

EXPOSE 8080

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY *.py ./
COPY payment.ini ./

CMD ["python", "payment.py"]
