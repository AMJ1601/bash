#!/bin/bash
# Script de monitorización avanzada
# Autor: Antonio Madrid jaén
# Fecha: 14/04/2025
# Descripción: Muestra recursos del sistema en tiempo real
    if [ $UID != 0 ]; then
        echo "[-] Ejecuta el script como root"
        exit 1
    fi
    
    dpkg -l | grep sysstat &>/dev/null
    if [ $? != 0 ]; then
        echo "[?] Para una mejor monitorizacion debemos instalar sysstat ¿quieres proceder? [S/n]"
        read instalar
        if [ -z $instalar ]; then
        echo "[?] Por favor, dime si lo quieres instalar [S/n]"
        read instalar
        elif [ $instalar == S || $instalar == s ]; then
            apt install sysstat -y
        else
            echo "[-] No se instalar el paquete"
        fi
    fi
    dpkg -l | grep cbm &>/dev/null
    if [ $? != 0 ]; then
        echo "[?] Para una mejor monitorizacion debemos instalar sysstat ¿quieres proceder? [S/n]"
        read instalar
        if [ -z $instalar ]; then
        echo "[?] Por favor, dime si lo quieres instalar [S/n]"
        read instalar
        elif [ $instalar == S || $instalar == s ]; then
            apt install sysstat -y
        else
            echo "[-] No se instalar el paquete"
        fi
    fi

    
    # Calcular memoria uso de la RAM
    mem_usada=$(free | awk '{print $3}' | tail -2 | head -1)
    mem_total=$(free | awk '{print $2}' | tail -2 | head -1)
    mem_porcentaje=$(( $mem_usada * 100 / $mem_total ))
    if [ $mem_porcentaje -ge 90 ]; then 
        mem_porcentaje="\e[31m$mem_porcentaje%\e[0m"
    else 
        mem_porcentaje="$mem_porcentaje%"
    fi

    # Calcular uso del procesador
    uso_desocupado=$(top -bn1 | grep Cpu | awk '{print $8}' | cut -d "." -f 1)
    if [[ ! $uso_desocupado =~ ^([1-9]|[1-9][0-9])$ ]]; then
        uso_desocupado=100
    fi
    uso_real=$(( 100 - uso_desocupado ))
    if [ $uso_real -ge 90 ]; then 
        uso_real="\e[31m$uso_real%\e[0m"
    else 
        uso_real="$uso_real%"
    fi

    # Espacio libre en el disco
    espacio_total=$(df -h | grep C: | awk '{print $2}')
    espacio_total2=${espacio_total: 0: -1}
    espacio_usado=$(df -h | grep C: | awk '{print $3}')
    espacio_usado2=${espacio_usado: 0: -1}
    espacio_porcentaje=$(( $espacio_usado2 * 100 / $espacio_total2 ))
    uso_disco=$(df -h | grep C: | awk '{print $5}')
    clear
    echo -e "\e[36m$(date)\nTiempo encendido:\e[0m $(uptime -p)\n" >> /var/log/recursos.log
    echo -e "RAM \tCPU\n$mem_porcentaje\t$uso_real" >> /var/log/recursos.log
    echo -e "\n\e[34mProceso con mas memoria\n\e[0m$(ps aux --sort=-%mem | head -2; for user in $(w -h | awk '{print $1}' | sort -u); do ps aux --sort=-%mem | awk -v u=$user '$1 == u {print; exit}'; done)" >> /var/log/recursos.log
    echo -e "\n\e[34mProceso con mas uso del procesador\n\e[0m$(ps aux --sort=-%cpu | head -2; for user in $(w -h | awk '{print $1}' | sort -u); do ps aux --sort=-%cpu | awk -v u=$user '$1 == u {print; exit}'; done)" >> /var/log/recursos.log
    echo -e "\n\e[34mEspacio libre en discos\e[0m\n$(df -h | head -1)\n$(df -h | grep /dev/sd)" >> /var/log/recursos.log
    echo -e "\n\e[34mDiscos\e[0m\n$(iostat | tail -6 | head -4)" >> /var/log/recursos.log
    echo -e "\n\e[34mServicios activos\e[0m\n$(systemctl list-units --type=service --state=running)" >> /var/log/recursos.log
    echo -e "\n\e[34mRed\n\e[0m" >> /var/log/recursos.log
    for i in $(ip -br link show | awk '$2 == "UP" {print}' | wc -l); do 
        interfaz=$(ip -br link show | awk '$2 == "UP" {print $1; exit}'|head -$i | tail -1 )
        bajada=$(cat /proc/net/dev | grep $interfaz | awk '{print $2}')
        bajada=$((bajada / 1024))
        subida=$(cat /proc/net/dev | grep $interfaz | awk '{print $10}')
        subida=$((subida / 1024))
        echo -e "\e[34m$interfaz:\e[0m ↓ $bajada KB | ↑ $subida KB" >> /var/log/recursos.log
    done 