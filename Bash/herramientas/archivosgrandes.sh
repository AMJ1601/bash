#!/bin/bash

if [ $UID != 0 ]; then
	echo "Debes ejecutar el script como root"
fi

echo -e "[?] Este script localiza archivos del tamaño que definas\n"
echo -e "[!] Para introducir el tamaño de archivo debes indicarlo de la siguiente manera (+100c) 'archivos mas grandes de 100 bytes'\nLa c para bytes\nLa K para Kilobytes\nLa M para MegaBytes\nLa G para GigaBytes\n"

while true; do
	read -p "[?] Dime la ruta donde quieres buscar: " ruta
	read -p "[?] Dime de que tamaño quieres buscarlo: " tamano
	if [[ $tamaño && $ruta ]]; then
		break
	fi
done

output=$(find $ruta -size $tamano -type f)
echo -e "\n$output"

while true; do
	read -p "[?] Quieres eliminar estos archivos [Y/n]: " confirmacion
	if [[ $confirmacion =~ ^[Yy]$ ]]; then
		echo "$output" | xargs rm
		break
	elif [[ $confirmacion =~ ^[Nn]$ ]]; then
		echo "[-] No se borraran"
		break
	else
		echo "[!] No has confirmado correctamente"
	fi
done

echo "[+] Hemos terminado"
