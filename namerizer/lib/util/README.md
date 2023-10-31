# Util

This folder is intended for all code that is not platform specific 
(such as firebase) and can be used for both android and web

# CloudStorage Class

WRITE HERE

# Firebase

The root contains:
- collection **storage**
- collection **profiles**

**storage** contains professors, by UID.

**storage/\<professorUID\>/** contains a collection of **classes**, by class code

**storage/\<professorUID\>/classes/\<classCode\>/** contains:
- String **class_name** -> name of that class
- collection **students**

**storage/\<professorUID\>/\<classCode\>/students/** contains