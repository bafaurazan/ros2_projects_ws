#!/usr/bin/env python3
import os
import shutil
import json
import glob
import sys
import time

# --- Funkcje pomocnicze ---

def log(message):
    """Wypisuje wiadomość z czasem, żebyś widział postęp."""
    print(f"[{time.strftime('%H:%M:%S')}] {message}")

def copy_if_updated(from_dir: str, to_dir: str):
    """
    Kopiuje pliki tylko jeśli są nowsze.
    Zawiera zabezpieczenia przed błędami i logowanie dla dużych operacji.
    """
    if not from_dir or not to_dir:
        return
    
    if not os.path.exists(from_dir):
        # log(f"Pominięto: źródło nie istnieje -> {from_dir}")
        return

    # Ostrzeżenie przy dużych katalogach
    is_heavy = "/usr/include" in from_dir
    if is_heavy:
        log(f"Synchronizacja dużego katalogu: {from_dir} -> {to_dir} (To może chwilę potrwać...)")

    try:
        if os.path.isdir(from_dir):
            if not os.path.exists(to_dir):
                os.makedirs(to_dir, exist_ok=True)
                
            # Jeśli docelowy folder jest pusty, użyj szybkiego copytree
            if not os.listdir(to_dir):
                shutil.copytree(from_dir, to_dir, dirs_exist_ok=True)
            else:
                # Rekurencyjne sprawdzanie dat (wolniejsze, ale dokładne)
                from_mtime = os.path.getmtime(from_dir)
                to_mtime = os.path.getmtime(to_dir)
                
                # Prosta heurystyka: jeśli folder źródłowy jest nowszy, wchodzimy głębiej
                # (Dla bezpieczeństwa sprawdzamy zawartość)
                for item in os.listdir(from_dir):
                    item_from = os.path.join(from_dir, item)
                    item_to = os.path.join(to_dir, item)
                    
                    if os.path.isdir(item_from):
                        copy_if_updated(item_from, item_to)
                    elif os.path.isfile(item_from):
                        if not os.path.exists(item_to) or os.path.getmtime(item_from) > os.path.getmtime(item_to):
                            shutil.copy2(item_from, item_to)
                            
    except PermissionError:
        log(f"Brak uprawnień do pliku w: {from_dir} - pomijam.")
    except Exception as e:
        log(f"Błąd podczas kopiowania {from_dir}: {e}")

    if is_heavy:
        log(f"Zakończono synchronizację: {from_dir}")

def elem(arr, index, default=None):
    if index < len(arr):
        return arr[index]
    return default

# --- Główna konfiguracja ---

# Ustalanie ścieżki do workspace (zakładamy, że skrypt jest w folderze wewnątrz workspace)
# Idziemy dwa piętra w górę (np. z ros2_ws/scripts/config.py -> ros2_ws)
current_dir = os.path.dirname(os.path.abspath(__file__))
# Jeśli skrypt leży bezpośrednio w workspace, zmień '..' na '.'
ws_dir = os.path.abspath(os.path.join(current_dir, "..")) 

log(f"Workspace directory: {ws_dir}")

config_path = os.path.join(ws_dir, ".vscode/settings.json")
compile_commands_path = os.path.join(ws_dir, "build/compile_commands.json")

# Ścieżki docelowe na hoście (w katalogu domowym użytkownika)
home_dir = os.path.expanduser("~")
site_dir = os.path.join(home_dir, ".vscode-paths/ros2-site-packages")
dist_dir = os.path.join(home_dir, ".vscode-paths/ros2-dist-packages")
include_dir = os.path.join(home_dir, ".vscode-paths/ros2-include")
usr_include_dir = os.path.join(home_dir, ".vscode-paths/usr-include")
usr_lib_python_dirs = []

# Sprawdzenie czy jesteśmy w Distrobox
running_distrobox = "DISTROBOX_HOST_HOME" in os.environ or os.path.exists("/run/host/etc/os-release")

if running_distrobox:
    log("Wykryto środowisko Distrobox/Kontener.")
    
    # Kopiowanie bibliotek Pythona ROS
    log("Kopiowanie site-packages ROSa...")
    copy_if_updated(elem(glob.glob("/opt/ros/*/lib/python*/site-packages"), 0), site_dir)
    copy_if_updated(elem(glob.glob("/opt/ros/*/local/lib/python*/dist-packages"), 0), dist_dir)
    
    # Kopiowanie nagłówków C++
    log("Kopiowanie nagłówków ROSa...")
    copy_if_updated(elem(glob.glob("/opt/ros/*/include"), 0), include_dir)
    
    # Kopiowanie systemowych nagłówków (/usr/include) - to trwa najdłużej
    copy_if_updated("/usr/include", usr_include_dir)

    # Kopiowanie systemowych pakietów Pythona
    log("Kopiowanie bibliotek systemowych Pythona...")
    for python_dir in glob.glob("/usr/lib/python*/dist-packages"):
        python_name = os.path.basename(os.path.dirname(python_dir))
        usr_python_dir = os.path.join(home_dir, f".vscode-paths/usr-lib-{python_name}-dist-packages")
        copy_if_updated(python_dir, usr_python_dir)
        usr_lib_python_dirs.append(usr_python_dir)
        
    for python_dir in glob.glob("/usr/local/lib/python*/dist-packages"):
        python_name = os.path.basename(os.path.dirname(python_dir))
        usr_python_dir = os.path.join(home_dir, f".vscode-paths/usr-local-lib-{python_name}-dist-packages")
        copy_if_updated(python_dir, usr_python_dir)
        usr_lib_python_dirs.append(usr_python_dir)
