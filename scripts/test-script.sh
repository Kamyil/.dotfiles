#!/usr/bin/env bash

echo "Testing basic script execution..."
echo "If you see this, the script works fine."

read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "User cancelled"
    exit 1
fi

echo "Script completed successfully"