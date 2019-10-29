#Для того чтобы этот скрипт сработал, название файлов фотографий должно совпадать с атрибутом Samaccountname пользователей
#Путь к файлам фотографий
$PhotosPath = "C:\Temp"
#Получение списка всех файлов
$PhotosFilePath = Get-ChildItem -Path $PhotosPath
#Запрос формата файлов
$filesformat = Read-Host "Insert Photo files Format. Example .jpg, .bmp etc"
#Цикл для каждого объекта фотографии
Foreach ($UserPhoto in $PhotosFilePath) {
#Перекодируем файл фотографии в понятный АД
$photo = [byte[]](Get-Content $UserPhoto -Encoding byte)
#Забираем из имени файла имя пользователя
$User = $UserPhoto.Name -replace $filesformat,''
#Задаем фотографию пользователю
Set-ADUser -Identity $User -Add @{thumbnailPhoto=$photo}
#Счастливый конец
}