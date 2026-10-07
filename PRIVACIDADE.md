# Privacidade e Transparência

**CoreAxis Tech Toolbox** · Declaração institucional · Versão 1.1.1 · Outubro de 2026

A CoreAxis Tech desenvolveu o CoreAxis Tech Toolbox para ser uma ferramenta em que técnicos e seus clientes possam confiar. Por isso, assumimos publicamente os compromissos abaixo.

## 1. O software não coleta informações pessoais

O programa **não possui telemetria, analytics, rastreamento, identificadores de publicidade ou cadastro online**. A CoreAxis Tech não recebe nenhuma informação sobre quem usa o programa, onde ou como.

Os dados que você cadastra — clientes, equipamentos, chamados, manutenções e inventários — são armazenados **exclusivamente no seu dispositivo**, dentro de um cofre criptografado com **AES-256-GCM**. Somente quem possui uma senha válida (ou a chave de recuperação) consegue abri-lo. **Nem a CoreAxis Tech tem acesso.**

## 2. O software não envia dados para terceiros

Nenhum dado cadastrado, inventário, relatório ou informação do computador é transmitido pelo programa. As únicas conexões que o programa faz são as listadas abaixo — todas acionadas por você, exceto a verificação de atualizações ao iniciar, que pode ser desativada:

| Função | Destino | O que trafega |
|---|---|---|
| Teste de internet | `speed.cloudflare.com` (velocidade), `www.google.com/generate_204` (HTTPS), `api.ipify.org` (IP público) | Tráfego de teste; nenhum dado seu |
| Ping, traceroute, DNS, scanner | Os endereços que **você** digitar / a sua rede local | Pacotes de diagnóstico |
| Teste de DNS | Servidores DNS públicos (Google, Cloudflare, Quad9, OpenDNS) | Consultas de nomes de domínio públicos |
| Verificar atualizações | GitHub (`github.com`) ou o endereço configurado | Ao iniciar (somente administradores; desativável em *Configurações → Atualizações*) ou ao clicar em "Verificar agora": download do manifesto público. O executável só é baixado se você confirmar. Nenhuma informação sua é enviada |
| Windows Update / Defender | Serviços da Microsoft, pelo próprio Windows | Operações do Windows |

A ativação de licença é **offline**: o código do dispositivo é calculado localmente e só é enviado à CoreAxis Tech se **você** decidir enviá-lo para comprar ou renovar uma licença. Esse código é um resumo criptográfico (hash) e não contém o número de série em texto.

## 3. Pode ser validado por hash SHA-256

Cada versão publicada tem seu hash **SHA-256** oficial divulgado em [`SHA256.txt`](SHA256.txt), na página da release e no site. Qualquer pessoa pode conferir:

```powershell
Get-FileHash .\CoreAxisTechToolbox-1.1.1-portable.exe -Algorithm SHA256
```

Se o valor não for idêntico ao oficial, **não execute o arquivo**. Um processo automatizado no GitHub confere periodicamente os hashes das releases publicadas.

## 4. É distribuído pelo GitHub

O único canal oficial de distribuição é:
**https://github.com/georgeangra/coreaxis-tech-toolbox/releases**

O site oficial (**https://georgeangra.github.io/coreaxis-tech-toolbox/**) sempre aponta para esse endereço. Desconfie de cópias em outros sites, anexos de e-mail ou links encurtados.

## 5. Possui código auditável sempre que aplicável

O núcleo do aplicativo é proprietário (protege o licenciamento comercial). A parte que **executa ações no seu sistema com privilégios de administrador** — os scripts PowerShell — é publicada integralmente em [`auditoria/`](auditoria/), junto com o manifesto de hashes de cada versão. O próprio programa confere esses hashes antes de executar qualquer script, garantindo que o que roda é exatamente o que está publicado.

## 6. Seus direitos (LGPD)

Como os dados ficam apenas no seu dispositivo, **você é o controlador** dos dados pessoais de seus clientes, nos termos da Lei nº 13.709/2018. O programa oferece recursos que apoiam suas obrigações: criptografia, controle de acesso por usuário, trilha de auditoria, exportação e exclusão de registros.

## 7. Contato

Dúvidas sobre privacidade: [site oficial — contato](https://georgeangra.github.io/coreaxis-tech-toolbox/contato.html)
Relatos de segurança: [SECURITY.md](SECURITY.md)

---
CoreAxis Tech · Desenvolvedor: George
