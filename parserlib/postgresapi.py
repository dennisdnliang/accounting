# -*- coding: utf-8 -*-
"""
Created on Sun Apr 14 11:45:53 2019

@author: Dennis
"""

import psycopg2
from readconfig import readconfig
import pandas as pd
import pandas.io.sql as sqlio

def insertdf(df,table,filterinput=True):
	#Connect to postgresql
	
	if filterinput:
		df=filterload(df,table)
		
	if df.empty:
		print('Insert Dataframe Empty ...... ')
		return 1
	
	conn = None
	try: 
		#read connection params
		params = readconfig('py_postgres_conn.ini','postgresql')
		
		#connect to PosgreSQL server
		print('Connecting to the PostgreSQL database ...... ')
		conn = psycopg2.connect(**params)
		
		#create a cursor
		cur = conn.cursor()
		
		print('Setting up data to insert into PostgreSQL database ...... ')
		
		df = df.where((pd.notnull(df)), None) #change NaN into None which inserts to NULL
		
		columnlist = df.columns.values
		df_col_headers = ','.join(map(str,columnlist))
		insert_df = df[columnlist]
		insert_tuples = [tuple(x) for x in insert_df.values]
		sformatting = ','.join(['%s']*len(columnlist))
		sql = "INSERT INTO "+table+" ("+df_col_headers+") VALUES("+sformatting+");"
		
		cur.executemany(sql,insert_tuples)
		
		print('Comitting Changes ...... ')
		
		conn.commit()
		#close communication 
		cur.close()
	except (Exception, psycopg2.DatabaseError) as error:
		print(error)
	finally:
		if conn is not None:
			conn.close()
			print('Database connection closed.')
			
			
def filterload(df,table):
	#Connect to postgresql
	
	df_new = df.copy()
	dfcompare = df.copy()
	dbdf = readtodf(table)
	dbdf = dbdf[dfcompare.columns]
	dbdftypes = dbdf.dtypes
	
	for index, value in dbdftypes.iteritems():
		if value == 'datetime64[ns]':
			dfcompare[index]=pd.to_datetime(dfcompare[index])
	
	dfcompare = dfcompare.where((pd.notnull(dfcompare)), None) #change NaN into None which inserts to NULL
	dbdf = dbdf.where((pd.notnull(dbdf)), None) #change NaN into None which inserts to NULL
	
	dfcompare = dfcompare.astype(str)
	dbdf = dbdf.astype(str)
	
	indexlist=[]
	
	print('Comparing and creating filtered df ......')
	
	for index, row in dfcompare.iterrows():
		if not (dbdf==row).all(axis=1).any(axis=0):
			indexlist.append(index)
	
	return df_new.loc[indexlist]


def readtodf(table):
	
	#Connect to postgresql
	
	conn = None
	try: 
		#read connection params
		params = readconfig('py_postgres_conn.ini','postgresql')
		
		#connect to PosgreSQL server
		print('Connecting to the PostgreSQL database ...... ')
		conn = psycopg2.connect(**params)
		
		#create a cursor
		cur = conn.cursor()
		
		#display PostgreSQL db server version
		
		sql = 'SELECT * from '+table+';'
		
		print('Querying '+table+' into dataframe ...... ')
		
		sqldf = sqlio.read_sql_query(sql,conn)

		#close communication 
		cur.close()
		
		return sqldf
	
	except (Exception, psycopg2.DatabaseError) as error:
		print(error)
	finally:
		if conn is not None:
			conn.close()
			print('Database connection closed.')
			
			


def testconnect():
	
	#Connect to postgresql
	
	conn = None
	try: 
		#read connection params
		params = readconfig('py_postgres_conn.ini','postgresql')
		
		#connect to PosgreSQL server
		print('Connecting to the PostgreSQL database ...... ')
		conn = psycopg2.connect(**params)
		
		#create a cursor
		cur = conn.cursor()
		
		#excute a statement 
		print('PostgreSQL database version and user:')
		cur.execute('SELECT version(),user')
		
		#display PostgreSQL db server version
		db_version = cur.fetchone()
		print(db_version)

		cur.execute('SELECT * from cashrecon.transactions')
		journalout = cur.fetchall()
		print(journalout)

		#close communication 
		cur.close()
	except (Exception, psycopg2.DatabaseError) as error:
		print(error)
	finally:
		if conn is not None:
			conn.close()
			print('Database connection closed.')
			
if __name__ == '__main__':
	testconnect()
	
	

	

