
#Path of files
$HFPath = "c:\temp\Updates.csv"
$SoftPath = "c:\temp\Soft.csv"
#Get and write all hotfixes and parameters to csv file
Get-HotFix | Export-Csv -Path $HFPath -Delimiter ";" -Encoding UTF8
#Get and write all installed software products and parameters to csv file
Get-WmiObject -Class win32_product | Export-Csv -Path $SoftPath -Delimiter ";" -Encoding UTF8
