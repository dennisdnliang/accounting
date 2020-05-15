# -*- coding: utf-8 -*-
"""
Created on Sat Apr 20 13:58:00 2019

@author: Dennis
"""

#import pandas as pd
from parserlib import data_df_format,parsefile,parser
from postgresapi import insertdf,filterload
#from readconfig import readconfig

#import psycopg2

###############################################################################


chase_file = ""

data_chase_unformat = parsefile(chase_file,'chase')
data_chase_formatted = data_df_format(data_chase_unformat,'chase','')
data_chase_insert = filterload(data_chase_formatted,'cashrecon.transactions')
#insertdf(data_chase_formatted,'cashrecon.transactions')

chase_parse = parser(chase_file,'chase','')
chase_parse.process()
insertdf(chase_parse.formatteddata,'cashrecon.transactions')

chase_ufd=chase_parse.unformatteddata
chase_fd=chase_parse.formatteddata

chase_compare_ufd=(chase_ufd.astype(str)==data_chase_unformat.astype(str))
chase_compare_ufd_result=chase_compare_ufd.all(axis=1).all(axis=0)
chase_compare_fd=(chase_fd.astype(str)==data_chase_formatted.astype(str))
chase_compare_fd_result=chase_compare_fd.all(axis=1).all(axis=0)

chase_parse.unformatteddata==data_chase_unformat
chase_parse.formatteddata==data_chase_formatted
########################

citi_file = ""

data_citi_unformat = parsefile(citi_file,'citi')
data_citi_formatted = data_df_format(data_citi_unformat,'citi','')
#insertdf(data_citi_formatted,'cashrecon.transactions')

citi_parse = parser(citi_file,'citi','')
citi_parse.process()
insertdf(citi_parse.formatteddata,'cashrecon.transactions')

citi_ufd=citi_parse.unformatteddata
citi_fd=citi_parse.formatteddata

citi_compare_ufd=(citi_ufd.astype(str)==data_citi_unformat.astype(str))
citi_compare_ufd_result=citi_compare_ufd.all(axis=1).all(axis=0)
citi_compare_fd=(citi_fd.astype(str)==data_citi_formatted.astype(str))
citi_compare_fd_result=citi_compare_fd.all(axis=1).all(axis=0)

citi_parse.unformatteddata==data_citi_unformat
citi_parse.formatteddata==data_citi_formatted
########################

bofa_file = ""

data_bofa_unformat = parsefile(bofa_file,'bofa')
data_bofa_formatted = data_df_format(data_bofa_unformat,'bofa','')
#insertdf(data_bofa_formatted,'cashrecon.transactions')

bofa_parse = parser(bofa_file,'bofa','')
bofa_parse.process()
insertdf(bofa_parse.formatteddata,'cashrecon.transactions')

bofa_ufd=bofa_parse.unformatteddata
bofa_fd=bofa_parse.formatteddata

bofa_compare_ufd=(bofa_ufd.astype(str)==data_bofa_unformat.astype(str))
bofa_compare_ufd_result=bofa_compare_ufd.all(axis=1).all(axis=0)
bofa_compare_fd=(bofa_fd.astype(str)==data_bofa_formatted.astype(str))
bofa_compare_fd_result=bofa_compare_fd.all(axis=1).all(axis=0)

bofa_parse.unformatteddata==data_bofa_unformat
bofa_parse.formatteddata==data_bofa_formatted


"""

df=data_citi

table = 'cashrecon.transactions'

params = readconfig('py_postgres_conn.ini','postgresql')

#connect to PosgreSQL server
print('Connecting to the PostgreSQL database ...... ')
conn = psycopg2.connect(**params)

#create a cursor
cur = conn.cursor()

print('Setting up data to insert into PostgreSQL database ...... ')

columnlist = df.columns.values
df_col_headers = ','.join(map(str,columnlist))
insert_df = df[columnlist]
insert_tuples = [tuple(x) for x in insert_df.values]
sformatting = ','.join(['%s']*len(columnlist))
sql = "INSERT INTO "+table+"("+df_col_headers+") VALUES("+sformatting+");"

cur.executemany(sql,insert_tuples)

print('Comitting Changes ...... ')

conn.commit()
#close communication 
cur.close()
"""