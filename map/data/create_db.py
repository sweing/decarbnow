#!/usr/bin/python

import sqlite3

conn = sqlite3.connect('keanomap.db')
print("Opened database successfully");

conn.execute('''CREATE TABLE KEANOMAP
         (RAND_STR      CHAR(50),
         GEOHASH        CHAR(50),
         ORIGURL        CHAR(256),
         TAG            CHAR(50),
         TTEXT          CHAR(50));''')
print("Table created successfully");

conn.close()
