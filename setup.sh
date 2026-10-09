#!/bin/bash
set -e

mkdir -p ~/incoming
cd ~/incoming

touch index.html style.css app.js README.md
touch logo.png banner.jpg icon.svg
touch notes.txt draft.txt old_backup.zip
touch .hidden_config

mkdir -p backup_2023
touch backup_2023/old_index.html

echo "Готово: ~/incoming создан"
ls -la
