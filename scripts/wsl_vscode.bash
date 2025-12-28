#!/bin/bash

echo "🔍 Skanuję katalogi użytkowników w poszukiwaniu VS Code..."

FOUND_PATH=""

# 1. Lista katalogów, w których szukamy (Users, Program Files)
# Szukamy najpierw w folderach użytkowników
for user_dir in /mnt/c/Users/*; do
    # Tworzymy pełną ścieżkę (dbając o spacje)
    check_path="$user_dir/AppData/Local/Programs/Microsoft VS Code/bin/code"
    
    if [ -f "$check_path" ]; then
        FOUND_PATH="$check_path"
        break
    fi
done

# 2. Jeśli nie znaleziono u użytkownika, sprawdź Program Files
if [ -z "$FOUND_PATH" ]; then
    sys_path="/mnt/c/Program Files/Microsoft VS Code/bin/code"
    if [ -f "$sys_path" ]; then
        FOUND_PATH="$sys_path"
    fi
fi

# 3. Zapisz wynik
if [ -n "$FOUND_PATH" ]; then
    echo "✅ ZNALEZIONO: $FOUND_PATH"
    
    # Usuń stary alias
    sed -i '/alias code=/d' ~/.bashrc
    
    # Dodaj nowy alias (z bezpiecznym cytowaniem ścieżki)
    echo "alias code=\"distrobox-host-exec '$FOUND_PATH'\"" >> ~/.bashrc
    
    echo "🎉 Gotowe! Alias zapisany w .bashrc"
    echo "🔄 Przeładowuję terminal, aby zmiany weszły w życie..."
    source ~/.bashrc
else
    echo "❌ Nadal nie udało się znaleźć pliku automatycznie."
    echo "Twoja instalacja może być niestandardowa."
fi