FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip install flask

WORKDIR /app

COPY app.py /app

CMD ["python3", "app.py"]
