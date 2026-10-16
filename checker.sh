#!/usr/bin/env bash
# checker.sh — проверяет выполнение задания "Наведи порядок на сервере"
# Ничего не модифицирует. Запускать под пользователем-студентом.

ROOT="$HOME/server_cleanup"

# Цвета (если терминал поддерживает)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    GREEN=''; RED=''; YELLOW=''; BLUE=''; BOLD=''; NC=''
fi

PASS=0
FAIL=0
TOTAL=0

# Функция проверки: $1 — описание, $2 — условие (0 = успех), $3 — подсказка (необязательно)
check() {
    TOTAL=$((TOTAL + 1))
    local desc="$1"
    local result="$2"
    local hint="$3"

    if [ "$result" -eq 0 ]; then
        printf "  ${GREEN}✅ %s${NC}\n" "$desc"
        PASS=$((PASS + 1))
    else
        printf "  ${RED}❌ %s${NC}\n" "$desc"
        [ -n "$hint" ] && printf "     ${YELLOW}↳ %s${NC}\n" "$hint"
        FAIL=$((FAIL + 1))
    fi
}

echo
printf "${BOLD}${BLUE}════════════════════════════════════════════════════════${NC}\n"
printf "${BOLD}${BLUE}   ПРОВЕРКА ЗАДАНИЯ «НАВЕДИ ПОРЯДОК НА СЕРВЕРЕ»${NC}\n"
printf "${BOLD}${BLUE}════════════════════════════════════════════════════════${NC}\n"
echo

# --- Проверка существования рабочей папки ---
if [ ! -d "$ROOT" ]; then
    printf "${RED}${BOLD}Ошибка: папка %s не найдена.${NC}\n" "$ROOT"
    printf "Сначала запусти prepare_task.sh\n\n"
    exit 1
fi

cd "$ROOT" || exit 1

# ============================================================
printf "${BOLD}ЧАСТЬ 1–2. Уборка мусора${NC}\n"
# ============================================================

# 1. Нигде не осталось файлов с TEMP
COUNT_TEMP=$(find . -iname '*TEMP*' 2>/dev/null | wc -l)
[ "$COUNT_TEMP" -eq 0 ]
check "Нет ни одного файла или папки с TEMP в имени" $? \
      "Найдено объектов с TEMP: $COUNT_TEMP. Используй: find . -iname '*TEMP*'"

# 2. Каталог logs/old удалён
[ ! -d "logs/old" ]
check "Каталог logs/old удалён" $? \
      "Попробуй: rmdir logs/old   (сначала убедись, что он пуст — ls -la logs/old)"

# ============================================================
printf "\n${BOLD}ЧАСТЬ 3. Порядок в файлах${NC}\n"
# ============================================================

# 3. Папка backups существует
[ -d "backups" ]
check "Папка backups/ создана" $? \
      "Создай: mkdir backups"

