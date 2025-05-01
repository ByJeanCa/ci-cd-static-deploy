#!/bin/bash

required_files=("index.html" "styles.css")
found_files=0


for required in "${required_files[@]}"; do
    if [[ -f static-files/$required ]]; then
        found_files=$((found_files + 1))
    fi
done

if [[ $found_files -eq ${#required_files[@]} ]]; then
    echo "The necessary files exist"
else
    echo "The required files do not exists"
    exit 1
fi
    

