#no special modules required tested with PowerShell 5
#Define input and output file - json and csv are supported for both files
$InputFilePath = "C:\Temp\t_person.json"
$OutputFilePath = "C:\Temp\t_person_anomized.csv"

#Create a new object for output
$OutputObject = [PSCustomObject]@{
    GUID = (New-Guid).Guid
    Date = (Get-Date).ToString()
    Data = [System.Collections.ArrayList]::new()
}
function Import-Data {
    param (
        $inputFile
    )
    $InputFileType = $inputFile.Split(".")[1]
    If ($InputFileType -eq "csv"){
        #Import CSV file into an array
        $data = Import-CSV -path $inputFile
    }elseif($InputFileType  -eq "json"){
        #Import JSON file into an array
        $data = Get-Content -path $inputFile | ConvertFrom-Json
    }
    return $data
}

function Export-Data {
    param (
        $outputFile,
        $OutputObject
    )
    $outpuFileType = $outputFile.Split(".")[1]

    If ($outpuFileType -eq "csv"){
        #export anomized data as CSV
        $OutputObject.Data | Export-Csv -Path $outputFile -NoTypeInformation
    }elseif($OutpuFileType -eq "json"){
        #export anomyzed data as .json
        $OutputObject.Data | ConvertTo-Json |Out-File $outputFile
    }
}

$Data = Import-Data -inputFile $InputFilePath

foreach($item in $Data){
    #first_name
    $length_first_name = $item.first_name.Length
    $length_to_cute = $length_first_name - 1 #same number as in line 50
    #Keep first character, cut every following character and add 9 asterisks
    $new_first_name =  $item.first_name.Remove(1,$length_to_cute) + "*********"
    
    #last name
    #replace all last names with a random number of 10 digits
    $new_last_name = "" #"reset" variable
    for ($i = 0; $i -lt 10; $i++) {
        #some progams automatically remove number 0 as first character. Therefore we start for the first chracter with at least 1
        if ($i -eq 0){
            $new_last_name += Get-Random -Minimum 1 -Maximum 9
        }else{
            $new_last_name += Get-Random -Minimum 0 -Maximum 9
        }
    }
    
    #date of birth
    #remove the first six characters of the birthdate
    $new_date_of_birth = $item.date_of_birth.Remove(0,6)

    #Salary
    #adopt the salary bassed on the value.
    $new_salary = ""
    $intsalary = $item.salary -as [int] #"import" salary as int for comparing

    if ($intsalary -lt 50000) {
        $new_salary = "low"
    }elseif ($intsalary -ge 50000 -and $intsalary -lt 100000) {
        $new_salary = "medium"
    }elseif ($intsalary -ge 100000) {
        $new_salary = "high"
    }

    #Add data to output object
    $OutputObject.Data.Add([PSCustomObject]@{
        Id =                $item.Id
        salutation =        $item.salutation
        first_name =        $new_first_name
        last_name =         $new_last_name
        date_of_birth =     $new_date_of_birth
        is_vip =            $null
        salary =            $new_salary
        date_of_creation =  $item.date_of_creation
        username =          $null
        password =          $null
    })  
} 

Export-Data -outputFile $OutputFilePath -OutputObject $OutputObject