else:
    log("Uruchomiono na hoście (Native Ubuntu).")

# --- Generowanie settings.json ---

log("Generowanie pliku konfiguracyjnego VS Code...")

if os.path.isfile(config_path):
    try:
        with open(config_path) as f:
            config = json.load(f)
    except json.JSONDecodeError:
        config = {}
else:
    config = {}

# Konfiguracja terminala
distrobox_script_path = os.path.join(ws_dir, "scripts/distrobox")

if running_distrobox:
    # Sprawdź czy skrypt startowy istnieje, żeby nie zepsuć terminala
    if os.path.isfile(distrobox_script_path):
        config["terminal.integrated.profiles.linux"] = {
            "kalman_ws": {"path": distrobox_script_path}
        }
        config["terminal.integrated.defaultProfile.linux"] = "kalman_ws"
    else:
        log(f"UWAGA: Nie znaleziono skryptu {distrobox_script_path}. Terminal VS Code pozostanie domyślny.")
else:
    bashrc_path = os.path.join(ws_dir, "scripts/native-ubuntu.bashrc")
    if os.path.isfile(bashrc_path):
        config["terminal.integrated.profiles.linux"] = {
            "kalman_ws": {
                "path": f"/usr/bin/bash",
                "args": ["--rcfile", bashrc_path]
            }
        }
        config["terminal.integrated.defaultProfile.linux"] = "kalman_ws"

# Ścieżki autocomplete
if running_distrobox:
    config["python.autoComplete.extraPaths"] = [site_dir, dist_dir] + usr_lib_python_dirs
    config["C_Cpp.default.includePath"] = [include_dir + "/**", usr_include_dir + "/**"]
else:
    config["python.autoComplete.extraPaths"] = []
    config["C_Cpp.default.includePath"] = []

# Dodawanie zainstalowanych pakietów z workspace (install/)
install_dir = os.path.join(ws_dir, "install")
if os.path.isdir(install_dir):
    for item in os.listdir(install_dir):
        item_dir = os.path.join(install_dir, item)
        if os.path.isdir(item_dir):
            # Python paths
            for sp in glob.glob(os.path.join(item_dir, "lib", "python*", "site-packages")) + \
                      glob.glob(os.path.join(item_dir, "local", "lib", "python*", "dist-packages")):
                if sp not in config["python.autoComplete.extraPaths"]:
                    config["python.autoComplete.extraPaths"].append(sp)
            
            # C++ paths
            for inc in glob.glob(os.path.join(item_dir, "include")):
                inc_path = inc + "/**"
                if inc_path not in config["C_Cpp.default.includePath"]:
                    config["C_Cpp.default.includePath"].append(inc_path)

# Dodatkowe ścieżki hosta (gdy działamy w Distrobox)
if running_distrobox:
    host_local_lib = os.path.expanduser("~/.local/lib/python*/")
    for sp in glob.glob(os.path.join(host_local_lib, "site-packages")) + \
              glob.glob(os.path.join(host_local_lib, "dist-packages")):
        if sp not in config["python.autoComplete.extraPaths"]:
            config["python.autoComplete.extraPaths"].append(sp)

    # --- Aktualizacja compile_commands.json ---
    if os.path.isfile(compile_commands_path):
        log("Aktualizacja compile_commands.json...")
        try:
            with open(compile_commands_path, "r", encoding="UTF-8") as f:
                compile_commands = f.read()
            
            # Zamiana ścieżek
            for ros_include_dir in glob.glob("/opt/ros/*/include"):
                compile_commands = compile_commands.replace(ros_include_dir, include_dir)
            
            compile_commands = compile_commands.replace(f"-I{include_dir}", f"-isystem {include_dir}")
            compile_commands = compile_commands.replace("/usr/include", usr_include_dir)
            
            extra_includes = f"-isystem {usr_include_dir} -isystem {os.path.join(usr_include_dir, 'x86_64-linux-gnu')}"
            
            if extra_includes not in compile_commands:
                # Dodajemy flagi tylko raz
                compile_commands = compile_commands.replace("-O", f"{extra_includes} -O")

            with open(compile_commands_path, "w", encoding="UTF-8") as f:
                f.write(compile_commands)
        except Exception as e:
            log(f"Błąd przy edycji compile_commands.json: {e}")

# Sortowanie i zapisywanie
if "python.autoComplete.extraPaths" in config:
    config["python.autoComplete.extraPaths"] = sorted(list(set(config["python.autoComplete.extraPaths"])))
    config["python.analysis.extraPaths"] = config["python.autoComplete.extraPaths"]

if "files.associations" not in config:
    config["files.associations"] = {}
config["files.associations"]["*.yaml.j2"] = "yaml"

os.makedirs(os.path.dirname(config_path), exist_ok=True)
with open(config_path, "w") as f:
    json.dump(config, f, indent=4)

log(f"ZAPISANO KONFIGURACJĘ: {config_path}")
log("Gotowe. Teraz możesz uruchomić 'distrobox-host-exec code .'")