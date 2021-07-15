#!/usr/bin/env python
# coding: utf-8

# In[1]:


"""
Proposals comments summaries - Dummy script

"""


# In[2]:


data_path = '../data'
config_file = 'proposals_summary_comments_textrank.ini'
logging_file ='proposals_summary_comments_textrank.log'


# In[3]:


# Input file:
inputjsonfile = 'comments.json'

# Output files:
comments_summaries_filename = 'ml_comments_summaries_proposals.json'


# In[4]:


import os
import pandas as pd


# ### Read the comments

# In[5]:


# comments_input_df = pd.read_json(os.path.join(data_path,inputjsonfile),orient="records")
# col_id = 'commentable_id'
# col_content = 'body'
# comments_input_df = comments_input_df[[col_id]+[col_content]]


# ### Create file. Comments summaries

# In[6]:


comments_summaries_cols = ['id','commentable_id','commentable_type','body']
comments_summaries_df = pd.DataFrame(columns=comments_summaries_cols)
row = [0,0,'Proposal','Summary']        
comments_summaries_df = comments_summaries_df.append(dict(zip(comments_summaries_cols,row)), ignore_index=True)
comments_summaries_df.to_json(os.path.join(data_path,comments_summaries_filename),orient="records", force_ascii=False)

