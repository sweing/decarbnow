#!/usr/bin/python

import sqlite3

print("Creating database")
conn = sqlite3.connect('data/keanomap.db')
print("Opened database successfully")

conn.execute('''CREATE TABLE IF NOT EXISTS KEANOMAP
         (RAND_STR      CHAR(50),
         GEOHASH        CHAR(50),
         ORIGURL        CHAR(256),
         TAG            CHAR(50),
         TTEXT          CHAR(50));''')
print("Table created successfully")

conn.execute('''INSERT INTO KEANOMAP VALUES('3JdVhSwNsFk2WMID','u2ecbb98przg','https://twitter.com/EcoInternetDrGB/status/1184901148987162624','transition','Solar Power! ☀️');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('H5mUuCZZGhMbr4uz','u2e6fm8kz15d','https://twitter.com/gruenewien/status/1157588184689258496','transition','Coal Shutdown! 🎉');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('7EqfK6i29XDAqJ4a','u2edrdvbdjjp','https://twitter.com/impacthubvienna/status/1185119324018790400','climateaction','Climathon! 💪');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('phlcuL5AKzOdVqle','u2edhwk4pv0q','https://twitter.com/Der_Gregor/status/1185212199117246464','climateaction','Cycling! 🚴🏿');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('uv7F33pst09lJnca','u2edgbvcpjyc','https://twitter.com/VIEmediaNEWS/status/1092724181509246976','pollution','Feces 🤮');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('NfF95hKZSVTs5mDQ','u2edhqcezn7f','https://twitter.com/GeorgHanisch/status/1185501850847629313','climateaction','Extinction Rebellion! ⌛');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('lOYxnKTy21RSrbVG','u2edhwzw68m6','https://twitter.com/EurocommPR/status/1154645634928009216','transition','Urban Gardening! 🌻');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('TN5GQSGadn8pLNJG','u2edhrk1pen3','https://twitter.com/Colt_Technology/status/1129028539666317312','transition','Cleaning Up! 🧽');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('AONic9h41wA9EN5I','u2ed78zppjqe','https://twitter.com/GreenCityeV/status/1141614942900166656','transition','Trees! 🌳');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('Q8vWlegzqV1exHq6','u2edm6xyrfn7','https://twitter.com/fluglehrer/status/1133654191371636736','pollution','Antibiotics Pollution! 💊');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('s8u5LKjsvUlU3kUs','u2ed5y91buf8','https://twitter.com/michpeko/status/1088063114933878784','pollution','Air Pollution! 😷');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('HUlglkrvvDzHTR25','u2edm903x7j6','https://twitter.com/GreenpeaceNZ/status/1169366632000438272','pollution','Polluting the Planet! 🛢️');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('Es4yVmiVVmp8RtE3','u2edk95qk6ky','https://twitter.com/TMadreiter/status/1168402377424199680','pollution','Extreme Weather! 🌪️');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('Es4yVmiVVmp8Rasd','u2edhw31xb','https://twitter.com/lindinger/status/523166265331159040','climateaction','Critical Mass at Karlsplatz Vienna on Friday');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('HUlglkrvvDzHTR31','u2edhws2bgcb','https://twitter.com/Luisamneubauer/status/1134434633851035648','climateaction','35.000 Protesters!');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('lOYxnKTy21RSrbaa','u3jexubsghhp','https://twitter.com/keanospace/status/1183358469484826626','pollution','Belchatov is the biggest single CO2 polluter in Europe. SHUT IT DOWN!');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('7EqfK6i29XDAqJrr','u15pehj14wnn','https://twitter.com/ohboywhatashot/status/1184472809164152834','pollution','Dutch government ready to shut down farms to control NO2 pollution.');''')
conn.execute('''INSERT INTO KEANOMAP VALUES('dqahsMeQuqy2z4eu','u2e9gffn8','','transition','#decarbnow developed at the Vienna Space Apps Challenge hosted at Factory Hub - T… https://t.co/vgJBX4MMrE');''')

conn.commit()

cur = conn.cursor()
cur.execute("SELECT * FROM KEANOMAP")

rows = cur.fetchall()

for row in rows:
    print(row)

print("Inserted data successfully?");
conn.close()
