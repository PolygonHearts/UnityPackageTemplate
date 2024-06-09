$companyNameReplaceTag = "REPLACE_ME_COMPANY_NAME"
$packageNameReplaceTag = "REPLACE_ME_PACKAGE_NAME"

$companyNameReplaceTagLowerCase = "REPLACE_ME_COMPANY_NAME_LOWER"
$packageNameReplaceTagLowerCase = "REPLACE_ME_PACKAGE_NAME_LOWER"

$packageDisplayNameReplaceTag = "REPLACE_ME_PACKAGE_DISPLAY_NAME"
$packageDescReplaceTag = "REPLACE_ME_PACKAGE_DESC"
$authorNameReplaceTag = "REPLACE_ME_AUTHOR_NAME"

$escapedRootPath = [Regex]::Escape($PSScriptRoot)

Write-Host "--- Please Provide Package Details ---" -ForegroundColor Cyan -BackgroundColor DarkBlue

Write-Host "Enter package identifer in the form X.Y (No Spaces) (e.g. Company.Package)" -ForegroundColor Yellow -BackgroundColor DarkBlue
$packageFullName = Read-Host

$regexMatch = [regex]::Match($packageFullName, "^(\w+)\.(\w+)$")

if(-not $regexMatch.Success)
{
    Write-Host "Package Name Not in Valid format of X.Y (no spaces)" -ForegroundColor Yellow -BackgroundColor DarkRed
    return
}

$companyName = $regexMatch.Groups[1].Value
$packageName = $regexMatch.Groups[2].Value

Write-Host "Enter package display name" -ForegroundColor Yellow -BackgroundColor DarkBlue
$packageDisplayName = Read-Host

Write-Host "Enter Package Description for manifest" -ForegroundColor Yellow -BackgroundColor DarkBlue
$packageDescription = Read-Host

Write-Host "Enter Author Name" -ForegroundColor Yellow -BackgroundColor DarkBlue
$authorName = Read-Host

$companyNameLower = $companyName.ToLowerInvariant()
$packageNameLower = $packageName.ToLowerInvariant()

Write-Host "Package Name: " -ForegroundColor Cyan -BackgroundColor DarkBlue  -NoNewline
Write-Host "$companyName.$packageName (com.$companyNameLower.$packageNameLower)" -ForegroundColor Yellow -BackgroundColor DarkBlue
Write-Host "Display Name: " -ForegroundColor Cyan -BackgroundColor DarkBlue  -NoNewline
Write-Host "$packageDisplayName" -ForegroundColor Yellow -BackgroundColor DarkBlue
Write-Host "Display Description: " -ForegroundColor Cyan -BackgroundColor DarkBlue  -NoNewline
Write-Host "$packageDescription" -ForegroundColor Yellow -BackgroundColor DarkBlue
Write-Host "Package Author: " -ForegroundColor Cyan -BackgroundColor DarkBlue  -NoNewline
Write-Host "$authorName" -ForegroundColor Yellow -BackgroundColor DarkBlue
Write-Host "" -ForegroundColor Yellow -BackgroundColor DarkBlue
Write-Host "--- Do you wish to continue (y/n)? ---" -ForegroundColor Yellow -BackgroundColor DarkBlue


$confirmation = Read-Host  
if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Host "Cancled Run" -ForegroundColor Yellow -BackgroundColor DarkRed
    return
}

Write-Host "--- Renaming Package Folder ---" -ForegroundColor Cyan -BackgroundColor DarkBlue

$rootFolder = Get-Item -Path "$PSScriptRoot/Assets/Packages/com.$companyNameReplaceTag.$packageNameReplaceTag"

$newRootPath = $rootFolder.Name -replace $companyNameReplaceTag,$companyName -replace $packageNameReplaceTag,$packageName
#$rootFolder = $rootFolder.FullName -replace $companyNameReplaceTag,$companyName -replace $packageNameReplaceTag,$packageName


$oldPathRelToScript = ($rootFolder -replace $escapedRootPath, "")
$newPathRelToScript = ($newRootPath -replace $escapedRootPath, "")

Write-Host " - Renaming $oldPathRelToScript`n    ->  $newPathRelToScript" 
#Rename-Item -Path $rootFolder -NewName $newRootPath

Write-Host "--- Renaming Files ---" -ForegroundColor Cyan -BackgroundColor DarkBlue

$filesNeedRenaming = Get-ChildItem -Path $rootFolder -Recurse | 
    Where {($_.Name -Match $companyNameReplaceTag) -or ($_.Name -Match $packageNameReplaceTag)}

foreach($file in $filesNeedRenaming)
{
    $newFilePath = $file.Name -replace $companyNameReplaceTag,$companyName -replace $packageNameReplaceTag,$packageName

    $oldPathRelToScript = ($file.FullName -replace "$escapedRootPath\\", "")
    $newPathRelToScript = ($newFilePath -replace "$escapedRootPath\\", "")

    Write-Host " - Renaming $oldPathRelToScript`n    ->  $newPathRelToScript" 
    #Rename-Item -Path $file.FullName -NewName $newFilePath
}


Write-Host "--- Replacing Text In Files ---" -ForegroundColor Cyan -BackgroundColor DarkBlue

$filesNeedTextReplace = Get-ChildItem -Path $rootFolder -Recurse -File
foreach ($file in $filesNeedTextReplace)
{
    $fileContents = Get-Content -Path $file.FullName
    if(`
        ($fileContents -Match $companyNameReplaceTag) -or`
        ($fileContents -Match $packageNameReplaceTag) -or`
        ($fileContents -Match $companyNameReplaceTagLowerCase) -or`
        ($fileContents -Match $packageNameReplaceTagLowerCase) -or#
        ($fileContents -Match $packageDisplayNameReplaceTag) -or
        ($fileContents -Match $packageDescReplaceTag) -or`
        ($fileContents -Match $authorNameReplaceTag))
    {
        $oldPathRelToScript = ($file.FullName -replace "$escapedRootPath\\", "")
        Write-Host " - Replacing Text in $oldPathRelToScript"

        $replacedTest =  $fileContents`
        -replace $companyNameReplaceTag, $companyName`
        -replace $packageNameReplaceTag, $packageName`
        -replace $companyNameReplaceTagLowerCase, $companyNameLower`
        -replace $packageNameReplaceTagLowerCase, $packageNameLower`
        -replace $packageDisplayNameReplaceTag, $packageDisplayName`
        -replace $packageDescReplaceTag, $packageDescription`
        -replace $authorNameReplaceTag, $authorName

        #Set-Content -Path $destination_file -Value $replacedTest
    }
}

Write-Host "--- Replace Readme text ---" -ForegroundColor Cyan -BackgroundColor DarkBlue

$newReadmeContent = @"
# $packageDisplayName
===

$packageDescription
"@

Set-Content -Path "$PSScriptRoot\README.md" -Value $replacedTest

Write-Host "--- Enabling Github Actions ---" -ForegroundColor Cyan -BackgroundColor DarkBlue
#Rename-Item -Path "$PSScriptRoot\.github\workflows_TO_ENABLE" -NewName "workflows"


Write-Host "--- Removing Setup Script ---" -ForegroundColor Cyan -BackgroundColor DarkBlue
#Remove-Item $PSCommandPath -Force 


Write-Host "--- Done! ---" -ForegroundColor Cyan -BackgroundColor DarkBlue
Start-Sleep -Seconds 3