# 4. В backups ровно 3 .bak файла
COUNT_BAK=$(ls -1 backups/*.bak 2>/dev/null | wc -l)
[ "$COUNT_BAK" -eq 3 ]
check "В backups/ лежат 3 файла .bak (найдено: $COUNT_BAK)" $? \
      "Перемести все .bak из configs/, data/, notes/ в backups/ через mv"

# 5. Ни одного .bak не осталось вне backups
STRAY_BAK=$(find . -name '*.bak' -not -path './backups/*' 2>/dev/null | wc -l)
[ "$STRAY_BAK" -eq 0 ]
check ".bak файлов вне backups/ не осталось" $? \
      "Найдено лишних .bak: $STRAY_BAK. Проверь configs/, data/, notes/"

# 6. Папка logs/important существует
[ -d "logs/important" ]
check "Папка logs/important/ создана" $? \
      "Создай: mkdir logs/important"

# 7. В logs/important ровно 3 .log
COUNT_IMP=$(ls -1 logs/important/*.log 2>/dev/null | wc -l)
[ "$COUNT_IMP" -eq 3 ]
check "В logs/important/ 3 файла .log (найдено: $COUNT_IMP)" $? \
      "Скопируй big1.log, big2.log, big3.log из logs/ в logs/important/"

# 8. В important НЕ попал small.log
[ ! -f "logs/important/small.log" ]
check "Файл small.log НЕ попал в logs/important/" $? \
      "small.log — маленький, его копировать не нужно. Удали лишний: rm logs/important/small.log"

# ============================================================
printf "\n${BOLD}ЧАСТЬ 4. Структура проекта${NC}\n"
# ============================================================

# 9. Три папки проектов существуют
[ -d "projects/web" ] && [ -d "projects/api" ] && [ -d "projects/docs" ]
check "Существуют projects/web, projects/api, projects/docs" $? \
      "Создай: mkdir -p projects/web projects/api projects/docs"

# 10. README.md в каждой папке
[ -f "projects/web/README.md" ] && \
[ -f "projects/api/README.md" ] && \
[ -f "projects/docs/README.md" ]
check "README.md есть в web, api, docs" $? \
      "Создай: touch projects/web/README.md projects/api/README.md projects/docs/README.md"

# 11. В корне не осталось .txt (кроме summary.txt)
ROOT_TXT=$(find . -maxdepth 1 -name '*.txt' -not -name 'summary.txt' 2>/dev/null | wc -l)
[ "$ROOT_TXT" -eq 0 ]
check "Все .txt из корня перемещены в projects/docs/" $? \
      "В корне осталось .txt (кроме summary.txt): $ROOT_TXT. Используй mv"

# 12. В projects/docs ровно 3 .txt (2 корневых + ничего лишнего)
DOCS_TXT=$(ls -1 projects/docs/*.txt 2>/dev/null | wc -l)
[ "$DOCS_TXT" -eq 2 ]
check "В projects/docs/ лежат 2 .txt файла (найдено: $DOCS_TXT)" $? \
      "Проверь: ls projects/docs/. Должны быть file_root1.txt и file_root2.txt"

# ============================================================
printf "\n${BOLD}ЧАСТЬ 5. Отчёт${NC}\n"
# ============================================================

# 13. summary.txt существует
[ -f "summary.txt" ]
check "Файл summary.txt создан" $? \
      "Создай: echo \"Уборка завершена, файлы с TEMP удалены\" > summary.txt"

# 14. summary.txt не пустой
if [ -f "summary.txt" ] && [ -s "summary.txt" ]; then
    check "summary.txt не пустой" 0
else
    check "summary.txt не пустой" 1 \
          "Файл пустой. Запиши текст: echo \"...\" > summary.txt"
fi

# ============================================================
printf "\n${BOLD}БОНУС (не обязательно, но приятно)${NC}\n"
# ============================================================

# 15. plan.txt в notes/
if [ -f "notes/plan.txt" ]; then
    check "Бонус: notes/plan.txt создан" 0
else
    TOTAL=$((TOTAL - 1))   # не считаем бонус в общий зачёт
    printf "  ${YELLOW}☆ Бонус не выполнен: notes/plan.txt${NC}\n"
fi

# ============================================================
# ИТОГ
# ============================================================
echo
printf "${BOLD}${BLUE}════════════════════════════════════════════════════════${NC}\n"
printf "${BOLD}   ИТОГ: ${GREEN}%d ✅${NC}   ${RED}%d ❌${NC}   (из %d обязательных)\n" \
    "$PASS" "$FAIL" "$TOTAL"
printf "${BOLD}${BLUE}════════════════════════════════════════════════════════${NC}\n"

if [ "$FAIL" -eq 0 ]; then
    printf "\n${GREEN}${BOLD}🎉 Отлично! Задание выполнено полностью.${NC}\n\n"
    exit 0
elif [ "$PASS" -gt $((TOTAL / 2)) ]; then
    printf "\n${YELLOW}${BOLD}⚠️  Больше половины сделано. Есть что доработать.${NC}\n\n"
    exit 2
else
    printf "\n${RED}${BOLD}❌ Пока слабовато. Прочитай подсказки выше и попробуй снова.${NC}\n\n"
    exit 1
fi
