#!/bin/bash

if [ $UID != 0 ]; then
	echo "Ejecuta el script como root"
	exit 1
fi

if [ -z $1 ]; then
	echo "Por favor dime que permisos quieres quitar (w/x/r)"
	exit 0
fi

echo -e "[!] Este script busca permisos de escritura para otros y/o elimina este permiso en la carpeta que me digas\n"

while true; do
	echo -e "[!] Este script queda bajo tu propia responsabilidad\n\n\t¿Quieres continuar? [Y/n]"
	read confirmacion
	if [[ "$confirmacion" =~ ^[Yy]$ ]]; then
		echo "[+] Continuando..."
		break
	elif [[ "$confirmacion" =~ ^[Nn]$ ]]; then
		echo "[-] Saliendo..."
		exit 0
	else
		echo -e "\n[?] No has escrito el caracter correcto\n"

	fi
done

read -p "[?] ¿Que carpeta quieres comprobar los permisos? " ruta

otros=$(find $ruta -perm -o+${1} 2>/dev/null) 

if [ -z $otros ]; then
	echo "No hay ningun archivo ni carpeta"
	exit 0
fi

echo -e "\n$otros"

read -p "[?] ¿Quieres quitarle los permisos a estas rutas? [Y/n] " confirmacion

while true; do
	if [[ $confirmacion =~ ^[Yy]$ ]]; then
		echo $otros | xargs chmod o-${1}
		echo -e "[+] Hemos terminado :)"
		exit 0
	elif [[ $confirmacion =~ ^[Nn]$ ]]; then
		echo "saliendo..."
		exit 0
	else
		echo "[?] No entiendo lo que quieres decir"
	fi
done

echo "Hemos terminado"
