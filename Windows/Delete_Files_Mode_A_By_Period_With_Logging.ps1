
## Задаем период и корневой каталог для удаления файлов
$start = (Get-Date).AddDays(-541)
$end = (Get-Date).AddDays(-176)
$paths = Get-ChildItem -path 'C:\temp' | select -Property fullname, name
## Общий цикл обработки
foreach ($path in $paths) {
## Для удобства переносим путь к файлу в отдельную переменную
$pat = $path.fullname
## формируем лог файл с именем каталогов входящих в состав корневого
$logpath = "C:\temp\delete log\" + $path.name + ".txt"
New-Item -Path "C:\temp\delete log" -Name ($path.name + ".txt") -ItemType File -Confirm:$false -Force
## Получаем только файлы, последнее взаимодействие с которыми было в указанный период
$files = Get-ChildItem -Path $pat -Recurse -Force | Where-Object {$_.Mode -eq "-a----"} | Where-Object {($_.LastWriteTime -gt $start) -and ($_.LastWriteTime -lt $end)}
## Записываем удобный для чтения лог
   foreach ($file in $files) {

   $log = $file.FullName + " ; " + $file.LastWriteTime
   Add-Content -Path $logpath -Value $log -Confirm:$false -Force
   Clear-Variable log

   }

## Непосредственно удаляем файлы
$files | Remove-Item -Recurse -Force -Confirm:$false
## Очистка переменных в конце цикла для избежания "Залипания" данных в переменой
Clear-Variable pat
Clear-Variable logpath
## Счастливый конец
}
