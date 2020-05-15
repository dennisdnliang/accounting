# -*- coding: utf-8 -*-
"""
Created on Fri Apr 19 15:36:48 2019

@author: Dennis
"""

#from configparser import ConfigParser
import pandas as pd
#from datetime import datetime as dt
from readconfig import readconfig

#from postgresapi import insertdf

class parser:
	
	def __init__(self,filename,bank_type,accountid=None):
		#load params
		self.filename=filename
		self.bank_type=bank_type
		self.accountid=accountid
		self.configfile='parseconfig.ini'
		
		parserparams = readconfig(self.configfile,self.bank_type)
		
		#unpack vars from parserparams
		for k, v in parserparams.items():
			setattr(self, k, v) #set self.keyvars as its values from dict
			
	def printparams(self):
		print (self.__dict__) #print all self vars
		
	def process(self):
		self.parsefile()
		self.data_df_format()
		
	def parsefile(self):
		
		csv_read_params={}
		
		if ('header' in self.__dict__ and self.header == 'None'):
			orig_col = self.orig_col.split(',')
			csv_read_params['index_col'] = False
			csv_read_params['header'] = None
			csv_read_params['names'] = orig_col
	
		if('thousands_delimiter' in self.__dict__):
			csv_read_params['thousands'] = self.thousands_delimiter
			
		if('skiprows' in self.__dict__):
			csv_read_params['skiprows'] = int(self.skiprows)
		
		with open(self.filename,'r') as csv_file:
			csv_read_params['filepath_or_buffer'] = csv_file
			data = pd.read_csv(**csv_read_params)
		
		self.unformatteddata = data
		
	def data_df_format(self,removenone=True):
		
		self.formatteddata = self.unformatteddata.copy()
		
		##### Change Colunm Names
		
		orig_col = self.orig_col.split(',')
		new_col = self.new_col.split(',')
		col_dict = dict(zip(orig_col,new_col))
	
		self.formatteddata = self.formatteddata.rename(columns = col_dict)
		
		##### Change Date Formatting
		
		orig_format = self.orig_dt_format
		new_format = self.new_dt_format
		
		datecolumns = self.datecolumns.split(',')
		#self.formatteddata=formatdate(self.formatteddata,datecolumns,orig_format,new_format)
		
		for col in datecolumns:
			self.formatteddata[col] = pd.to_datetime(self.formatteddata[col], format = orig_format)
			self.formatteddata[col] = self.formatteddata[col].dt.strftime(new_format)
		
		if(removenone):
			cols = [c for c in self.formatteddata.columns if c.lower()[:4]!='none']
			self.formatteddata = self.formatteddata[cols]
			
		if('bank' in self.__dict__):
			self.formatteddata['bank']=self.bank
		
		if(self.accountid):
			self.formatteddata['account_number']=self.accountid
			
		if('sortcols' in self.__dict__ and 'sortorder' in self.__dict__):
			scols = self.sortcols.split(',')
			sorder = self.sortorder.split(',')
			self.formatteddata = self.formatteddata.sort_values(by=scols,ascending=sorder)
			


###############################################################################

def formatdate(df,colunms,orig_format,new_format):
	
	df_new = df.copy()
	
	for col in colunms:
		df_new[col] = pd.to_datetime(df_new[col], format = orig_format)
		df_new[col] = df_new[col].dt.strftime(new_format)
		
	return df_new


def data_df_format(df,fileconfig,accountid,removenone=True):
	
	params = readconfig('parseconfig.ini',fileconfig)
	
	df_new = df.copy()
	
	##### Change Colunm Names
	
	orig_col = params['orig_col'].split(',')
	new_col = params['new_col'].split(',')
	col_dict = dict(zip(orig_col,new_col))

	df_new = df_new.rename(columns = col_dict)
	
	##### Change Date Formatting
	
	orig_format = params['orig_dt_format']
	new_format = params['new_dt_format']
	
	datecolumns = params['datecolumns'].split(',')
	df_new=formatdate(df_new,datecolumns,orig_format,new_format)
	
	if(removenone):
		cols = [c for c in df_new.columns if c.lower()[:4]!='none']
		df_new = df_new[cols]
		
	if('bank' in params):
		df_new['bank']=params['bank']
	
	if(accountid):
		df_new['account_number']=accountid
		
	if('sortcols' in params and 'sortorder' in params):
		scols = params['sortcols'].split(',')
		sorder = params['sortorder'].split(',')
		df_new = df_new.sort_values(by=scols,ascending=sorder)
		
	return df_new


def parsefile(filename,banktype):
	
	params = readconfig('parseconfig.ini',banktype)
	
	csv_read_params={}
	
	if ('header' in params and params['header'] == 'None'):
		orig_col = params['orig_col'].split(',')
		csv_read_params['index_col'] = False
		csv_read_params['header'] = None
		csv_read_params['names'] = orig_col

	if('thousands_delimiter' in params):
		csv_read_params['thousands'] = params['thousands_delimiter']
		
	if('skiprows' in params):
		csv_read_params['skiprows'] = int(params['skiprows'])
	
	with open(filename,'r') as csv_file:
		csv_read_params['filepath_or_buffer'] = csv_file
		data = pd.read_csv(**csv_read_params)
	
	return data

