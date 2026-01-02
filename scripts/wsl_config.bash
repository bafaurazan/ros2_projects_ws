#!/bin/bash

echo "🔄 Rozpoczynam automatyczną konfigurację SWAP dla WSL..."

WIN_HOME=""

# 1. Znajdź katalog użytkownika (bezpieczna metoda)
for dir in /mnt/c/Users/*; do
    dirname=$(basename "$dir")
    if [[ "$dirname" == "Public" || "$dirname" == "Default" || "$dirname" == "Default User" || "$dirname" == "All Users" || "$dirname" == "desktop.ini" ]]; then
        continue
    fi
    if [ -d "$dir" ] && [ -w "$dir" ]; then
        WIN_HOME="$dir"
        echo "🏠 Wykryto katalog użytkownika: $dirname"
        break
    fi
done

if [ -z "$WIN_HOME" ]; then
    echo "❌ Nie znaleziono katalogu użytkownika."
    exit 1
fi

WSL_CONFIG_PATH="$WIN_HOME/.wslconfig"

# 2. Kopia zapasowa
if [ -f "$WSL_CONFIG_PATH" ]; then
    cp "$WSL_CONFIG_PATH" "$WSL_CONFIG_PATH.backup_$(date +%s)"
fi

# 3. Zapis konfiguracji
cat <<EOF > "$WSL_CONFIG_PATH"
[wsl2]
swap=17GB
networkingMode=mirrored
EOF

echo "✅ Sukces! Ustawiono SWAP."
echo ""
echo "⚠️  UWAGA: ZMIANY WEJDĄ W ŻYCIE DOPIERO PO RESTARCIE WSL."
echo "--------------------------------------------------------"
echo "Aby dokończyć, wykonaj te 2 kroki:"
echo "1. Zamknij ten terminal."
echo "2. Otwórz PowerShell w Windowsie i wpisz: wsl --shutdown"
echo "--------------------------------------------------------"