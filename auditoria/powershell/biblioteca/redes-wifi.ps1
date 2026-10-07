<#
.NOME Perfis de Wi-Fi salvos
.CATEGORIA Rede
.DESCRICAO Lista as redes Wi-Fi salvas no computador e o tipo de autenticação de cada uma.
.PERIGOSO Nao
#>
$perfis = (Executar netsh.exe 'wlan show profiles') | Select-String ':\s(.+)$' | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() }
foreach ($p in $perfis) {
    $d = Executar netsh.exe "wlan show profile name=`"$p`""
    $auth = ($d | Select-String '(Autentica\S+|Authentication)\s*:\s*(.+)$' | Select-Object -First 1).Matches.Groups[2].Value
    [pscustomobject]@{ Rede = $p; Autenticacao = $auth }
}
