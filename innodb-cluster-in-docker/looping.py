import pymysql.cursors
from datetime import datetime
from time import sleep
from basedb import MySqlDriver

def try_shit(dbo):
    try:
        select_query = "SELECT CONCAT('LAST:', data_time) FROM testing ORDER BY data_time DESC LIMIT 1;"
        insert_query = "INSERT INTO testing VALUES(NOW());"

        ins = dbo.execute_stmt(stmt=insert_query, commit=True)
        print "insert_result=", ins
        slc = dbo.select_one(select_query)
        print "select_result=", slc

    except Exception as e :
        print("FUCK!", e)


def main():
    cstr = {
        "host": "mrouter",
        "port": 6446,
        "database": "ngetes",
        "user": "nyot",
        "password": "1234"
    }
    dbo=MySqlDriver(**cstr)
    dbo.setup_connection(3)
    while True:
        try_shit(dbo)
        sleep(1)

if __name__ == '__main__':
    main()