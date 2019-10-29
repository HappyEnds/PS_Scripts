$OUDN = Read-Host "Insert OU Distinguished Name For Search Users and Groups"
$GRPNamePart = Read-Host "Insert a part of Group name for search filtering"
$AttrValue0 = Read-Host "Insert Attr Value for adding in first condition"
$AttrValue1 = Read-Host "Insert Attr Value for adding in second condition"
$AttrValue2 = Read-Host "Insert Attr Value for adding in third condition"
$KeyAttrValue00 = "0"
$KeyAttrValue01 = "1"

$GRPNamePart = $GRPNamePart + "*"

$UsersFromOU = Get-ADUser -Filter * -SearchBase $OUDN -Properties *
$GroupsFromOU = Get-ADGroup -Filter {Name -like $GRPNamePart} -SearchBase $OUDN

foreach ($User in $UsersFromOU) {

   if ($User.Surname -eq $KeyAttrValue00) {

      Foreach ($Group in $GroupsFromOU) {

         $GroupMember = Get-ADGroupMember -Identity $Group.Name | Where-Object {$_.SamAccountName -eq $User.SamAccountName}

         if ($GroupMember -ne $null) {

            Set-ADUser -Identity $User.SamAccountName -City $AttrValue0

           }
       }
   }

   elseif ($User.Surname -eq $KeyAttrValue01) {
   
      foreach ($Group in $GroupsFromOU) {
      
         $GroupMember = Get-ADGroupMember -Identity $Group.Name | Where-Object {$_.SamAccountName -eq $User.SamAccountName}

         if ($GroupMember -ne $null) {

            Set-ADUser -Identity $User.SamAccountName -City $AttrValue1

           }
       }
   }
   
   else {

   Set-ADUser -Identity $User.SamAccountName -City $AttrValue2

   }

   Clear-Variable User,Group,GroupMember
}
