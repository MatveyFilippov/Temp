#!/usr/bin/env bash
# prepare_task.sh — готовит окружение для задания по базовым командам Linux.
# Запускать под пользователем-студентом, НЕ под root.

set -e

ROOT="$HOME/server_cleanup"

echo "==> Готовлю окружение в $ROOT"

# 1. Чистим старое
if [ -d "$ROOT" ]; then
    echo "    Найдена старая папка — удаляю."
    rm -rf "$ROOT"
fi

# 2. Создаём базовую структуру
mkdir -p "$ROOT/logs/old"
mkdir -p "$ROOT/configs"
mkdir -p "$ROOT/data"
mkdir -p "$ROOT/notes"
mkdir -p "$ROOT/tmp"

# 3. Наполняем "мусором"

# --- Файлы с TEMP (удалить) ---
echo "temp data"   > "$ROOT/tmp/TEMP_file1.txt"
echo "another temp"> "$ROOT/TEMP_notes.log"
echo "junk"        > "$ROOT/data/TEMP_old.dump"
echo "more junk"   > "$ROOT/configs/TEMP_config.conf"
echo "deep junk"   > "$ROOT/logs/old/TEMP_archive.log"

# --- Папка с TEMP (удалить через rm -r) ---
mkdir -p "$ROOT/data/TEMP_dir"
echo "inside"      > "$ROOT/data/TEMP_dir/inside.txt"

# --- .bak файлы (переместить в backups/) ---
echo "backup 1"    > "$ROOT/configs/app.conf.bak"
echo "backup 2"    > "$ROOT/data/db.sql.bak"
echo "backup 3"    > "$ROOT/notes/old_notes.txt.bak"

# --- .log файлы (3 больших скопировать, 1 маленький оставить) ---
# маленький (< 1 КБ) — НЕ копировать
echo "small log"   > "$ROOT/logs/small.log"
# три больших — их копировать в logs/important/
head -c 2000 /dev/urandom | base64 > "$ROOT/logs/big1.log"
head -c 5000 /dev/urandom | base64 > "$ROOT/logs/big2.log"
head -c 1500 /dev/urandom | base64 > "$ROOT/logs/big3.log"

# --- .txt файлы в корне (переместить в projects/docs/) ---
echo "root txt 1"  > "$ROOT/file_root1.txt"
echo "root txt 2"  > "$ROOT/file_root2.txt"

# --- Информационный шум ---
echo "important config" > "$ROOT/configs/app.conf"
echo "notes"            > "$ROOT/notes/todo.md"
echo "data sample"      > "$ROOT/data/sample.csv"

# 4. Проверка
echo
echo "==> Готово. Что получилось:"
if command -v tree >/dev/null 2>&1; then
    tree "$ROOT"
else
    ls -R "$ROOT"
fi

echo
echo "Задание можно начинать. Удачи!"
