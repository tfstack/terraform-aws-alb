#!/bin/bash

# Package Lambda function
echo "Packaging Lambda function..."

# Create ZIP file
zip -j lambda_function.zip lambda_function.js

echo "Lambda function packaged as lambda_function.zip"
echo "You can now run: terraform init && terraform apply"
