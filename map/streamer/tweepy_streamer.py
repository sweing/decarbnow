from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
from tweepy import API
from tweepy import Cursor
from export import exportto

import credentials
import random
import string
import os
import boto3
import yaml
import re
import geohash
import json
from pathlib import Path
import sqlite3
import argparse

print("Starting streamer...")

import create_db

with open('config.yaml', "r") as config:
    script_config = yaml.load(config)

conn = sqlite3.connect('data/keanomap.db')
print("Opened database successfully")

auth = OAuthHandler(credentials.CONSUMER_KEY, credentials.CONSUMER_SECRET)
auth.set_access_token(credentials.ACCESS_TOKEN, credentials.ACCESS_TOKEN_SECRET)



class TwitterStreamer():
    """
    Class for streaming and processing live tweets
    """

    def __init__(self):
        pass

    def stream_tweets(self, hash_tag_list):
        # Authentication logic
        listener = SQLiteListener()
        stream = Stream(auth, listener)

        stream.filter(track=hash_tag_list)

    def import_tweets(self, hash_tag_list):
        api = API(auth,wait_on_rate_limit=True)
        for hash_tag in hash_tag_list:
            print("searching tweets for ", hash_tag)
            for tweet in Cursor(api.search,q=hash_tag,count=100,since="2019-01-01").items():
                print (tweet.created_at, tweet.text)
                # csvWriter.writerow([tweet.created_at, tweet.text.encode('utf-8')])

                m = re.search(r"\#([a-zA-Z]+)\s+\#([a-zA-Z]+)\s+\@([a-zA-Z0-9]+)\s+(.+)", tweet.text)

                if m == None:
                    print("next.")
                    print("---------")
                    continue

                print(m)
                resl = {
                    "detectionTag": m.group(1),
                    "layerTag": m.group(2),
                    "geo": m.group(3),
                    "text": m.group(4),
                    "origUrl": ""
                }

                if hasattr(tweet, "in_reply_to_screen_name"):
                    resl["origUrl"] = "https://twitter.com/" + tweet.in_reply_to_screen_name + "/status/" + tweet.in_reply_to_status_id_str

                # mydict = dict((k.strip(), v.strip()) for k,v in (item.split(':') for item in resl.split(',')))
                # mydict["l"] = geohash.decode(mydict["l"].replace('"', ''))
                # mydict["tag"] = mydict["tag"].replace('"', '')
                # mydict["text"] = re.sub(r"{[^>]*}|#decarbnow", "", tweet.text).lstrip(' ')

                # Generating a random ID
                random_str = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
                print(random_str)
                print(resl)

                conn.execute("INSERT INTO KEANOMAP (RAND_STR, GEOHASH, ORIGURL, TAG, TTEXT) \
                    VALUES (?, ?, ?, ?, ?)", (random_str, resl["geo"], resl["origUrl"], resl["layerTag"], resl["text"]))
                conn.commit()

                print("imported.")
                print("---------")

        print("Records created successfully")
        conn.close()

class SQLiteListener(StreamListener):
    """
    Basic listener class that just prints received tweets to console
    def __init__(self):
    """

    def on_data(self, data):
        try:
            print(data)

            # Generating a random ID
            random_str = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))

            tweet = json.loads(data)

            m = re.search(r"\#([a-zA-Z]+)\s+\#([a-zA-Z]+)\s+\@([a-zA-Z0-9]+)\s+(.+)", tweet["text"])

            if m == None:
                print("next.")
                print("---------")
                return True

            resl = {
                "detectionTag": m.group(1),
                "layerTag": m.group(2),
                "geo": m.group(3),
                "text": m.group(4),
                "origUrl": ""
            }

            if "in_reply_to_screen_name" in tweet and tweet["in_reply_to_screen_name"] is not None and tweet["in_reply_to_status_id_str"] is not None:
                resl["origUrl"] = "https://twitter.com/" + tweet["in_reply_to_screen_name"] + "/status/" + tweet["in_reply_to_status_id_str"]

            if "quoted_status_permalink" in tweet and tweet["quoted_status_permalink"] is not None:
                resl["origUrl"] = tweet["quoted_status_permalink"]["expanded"]

            print(random_str)
            print(resl)

            conn.execute("INSERT INTO KEANOMAP (RAND_STR, GEOHASH, ORIGURL, TAG, TTEXT) \
                VALUES (?, ?, ?, ?, ?)", (random_str, resl["geo"], resl["origUrl"], resl["layerTag"], resl["text"]))
            conn.commit()

            print("imported.")
            print("---------")

            exportto("data/marker.json", conn)

        except BaseException as e:
            print("Error: {}".format(str(e)))

        return True

    def on_error(self, status):
        print(status)

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument("-i", action='store_true')
    args = parser.parse_args()

    hash_tag_list = script_config['hash_tag_list']

    twitter_streamer = TwitterStreamer()

    if args.i:
        print("importing...")
        twitter_streamer.import_tweets(hash_tag_list)
    else:
        print("waiting for new tweets...")
        twitter_streamer.stream_tweets(hash_tag_list)

else:
    print("exiting.")
