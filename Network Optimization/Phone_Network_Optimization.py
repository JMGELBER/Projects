# -*- coding: utf-8 -*-
"""
Created on Tue Mar 24 14:31:02 2020

"""
# Importing Packages
import networkx as nx
import pandas as pd 
import numpy as np

# Changing Dataframe Settings
pd.set_option('display.max_columns', None)
pd.set_option('display.width', None)
pd.set_option('display.max_colwidth', None)
pd.set_option('expand_frame_repr', True)


network_k_0 = pd.read_excel("Network_Info.xlsx", sheet_name="K = 0") #read the excel file into dataframe when k= 0
network_k_1000 = pd.read_excel("Network_Info.xlsx", sheet_name="K = 1000") #read the excel file into dataframe when k= 1000
network_k_100000 = pd.read_excel("Network_Info.xlsx", sheet_name="K = 100000") #read the excel file into dataframe when k= 100000

#putting all network conditions in a list
network_info = [network_k_0, network_k_1000, network_k_100000 ]

city_demand = pd.read_excel("City_Demand.xlsx", header=1) #read the excel file for demand between cities into a dataframe  

cities=['San Francisco', 'Fort Worth', 'Jacksonville', 'Austin', 'San Jose', 'Dallas', 'San Diego', 'San Antonio', 'Philadelphia' , 'Phoenix',	'Houston', 'Chicago','Los Angeles'	,	'NY city']

labels=['Starting Node', 'To', 'Distance', 'pred', 'euclidean', 'eucli * 4/3', 'satisfy constraint?', 'Demand'] 

# This is where you set your starting network conditions dataframe 
df = network_info[0]
    
h=nx.from_pandas_edgelist(df, source = df.columns[0], target = df.columns[1], edge_attr = df.columns[2]) #reads dataframe into edgelist for when k=0
#info of edgelist h 
print(nx.info(h)) 
# gives nodes of edgelist h 
print('Nodes:', h.nodes()) 
# gives edges of edgelist h 
#print(h.edges()) 

djk = pd.DataFrame(np.zeros((len(cities),len(labels))),columns=labels) #make a dataframe to store results of dijkstra 

nx.draw_networkx(h, with_labels = True) # draws edgelist h 

def dijkstra_meth(cities): # function defines to run dijkstra for all cities and store results
    pred=[] # creates empty list for the predecessor results for dijkstra
    dist=[] # creates empty list for the distance results for dijkstra
    for i in range(len(cities)):
        x, y = nx.dijkstra_predecessor_and_distance(h, cities[i], weight=df.columns[2]) 
        pred.append(x)
        dist.append(y)
        
    return pred, dist

pred, dist = dijkstra_meth(cities)

   
# reforming a dataframe djk to be able to handle results from dijkstra_predecessor_and_distance
djk['To'] = cities #sets ending nodes column equal list cities
cit = pd.Series(cities) # make list cities into a series 
cit = cit.repeat(14) # everyvalue it series cit repeated 14 times
cit = cit.reset_index(drop=True) # reorganizing index cit to start from 0
djk = pd.concat([djk] * 14, ignore_index=True) #multiply data frame djk * 14 to accomodate all results
djk['Starting Node'] = cit #setting starting node columns equal to cit



for i in range(0,len(cities)): # storing the results from dijkstra in dataframe djk
    djk.loc[(0 + (i * 14)):(14 * (i + 1)), 'pred'] = djk.loc[(0 + (i * 14)):(14 * (i + 1)), 'To'].map(pred[i])
    djk.loc[(0 + (i * 14)):(14*(i + 1)), 'Distance'] = djk.loc[(0 + (i * 14)):(14 * (i + 1)), 'To'].map(dist[i])


# storing euclidean distance for each path in djk
def extract_row(x):
    try:
        if x.Distance > 0:
            row=int(df.loc[(df[df.columns[0]]== x['Starting Node']) & (df['City_2']== x['To'])].index[0])
            return df.iloc[row,2]
    except: 
        pass
  
djk.loc[:,'euclidean'] = djk.apply(extract_row, axis = 1)

#print(djk.Distance)
 
    
djk['eucli * 4/3'] = djk['euclidean']*4/3 # putting constraint into djk

# Creating function to check the constraint
def constraint(x):
    if x.loc['Distance'] <= x.loc['eucli * 4/3']:
        return 'Yes'
    else:
        return 'No'
        
# checking is constraing is satisfied or not
djk['satisfy constraint?'] = djk.apply(constraint, axis = 1)

# adding demand to djk dataframe
djk['row'] = djk.apply(lambda x: int(city_demand.loc[(city_demand['City'] == x['Starting Node'])].index[0]), axis = 1)
djk['Demand'] = djk.apply(lambda x:  city_demand.loc[x['row'],x['To']], axis = 1)

# dropping helper column
djk.drop(columns = 'row', inplace = True)

djk['djkista cost'] = djk['Distance'] * djk['Demand'] # checking cost djkista distacne * demand
djk['euclidean cost'] = djk['euclidean'] * djk['Demand']  # checking cost euclidean distance * demand
djk['difference'] = djk['djkista cost'] - djk['euclidean cost']  # checking difference 'euclidean cost'  and 'djkista cost'

djk['k=1000']=np.zeros(len(djk))
djk['k=100,000']=np.zeros(len(djk))

# checking if the difference in cost is greater than k, when k=1000
djk['k=1000'] = djk.apply(lambda x: 'Yes' if x.difference > 1000 else 'No' , axis = 1)

# checking if the difference in cost is greater than k, when k=100,000
djk['k=100,000'] = djk.apply(lambda x: 'Yes' if x.difference > 100000 else 'No' , axis = 1)

# making a mini dataframe of all paths that constraint (euli * 4/3) is not satisifed
z=djk.loc[djk['satisfy constraint?']=='No']

# making a mini dataframe of all paths where  difference is greater than k, when k=1000
w=djk.loc[djk['k=1000']=='Yes']

# making a mini dataframe of all paths where  difference is greater than k, when k=100,000
y=djk.loc[djk['k=100,000']=='Yes']

# checking all 14 cities as staring for djikstra into mini dataframes
cities_dist = dict()
for city in cities: 
    city_results = djk.loc[djk['Starting Node'] == city]
    city_results = city_results.sort_values(by=['Distance'])
    city_results = city_results.reset_index(drop=True)
    cities_dist[city] = city_results
 

# This writes the results to excel 
#w.to_excel(excel_writer=")

