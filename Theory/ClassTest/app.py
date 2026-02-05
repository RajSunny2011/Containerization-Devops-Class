# Simple program to verify SAP ID
# This program is intentionally basic
# Focus of this task is containerization, not Python

import numpy as np  # dependency for learning purpose

stored_sapid = "500119624"
while (True):
    user_sapid = input("Enter your SAP ID: ")
    if user_sapid == stored_sapid:
        print("Matched")
    else:
        print("Not Matched")
