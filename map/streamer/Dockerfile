FROM python:3.7

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY tweepy_streamer.py /usr/src/app/tweepy_streamer.py
COPY export.py /usr/src/app/export.py
COPY credentials.py /usr/src/app/credentials.py
COPY config.yaml /usr/src/app/config.yaml
COPY create_db.py /usr/src/app/create_db.py

CMD [ "python", "./tweepy_streamer.py" ]
