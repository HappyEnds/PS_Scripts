
##Вводимые данные
$ScopeName = Read-host 'Как назовём scope?'
$Mask = Read-host 'Сетку в формате 192.168.0.0\24 пожалуйста'
$excludeIP = Read-host 'Сколько адресов исключить'
$Descript = Read-host 'Какому VLAN отдаём скоп? соблюдаем формат 000!'
$dhcpServers = Get-DhcpServerInDC | select dnsname
if ([int]$dhcpServers.Count -eq '0') {
$iCount = [int]$dhcpServers.Count + 1
}
else {
$iCount = [int]$dhcpServers.Count -1
}
$ID = 0
foreach ($dhcpServer in $dhcpServers){
$dhcp = @{Name = $dhcpServer.dnsname; ServerID = $ID}
$dhcp
$ID++
 }
$dhcpServerID = Read-host 'Server ID одного из предложенных серверов пожалуйста'
##Получаем опцию dns и определяем есть ли failover сервер
$dns = Get-DhcpServerv4OptionValue -ComputerName $dhcpServers[$dhcpServerID].dnsname -OptionId 6
$Failover = Get-DhcpServerv4Failover -ComputerName $dhcpServers[$dhcpServerID].dnsname -ErrorAction ignore
##Считает началльный и конечный IP, IP роутера, маску понятную серверу, приводим к понятному виду DNS и домен
$Mask = $Mask.Split('\')
$network = $mask[0]
$network = $network.Split('.')
$dom = $dhcpServer.Split('.')
##Жесткая ебанина в которую если не понимаете лучше не вдаваться))
[uint32]$tmp = 0
$tmp = -bnot $tmp -shl (32 - $mask[1])
$MaskIP = for ( $i = 1 ; $i -le 4 ; $i++ ) {
  [uint32]$tmp2 = $tmp -band (255 -shl 24)
  $tmp2 = $tmp2 -shr 24
  write-Output $tmp2
  $tmp = $tmp -shl 8
}
##Записываем IP Маски, первого и последнего адреса
$StartIP = ([int]$Network[0], [int]$Network[1], [int]$Network[2], ([int]$Network[3]+[int]$excludeIP+1)) -join '.'
$EndIP = (([int]$network[0]+(255-[int]$MaskIP[0])), ([int]$network[1]+(255-[int]$MaskIP[1])), ([int]$network[2]+(255-[int]$MaskIP[2])), ([int]$network[3]+(254-[int]$MaskIP[3]))) -join '.'
$Router = ([int]$Network[0], [int]$Network[1], [int]$Network[2], ([int]$Network[3]+1)) -join '.'
$MaskIP = $MaskIP -join '.'
$dom = [string]$dom[1] + "." + [string]$dom[2]
if ($dns.value[1] -ne  $null) {
$dns = [string]$dns.value[0] + ', ' + [string]$dns.value[1]
}
else {
$dns = [string]$dns.value[0]
}
##Добавляем слово VLAN к нашему VlanID и задаём лизу 7 дней (Её в общем-то можно тоже взять из дефолтного сокпа)
$Descript = "Vlan " + $VlanID
$leaseDur = "7.00:00:00"
##Вывод получившихся значений для проверки (А то вдруг скрипт разучился считать или вы что-то ввели неправильно)
Write-Host $StartIP ' - Первый IP в сети'  -ForegroundColor Green
Write-Host $EndIP ' - Последний IP Сети'  -ForegroundColor Green
Write-Host $Router ' - Gateway Адрес' -ForegroundColor Green
Write-Host $MaskIP ' - IP Маски' -ForegroundColor Green
Write-Host $dom ' - DNS Имя домена' -ForegroundColor Green
Write-Host $dns ' - DNS Серверы' -ForegroundColor Green
##Тут просто создается scope и добавляются опции
Add-DhcpServerv4Scope -Name $ScopeName -StartRange $StartIP -EndRange $EndIP -SubnetMask $MaskIP -LeaseDuration $LeaseDur -ComputerName $dhcpServers[$dhcpServerID].dnsname -Description $Descript
Start-Sleep -Seconds 3
Set-DhcpServerv4OptionValue -ScopeId (Get-DhcpServerv4Scope -ComputerName $dhcpServers[$dhcpServerID].dnsname | Where-Object {$_.name -eq $ScopeName}).ScopeId.IPAddressToString -ComputerName $dhcpServers[$dhcpServerID].dnsname -Router $Router
Set-DhcpServerv4DnsSetting -ComputerName $dhcpServers[$dhcpServerID].dnsname -ScopeId (Get-DhcpServerv4Scope -ComputerName $dhcpServers[$dhcpServerID].dnsname | Where-Object {$_.name -eq $ScopeName}).ScopeId.IPAddressToString -NameProtection $false -DynamicUpdates Always -UpdateDnsRRForOlderClients $true 
##Если есть конфигурация Failover то в нее добавится наш скоп, если нет, скрипт сообщит об этом
if ($Failover -ne $null) {
Add-DhcpServerv4FailoverScope -Name $FailoverName -ScopeId $name.ScopeId.IPAddressToString -ComputerName $dhcpServers[$dhcpServerID].dnsname
}
else {
Write-Host 'Отказоустойчивые конфигурации не найдены и не будут созданы' -ForegroundColor Red
}
