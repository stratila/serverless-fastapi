#!/bin/bash

set -e

# Step 1: Install venv
python3.10 -m venv venv

# Step 2: Activate the virtual environment
source venv/bin/activate

# Step 3: Install requirements.txt
pip install -r requirements.txt

# Step 4: Change working directory to venv/lib/python3.10/site-packages
cd venv/lib/python3.10/site-packages

# Step 5: Archive site-packages content to zip archive
zip -r9 ../../../../function.zip ./

# Step 6: Change working directory to project root
cd ../../../../

# Step 7: Archive project files to zip archive
zip -g function.zip -r app

# Step 8: Echo done
echo "Archivating done!"

# Step 9: Deactivate the virtual environment
deactivate

# Step 10: Change working directory to infra
cd infra


# Step 11: Terraform plan
terraform plan

# Step 13: Terraform apply
terraform apply 



