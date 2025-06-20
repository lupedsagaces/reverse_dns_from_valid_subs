#!/bin/bash

# Verificação de uso
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <arquivo_subdominios_validos>"
    exit 1
fi

ARQUIVO_SUBDOMINIOS_VALIDOS="$1"
DIRETORIO_SAIDA="resultado_dns"
ARQUIVO_IPS_UNICOS="$DIRETORIO_SAIDA/ips_unicos.txt"
ARQUIVO_REVERSE_DNS="$DIRETORIO_SAIDA/reverse_dns.txt"

mkdir -p "$DIRETORIO_SAIDA"
> "$ARQUIVO_IPS_UNICOS"
> "$ARQUIVO_REVERSE_DNS"

echo "[+] Resolvendo IPs dos subdomínios válidos..."
while read -r sub; do
    ip=$(host "$sub" | awk '/has address/ {print $4}')
    if [ -n "$ip" ]; then
        echo "$ip" >> "$ARQUIVO_IPS_UNICOS"
    fi
done < "$ARQUIVO_SUBDOMINIOS_VALIDOS"

sort -u "$ARQUIVO_IPS_UNICOS" -o "$ARQUIVO_IPS_UNICOS"

echo "[+] Iniciando pesquisa reversa nos blocos IP..."

while read -r ip; do
    echo "    - IP: $ip"
    
    whois_info=$(whois "$ip")
    range=$(echo "$whois_info" | grep -iE 'inetnum|NetRange' | head -n1)

    if echo "$range" | grep -qE '([0-9]+\.){3}[0-9]+'; then
        ip_start=$(echo "$range" | grep -oE '([0-9]+\.){3}[0-9]+' | head -n1)
        ip_end=$(echo "$range" | grep -oE '([0-9]+\.){3}[0-9]+' | tail -n1)

        prefix=$(echo "$ip_start" | cut -d. -f1-3)
        start=$(echo "$ip_start" | cut -d. -f4)
        end=$(echo "$ip_end" | cut -d. -f4)

        echo "    > Range: $prefix.$start até $prefix.$end"

        for i in $(seq "$start" "$end"); do
            resultado=$(host -t ptr "$prefix.$i" 2>/dev/null | grep -v "not found")
            if [ -n "$resultado" ] && ! echo "$resultado" | grep -q "$prefix-$i"; then
                echo "$resultado" | tee -a "$ARQUIVO_REVERSE_DNS"
            fi
        done
    else
        echo "    [!] Range não identificado para $ip"
    fi

done < "$ARQUIVO_IPS_UNICOS"

echo "[✓] Finalizado. Resultados em:"
echo "    → IPs únicos:        $ARQUIVO_IPS_UNICOS"
echo "    → Pesquisa reversa:  $ARQUIVO_REVERSE_DNS"
