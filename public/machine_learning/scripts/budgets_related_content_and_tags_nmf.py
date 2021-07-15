#!/usr/bin/env python
# coding: utf-8

# In[1]:


"""
Related Participatory Budgeting projects and Tags - Dummy script

"""


# In[2]:


data_path = '../data'
config_file = 'budgets_related_content_and_tags_nmf.ini'
logging_file ='budgets_related_content_and_tags_nmf.log'


# In[3]:


# Input file:
inputjsonfile = 'budget_investments.json'

# Output files:
taggings_filename = 'ml_taggings_budgets.json'
tags_filename = 'ml_tags_budgets.json'
related_props_filename = 'ml_related_content_budgets.json'


# In[4]:


import os
import pandas as pd


# ### Read the proposals

# In[5]:


# proposals_input_df = pd.read_json(os.path.join(data_path,inputjsonfile),orient="records")
# col_id = 'id'
# cols_content = ['title','description']
# proposals_input_df = proposals_input_df[[col_id]+cols_content]    


# ### Create file: Taggings. Each line is a Tag associated to a Proposal

# In[6]:


taggings_file_cols = ['tag_id','taggable_id','taggable_type']
taggings_file_df = pd.DataFrame(columns=taggings_file_cols)
row = [0,1,'Budget::Investment']        
taggings_file_df = taggings_file_df.append(dict(zip(taggings_file_cols,row)), ignore_index=True)
taggings_file_df.to_json(os.path.join(data_path,taggings_filename),orient="records", force_ascii=False)


# ### Create file: Tags. List of Tags with the number of times they have been used

# In[7]:


tags_file_cols = ['id','name','taggings_count','kind']
tags_file_df = pd.DataFrame(columns=tags_file_cols)
row = [0,'tag',0,'']
tags_file_df = tags_file_df.append(dict(zip(tags_file_cols,row)), ignore_index=True)
tags_file_df.to_json(os.path.join(data_path,tags_filename),orient="records", force_ascii=False)


# ### Create file: List of related proposals

# In[8]:


numb_related_proposals = 2
related_props_cols = ['id']+['related'+str(num) for num in range(1,numb_related_proposals+1)]
related_props_df = pd.DataFrame(columns=related_props_cols)
row = [1]+['' for num in range(1,numb_related_proposals+1)]    
related_props_df = related_props_df.append(dict(zip(related_props_cols,row)), ignore_index=True)
related_props_df.to_json(os.path.join(data_path,related_props_filename),orient="records", force_ascii=False)

