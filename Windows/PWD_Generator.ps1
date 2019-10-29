#Pass exit count
$PassCount = 65
#Create txt file for password storing
New-Item -Path c:\temp -Name 2.txt -ItemType File
#Cicle
for ( $i = 1 ; $i -le $PassCount ; $i++ ) {
#Store all using symbls to var, assign minimum one number, create var with symbs
$chars = "abcdefghijkmnopqrstuvwxyzABCEFGHJKLMNPQRSTUVWXYZ123456789!#%?".ToCharArray()
$symb = "123456789!#%?".ToCharArray() | Get-Random
$newPassword=""
1..9 | ForEach {  $newPassword += $chars | Get-Random }
$newPassword = $newPassword + $symb
$word = $newPassword
#Add password string to file
Add-Content -Path c:\temp\2.txt -Value $word
#Happy End
}
