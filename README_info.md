# ros2_ws

```cmd
winget install usbipd # zainstaluj na windowsie

usbipd list

# wybierz kamere lub sensor/urządzenie na usb i jego numer id (np. 1-4)
usbipd bind --busid 1-4
usbipd attach --wsl --busid 1-4

# i teraz na windows wsl zadziała cała komenda więc można wywoływać skrypt
 ./scripts/distrobox # rm -rf .distrobox  jeśli tamta zawiedzie to trza usuwać wszystko

# teraz trzeba odmontować
usbipd detach --busid 1-4

#i działa na hoscie
```
