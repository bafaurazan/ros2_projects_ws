#!/bin/bash

echo "🔍 Skanuję katalogi użytkowników w poszukiwaniu VS Code..."

FOUND_PATH=""

# 1. Szukamy w folderach użytkowników
for user_dir in /mnt/c/Users/*; do
    check_path="$user_dir/AppData/Local/Programs/Microsoft VS Code/bin/code"
    if [ -f "$check_path" ]; then
        FOUND_PATH="$check_path"
        break
    fi
done

# 2. Szukamy w Program Files
if [ -z "$FOUND_PATH" ]; then
    sys_path="/mnt/c/Program Files/Microsoft VS Code/bin/code"
    if [ -f "$sys_path" ]; then
        FOUND_PATH="$sys_path"
    fi
fi

# 3. Zapisz wynik
if [ -n "$FOUND_PATH" ]; then
    echo "✅ ZNALEZIONO: $FOUND_PATH"
    
    # Usuń stary alias (jeśli jest)
    sed -i '/alias code=/d' ~/.bashrc
    
    # Usuń starą definicję funkcji code (jeśli jest), aby nie dublować
    # (To proste czyszczenie, usuwa linię z klamrą otwierającą funkcję, jeśli nazwa to code)
    # Dla bezpieczeństwa po prostu dopisujemy nową na końcu - bash weźmie ostatnią.

    cat <<EOF >> ~/.bashrc

# --- VS Code WSL Fix (URI Method) ---
code() {
    # 1. Pobierz argument (lub kropkę jako domyślny)
    TARGET="\${1:-.}"
    
    # 2. Zamień na ścieżkę absolutną (np. /home/rafal/projekt)
    ABS_PATH=\$(readlink -f "\$TARGET")
    
    # 3. Sprawdź czy to plik czy folder
    if [ -d "\$ABS_PATH" ]; then
        # JEŚLI FOLDER: Użyj metody URI (naprawia błąd cli.js)
        distrobox-host-exec "$FOUND_PATH" --folder-uri "vscode-remote://wsl+\${WSL_DISTRO_NAME}\$ABS_PATH"
    else
        # JEŚLI PLIK: Otwórz normalnie (pliki rzadziej powodują błąd cli.js)
        distrobox-host-exec "$FOUND_PATH" --remote "wsl+\${WSL_DISTRO_NAME}" "\$ABS_PATH"
    fi
}
# ------------------------------------
EOF
    
    echo "🎉 Gotowe! Zastosowano metodę URI (naprawa błędu cli.js)."
    echo "🔄 Przeładowuję terminal..."
    exec bash
else
    echo "❌ Nie znaleziono VS Code."
fi