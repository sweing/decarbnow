import sqlite3
import geohash

def exportto(filePath, conn):
    cursor = conn.execute('SELECT RAND_STR, GEOHASH, ORIGURL, TAG, TTEXT FROM KEANOMAP').fetchall()
    print("exporting " + str(len(cursor)) + " entries")

    f = open(filePath, "w")
    f.write("{\"markers\":[")
    i = 0

    for row in cursor:
        geo = geohash.decode(row[1])
        f.write("{\"id\":\"" + row[0] + "\",\"lat\":" + str(geo[0]) + ",\"lng\":" + str(geo[1]) + ",\"origurl\":\"" + row[2] + "\",\"tag\":\"" + row[3] + "\",\"text\":\"" + row[4] + "\"}")
        i = i + 1
        if i != len(cursor):
            f.write(",")


    f.write("]}")
    f.close()

if __name__ == "__main__":
    exportto("marker.json", sqlite3.connect('keanomap.db'))
