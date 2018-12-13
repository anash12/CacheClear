#Title: Cache Clear
#Author: Drew Nash
#Date: 7/31/2018
#Version: 0.1
#
#Description: This is a WPF app used to perform general cleanup on a Windows PC. Currently still in progress. 
#

function ClearIECache{
    param(
        $SavePasswords
        )
    $ErrorActionPreference = SilentlyContinue
    Get-Process iexplore | Stop-Process -Force
    $ErrorActionPreference = Continue
     ###Delete cache, save passwords
    if ($SavePasswords = "Y"){
        rundll32.exe inetcpl.cpl, ClearMyTracksByProcess 8
        rundll32.exe inetcpl.cpl, ClearMyTracksByProcess 2
        rundll32.exe inetcpl.cpl, ClearMyTracksByProcess 1
        rundll32.exe inetcpl.cpl, ClearMyTracksByProcess 16
        rundll32.exe inetcpl.cpl, ClearMyTracksByProcess 4351
    }

    ###Delete all cache including passwords 
    else{
        rundll32.exe inetcpl.cpl, ClearMyTracksByProcess 255
    }
}

function ClearChromeCache{
    param(
        $SavePasswords
    )
    $ErrorActionPreference = SilentlyContinue
    Get-Process chrome | Stop-Process -Force
    $ErrorActionPreference = Continue
    ###Delete cache, save passwords
    if ($SavePasswords = "Y"){
        $Path = "C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\User Data\Default\Cache"
        Get-ChildItem -Path $Path -Recurse | ForEach-Object {Remove-Item -Path $Path -Recurse}  ###delete any files and subfolders
        Remove-Item 'C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\User Data\Default\Cookies'
        Remove-Item 'C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\User Data\Default\History'
    }
    else{
        $Path = "C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\User Data\Default\Cache"
        Get-ChildItem -Path $Path -Recurse | ForEach-Object {Remove-Item -Path $Path -Recurse}  ###delete any files and subfolders
        Remove-Item 'C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\User Data\Default\Cookies'
        Remove-Item 'C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\User Data\Default\History'
        Remove-Item 'C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\User Data\Default\Login Data'
    }
}

function ClearFirefoxCache{
}

function ClearEdgeCache{
}

function WindowsCleanup{

    ###Launches Disk Cleanup utility, allowing for option before launching the tool.
    cleanmgr.exe /sageset:1
}


###Prompt for user input
Write-Host "Would you like to preserve saved passwords? (Y/N)"

###Sets the $SavePasswords parameter for the function parameters
$SavePasswords = Read-Host 


###Call the functions
ClearIECache -SavePasswords $SavePasswords
ClearChromeCache -SavePasswords $SavePasswords

$ErrorActionPreference 

###GUI Creation
$inputXML = @"
<Window x:Class="FoxDeploy.Window1" 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
    xmlns:d="http://schemas.microsoft.com/expression/blend/2008" 
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" 
    xmlns:local="clr-namespace:Azure" 
    mc:Ignorable="d" 
    Title="FoxDeploy Awesome GUI" Height="524.256" Width="541.076">
    <Grid Margin="0,0,45,0">
        <Image x:Name="image" HorizontalAlignment="Left" Height="100" Margin="24,28,0,0" VerticalAlignment="Top" Width="100" Source="C:\Users\Stephen\Dropbox\Docs\blog\foxdeploy favicon.png"/>
        <TextBlock x:Name="textBlock" HorizontalAlignment="Left" Height="100" Margin="174,28,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="282" FontSize="16"><Run Text="Use this tool to find out all sorts of useful disk information, and also to get rich input from your scripts and tools"/><InlineUIContainer>
                <TextBlock x:Name="textBlock1" TextWrapping="Wrap" Text="TextBlock"/>
            </InlineUIContainer></TextBlock>
        <Button x:Name="button1" Content="OK" HorizontalAlignment="Left" Height="55" Margin="370,235,0,0" VerticalAlignment="Top" Width="102" FontSize="18.667"/>
        <TextBox x:Name="textBox" HorizontalAlignment="Left" Height="35" Margin="221,166,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="168" FontSize="16"/>
        <Label x:Name="label" Content="UserName" HorizontalAlignment="Left" Height="46" Margin="56,162,0,0" VerticalAlignment="Top" Width="138" FontSize="16"/>
        <Button x:Name="button2" Content="Button" HorizontalAlignment="Left" Height="42" Margin="174,391,0,0" VerticalAlignment="Top" Width="140"/>
    </Grid>
</Window>
"@

$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
try{
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
}
catch{
    Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
    throw
}

###Load XAML objects in powershell

$xaml.SelectNodes("//*[@Name]") | %{"trying item $($_.Name)";
    try {Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop}
    catch{throw}
    }
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
 
##Get-FormVariables
$WPFbutton1.Add_Click({$form.Close()})

###Call the form
$form.ShowDialog() | Out-Null







