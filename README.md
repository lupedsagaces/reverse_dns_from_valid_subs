# 🔍 reverse_dns_from_valid_subs.sh 

É um script em **Bash** para automatizar a resolução de subdomínios válidos em IPs e realizar **pesquisa reversa de DNS (PTR)** com base no bloco de IPs descoberto via `whois`.

Ideal para tarefas de _footprinting_, _bug bounty_ e descoberta de domínios não mapeados por listas comuns.

---

## 🧠 Como Funciona

1. Lê um arquivo com subdomínios válidos.
2. Resolve os subdomínios para obter os IPs.
3. Executa `whois` em cada IP para identificar o bloco de endereçamento (`inetnum` ou `NetRange`).
4. Varre esse range e executa consultas PTR (`host -t ptr`) para encontrar possíveis domínios associados.

---

## 📁 Estrutura de Saída

Cria o diretório `resultado_dns/` contendo:

- `ips_unicos.txt`: lista de IPs únicos dos subdomínios resolvidos.
- `reverse_dns.txt`: registros PTR encontrados dentro dos blocos de IPs.

---

## ⚙️ Requisitos

Certifique-se de ter os seguintes utilitários instalados:

- `bash`
- `host` (geralmente disponível via `dnsutils` ou `bind-utils`)
- `whois`
- `awk`, `grep`, `cut`, `sort`, `seq`

### Debian/Ubuntu

```bash
sudo apt install dnsutils whois
```

## 🚀 Uso
```bash
chmod +x reverse_dns_from_valid_subs.sh
./reverse_dns_from_valid_subs.sh <arquivo_subdominios_validos>
```

## 📄 Exemplo de Entrada do arquivo subdominios_validos.txt

```
mail.exemplo.com
painel.exemplo.com
api.exemplo.com
```

## 🤝 Contribuições
Contribuições são bem-vindas! Abra uma issue ou envie um pull request com melhorias, sugestões ou correções.

Made with 💚 by lupedsagaces


