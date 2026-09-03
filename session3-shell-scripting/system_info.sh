#!/bin/bash

# System Information Script — Shell Scripting homework
# Uses variables, read -p, mkdir, touch, echo, df, ps, and > redirection.

current_date=$(date)
host_name=$(hostname)
user_name=$(whoami)
disk_usage=$(df -h)

echo "===== System Information ====="
echo "Date:       $current_date"
echo "Hostname:   $host_name"
echo "Username:   $user_name"
echo ""

echo "===== Disk Usage ====="
echo "$disk_usage"
echo ""

echo "===== Running Processes ====="
ps
echo ""

read -p "Enter your name: " name
read -p "Enter a directory name to create: " dir_name
read -p "Enter a file name to store process info: " file_name

if [ -z "$dir_name" ]; then
  dir_name="sysinfo_output"
fi

if [ -z "$file_name" ]; then
  file_name="process.log"
fi

mkdir -p "$dir_name"
touch "$dir_name/$file_name"

# store running process information in the file using > redirection
ps > "$dir_name/$file_name"

echo ""
echo "Hello, $name."
echo "Created directory: $dir_name"
echo "Created file:      $dir_name/$file_name"
echo "Running processes were written to $dir_name/$file_name"
echo ""
echo "===== File contents ($dir_name/$file_name) ====="
cat "$dir_name/$file_name"
