# -*- coding: utf-8 -*-
"""
Created on Fri Apr 19 20:22:01 2019

@author: Dennis
"""

from configparser import ConfigParser
import pandas as pd
from datetime import datetime as dt


def readconfig(filename='connections.ini', section='postgresql'):
	
	#init parser
	parser = ConfigParser(interpolation=None)
	#read ini using parser
	parser.read(filename)
	
	#read section from ini file
	db = {}
	if parser.has_section(section):
		params = parser.items(section)
		for param in params:
			db[param[0]] = param[1]
	else:
		raise Exception('Section {0} not found in the {1} file'.format(section,filename))
		
	return db
