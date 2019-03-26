import pymysql as db
import gevent.queue

class MySqlDriver(object):

    def __init__(self, **kwargs):
        self.__connect_params = kwargs
        self.__pool = None  # type: gevent.queue.Queue

    def setup_connection(self, num_conn=100):
        self.__pool = gevent.queue.Queue(maxsize=num_conn)
        for i in range(num_conn):
            conn = db.connect(**self.__connect_params)
            self.__pool.put_nowait(conn)

    def __test_and_reconnect(self, conn):
        """
        Reconnect lost connection
        Args:
            conn(db.connections.Connection):

        Returns:
            new connection
        """
        try:
            if not conn.open:
                conn.ping()
            return conn
        except db.OperationalError:
            conn = db.connect(**self.__connect_params)
            return conn

    def __get_connection(self):
        if self.__pool.maxsize < 1:
            print("Connection pool is empty. Trying to setup the connection pool with default value (100).")
            self.setup_connection()
        conn = self.__pool.get()  # type: db.connections.Connection
        conn = self.__test_and_reconnect(conn)
        return conn

    def __put_connection(self, conn):
        self.__pool.put(conn, block=False)

    def commit(self, conn):
        """
        Commit a transaction and close the connection immediately

        :return: True if successful, False otherwise
        """
        if conn is not None:
            conn.commit()
            self.__put_connection(conn)
            successful = True
        else:
            successful = False
            print('connection was null during commit phase.')

        return successful

    def rollback(self, conn):
        """
        Rollback a transaction and close the connection immediately

        :return: True if successful, False otherwise
        """
        if conn is not None:
            conn.rollback()
            self.__put_connection(conn)
            successful = True
        else:
            successful = False
            print('connection was null during rollback phase.')

        return successful

    def begin_transaction(self):
        """
        Get a connection and preapre it with begin transaction
        """
        conn = self.__get_connection()
        conn.begin()
        return conn

    def exec_transaction(self, conn, stmt, args=None, commit=False):
        """
        Execute a statement with given connection
        """
        try:
            cursor = conn.cursor()
            if args is not None:
                cursor.execute(stmt, args)
            else:
                cursor.execute(stmt)
        except Exception as e:
            print("Error executing SQL with info: %s\n---Retrying once. SQL: %s" % (e, stmt[:100]))
            conn = self.__test_and_reconnect(conn)
            cursor = conn.cursor()
            if args is not None:
                cursor.execute(stmt, args)
            else:
                cursor.execute(stmt)

        if commit:
            self.commit(conn)

        row_count = cursor.rowcount
        cursor.close()

        return row_count

    def exec_transaction_many(self, conn, stmt, args=None, commit=False):
        """
        Execute a statement with given connection
        """
        try:
            cursor = conn.cursor()
            if args is not None:
                cursor.executemany(stmt, args)
            else:
                cursor.execute(stmt)
        except Exception as e:
            print("Error executing SQL with info: %s\n---Retrying once. SQL: %s" % (e, stmt[:100]))
            conn = self.__test_and_reconnect(conn)
            cursor = conn.cursor()
            if args is not None:
                cursor.execute(stmt, args)
            else:
                cursor.execute(stmt)

        if commit:
            self.commit(conn)

        row_count = cursor.rowcount
        cursor.close()

        return row_count

    def select_one(self, query, args=None, first_try=True, conn=None):
        """
        Execute a select statement

        Args:
            query (str): the statement to execute
            args (tuple): arguments for the where clause
            first_try (bool): flag for retry query
            conn (db.connections.Connection): connection object to use

        Returns:
            return only one row
        """
        if conn is None:
            conn = self.__get_connection()
        cursor = conn.cursor()

        try:
            if args is not None:
                cursor.execute(query, args)
            else:
                cursor.execute(query)

            conn.commit()
            result = cursor.fetchall()
            cursor.close()
            return result[0] if result else None

        except Exception as e:
            if first_try:
                return self.retry_query(conn, 'select_one', query, args, None, e)
            else:
                print('Retry fail. Err:%s' % e)
                return None

        finally:
            if first_try:
                self.__put_connection(conn)

    def select(self, query, args=None, first_try=True, conn=None):
        """
        Execute a select statement

        Args:
            query (str): the statement to execute
            args (tuple): arguments for the where clause
            first_try (bool): flag for retry query
            conn (db.connections.Connection): connection object to use

        Returns:
            array of tuple from the query result
        """
        if conn is None:
            conn = self.__get_connection()
        cursor = conn.cursor()

        try:
            if args is not None:
                cursor.execute(query, args)
            else:
                cursor.execute(query)

            conn.commit()
            rows = cursor.fetchall()
            cursor.close()
            return rows

        except Exception as e:
            if first_try:
                return self.retry_query(conn, 'select', query, args, None, e)
            else:
                print('Retry fail. Err:%s' % e)
                return None

        finally:
            if first_try:
                self.__put_connection(conn)

    def insert_get_id(self, stmt, args=None, commit=False, first_try=True, conn=None):
        """
        Execute an sql statement and return the last inserted id
        Args:
            stmt (str): the statement to execute
            args (tuple): arguments for the where clause
            commit (bool): True if transaction should be committed. Defaults to False
            first_try (bool): flag for retry query
            conn (db.connections.Connection): connection object to use

        Returns:
            Last inserted id

        """
        if conn is None:
            conn = self.__get_connection()
        cursor = conn.cursor()

        try:
            if args is not None:
                cursor.execute(stmt, args)
            else:
                cursor.execute(stmt)

            if commit:
                conn.commit()

            last_row_id = cursor.lastrowid
            cursor.close()
            return last_row_id

        except Exception as e:
            if first_try:
                return self.retry_query(conn, 'insert_get_id', stmt, args, commit, e)
            else:
                print('Retry fail. Err:%s' % e)
                return None

        finally:
            if first_try:
                self.__put_connection(conn)

    def execute_stmt(self, stmt, args=None, commit=False, first_try=True, conn=None):
        """
        Execute a sql statement

        Args:
            stmt (str): the statement to execute
            args (tuple): optional arguments, is a tuple
            commit (bool): True if transaction should be committed. Defaults to False
            first_try (bool): flag for retry query
            conn (db.connections.Connection): connection object to use

        Returns
            count of the number of affected rows

        Examples
            self.execute_stmt('INSERT INTO tb VALUES (val1, val2, val3)
            self.execute_stmt('INSERT INTO tb VALUES(?, ?, ?)', [val1, val2, val3])
        """
        if conn is None:
            conn = self.__get_connection()
        cursor = conn.cursor()

        try:
            if args is not None:
                cursor.execute(stmt, args)
            else:
                cursor.execute(stmt)

            if commit:
                conn.commit()

            row_count = cursor.rowcount
            cursor.close()
            return row_count

        except Exception as e:
            if first_try:
                return self.retry_query(conn, 'execute_stmt', stmt, args, commit, e)
            else:
                print('Retry fail. Err:%s' % e)
                return None

        finally:
            if first_try:
                self.__put_connection(conn)

    def execute_many(self, stmt, args, commit=False, first_try=True, conn=None):
        """
        Execute a sql statement with multiple args

        Args:
            stmt (str): the statement to execute
            args (list): optional arguments, list of tuple
            commit (bool): True if transaction should be committed. Defaults to False
            first_try (bool): flag for retry query
            conn (db.connections.Connection): connection object to use

        Returns
            count of the number of affected rows

        Examples
            self.execute_many("INSERT INTO tb (val1, val2) VALUES (?, ?);", [(i['val1'], i['val2']) for i in csv] )
        """
        if conn is None:
            conn = self.__get_connection()
        cursor = conn.cursor()

        try:
            cursor.executemany(stmt, args)

            if commit:
                conn.commit()

            row_count = cursor.rowcount
            cursor.close()
            return row_count

        except Exception as e:
            if first_try:
                return self.retry_query(conn, 'execute_many', stmt, args, commit, e)
            else:
                print('Retry fail.\nStmt=%s\nErr:%s' % (stmt[:200], e))
                return None

        finally:
            if first_try:
                self.__put_connection(conn)

    def retry_query(self, conn, fname, param1, param2, param3, e):
        """
        Retry a query once if the error is due to lost connection, or due to deadlock
        Args:
            conn (db.connections.Connection): connection object to use
            fname (str): function's name
            param1:
            param2:
            param3:
            e:

        Returns:

        """
        error_message = "Error executing SQL with info: %s\n---SQL:%s, %s" % (e, fname, param1[:100])
        print(error_message)

        if "Lost connection to MySQL" in str(e) or "Deadlock found" in str(e) or "Broken pipe" in str(e):
            conn = self.__test_and_reconnect(conn)

            if fname == 'select':
                return self.select(query=param1, args=param2, first_try=False, conn=conn)
            elif fname == 'select_one':
                return self.select_one(query=param1, args=param2, first_try=False, conn=conn)
            elif fname == 'insert_get_id':
                return self.insert_get_id(stmt=param1, args=param2, commit=param3, first_try=False, conn=conn)
            elif fname == 'execute_stmt':
                return self.execute_stmt(stmt=param1, args=param2, commit=param3, first_try=False, conn=conn)
            elif fname == 'execute_many':
                return self.execute_many(stmt=param1, args=param2, commit=param3, first_try=False, conn=conn)
        else:
            return None

    def disable_constraint(self):
        query = "SET FOREIGN_KEY_CHECKS = 0; "
        return self.execute_stmt(query, commit=True)

    def enable_constraint(self):
        query = "SET FOREIGN_KEY_CHECKS = 1; "
        return self.execute_stmt(query, commit=True)
