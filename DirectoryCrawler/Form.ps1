<#
.SYNOPSIS
This script contains functions for parsing INI files and working with Windows Forms.

.DESCRIPTION
This script defines functions for parsing INI files and working with Windows Forms for various purposes.

.AUTHOR
Ryan McLaughlin

.NOTES
File Name      : Form.ps1
Prerequisite   : PowerShell
#>

# Load the Windows Forms assembly
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
cls
function Parse-IniFile
{
    <#
    .SYNOPSIS
    Parses an INI file and returns its contents as a hashtable.

    .DESCRIPTION
    This function reads and parses an INI file specified by the FilePath parameter. It extracts the sections, keys, and values from the INI file and returns them as a hashtable for further processing.

    .PARAMETER FilePath
    Specifies the path to the INI file to be parsed.

    #>
    param
    (
        [string]$FilePath
    )

    $ini = @{}

    # default section if none exist
    $section = "NO_SECTION"
    $ini[$section] = @{}

    switch -regex -file $FilePath
    {        
        "^\[(.+)\]$" 
        {
        
            $section = $matches[1].Trim()
            $ini[$section] = @{}
        }
        
        "^\s*([^#].+?)\s*=\s*(.*)"
        {
            $name,$value = $matches[1..2]

            # skip comments (lines starting with ; or #)
            if (!($name.StartsWith(";")) -and !($name.StartsWith("#")))
            {
                $ini[$section][$name] = $value.Trim()
            }
        }
    }
    
    # Return the parsed INI data
    return $ini
}

function Get-IniValue
{
    <#
    .SYNOPSIS
    Retrieves a value from an INI file section.

    .DESCRIPTION
    This function retrieves a specific value from an INI file section. It takes a hashtable containing the parsed INI data, the name of the section, and the name of the key as parameters. If the section and key exist, it returns the associated value.

    .PARAMETER IniData
    Specifies a hashtable containing the parsed INI data.

    .PARAMETER SectionName
    Specifies the name of the section from which to retrieve the value.

    .PARAMETER KeyName
    Specifies the name of the key for which to retrieve the value.

    #>
    param
    (
        [hashtable]$IniData,
        [string]$SectionName,
        [string]$KeyName
    )

    # Check if the section exists in the dictionary
    if ($IniData.ContainsKey($SectionName))
    {
        # Check if the key exists within the section
        if ($IniData[$SectionName].ContainsKey($KeyName))
        {
            # Retrieve the value associated with the key
            $value = $IniData[$SectionName][$KeyName]
            Write-Host "Value of $KeyName in [$SectionName]: $value"
            return $value
        }
        else
        {
            Write-Host "Key $KeyName not found in [$SectionName]"
        }
    }
    else
    {
        Write-Host "Section [$SectionName] not found"
    }
}

# Parse ini file
$iniPath = Join-Path -Path $PSScriptRoot -ChildPath "crawl.ini"				   
$iniData = Parse-IniFile $iniPath

# Get variables from ini
$sectionName = "Defaults"
$startingDirectory = Get-IniValue -IniData $iniData -SectionName $sectionName -KeyName "StartingDirectory"
$logLocation = Get-IniValue -IniData $iniData -SectionName $sectionName -KeyName "LogLocation"


# Create a form
$form = New-Object Windows.Forms.Form
$form.Text = "Directory Crawler"
$form.Width = 420

# Label for Starting Directory
$labelStartingDir = New-Object Windows.Forms.Label
$labelStartingDir.Text = "Starting Directory:"
$labelStartingDir.Location = New-Object Drawing.Point(10, 10)
$labelStartingDir.Width = 120

# Textbox for Starting Directory
$textBoxStartingDir = New-Object Windows.Forms.TextBox
$textBoxStartingDir.Location = New-Object Drawing.Point(140, 10)
$textBoxStartingDir.Width = 250
$textBoxStartingDir.Text = $startingDirectory  # Set the text to the startingDirectory

# Label for Log Location
$labelLogDir = New-Object Windows.Forms.Label
$labelLogDir.Text = "Log Location:"
$labelLogDir.Location = New-Object Drawing.Point(10, 40)
$labelLogDir.Width = 120

# Textbox for Log Location
$textBoxLogDir = New-Object Windows.Forms.TextBox
$textBoxLogDir.Location = New-Object Drawing.Point(140, 40)
$textBoxLogDir.Width = 250
$textBoxLogDir.Text = $logLocation  # Set the text to the logLocation

# Checkbox for Crawl Subdirectories
$checkBoxCrawlSub = New-Object Windows.Forms.CheckBox
$checkBoxCrawlSub.Text = "Crawl Subdirectories"
$checkBoxCrawlSub.AutoSize = $false  # Disable auto-sizing
$checkBoxCrawlSub.Location = New-Object Drawing.Point(10, 70)
$checkBoxCrawlSub.Checked = $false
$checkBoxCrawlSub.Width = 200  # Adjust the width as needed to fit the text without wrapping


# Button to Start
$buttonStart = New-Object Windows.Forms.Button
$buttonStart.Text = "Start"
$buttonStart.Location = New-Object Drawing.Point(10, 100)
$buttonStart.Add_Click({
    # Handle Start button click here
    $startingDirectory = $textBoxStartingDir.Text
    $logLocation = $textBoxLogDir.Text
    $crawlSubdirectories = $checkBoxCrawlSub.Checked

    # Perform the directory crawling operation here
    # You can use the provided variables $startingDirectory, $logLocation, and $crawlSubdirectories
    # Example: Invoke-YourDirectoryCrawlFunction -StartingDirectory $startingDirectory -LogLocation $logLocation -CrawlSubdirectories $crawlSubdirectories
})

# Button to Open Log
$buttonOpenLog = New-Object Windows.Forms.Button
$buttonOpenLog.Text = "Open Log"
$buttonOpenLog.Location = New-Object Drawing.Point(140, 100)
$buttonOpenLog.Add_Click
({
    # Handle Open Log button click here
    $logLocation = $textBoxLogDir.Text
        
    Write-Host "Open log: $logLocation"

    # Open the log file or perform the desired action here
    # Example: Invoke-YourLogOpeningFunction -LogLocation $logLocation
})

# List of Extension Types to Find
$listBoxExtensions = New-Object Windows.Forms.ListBox
$listBoxExtensions.Location = New-Object Drawing.Point(10, 130)
$listBoxExtensions.Width = 250
$listBoxExtensions.Height = 100
$listBoxExtensions.SelectionMode = [System.Windows.Forms.SelectionMode]::MultiExtended  # Allow multiple selections
# Add extension types to the list
$listBoxExtensions.Items.Add(".txt")
$listBoxExtensions.Items.Add(".jpg")
$listBoxExtensions.Items.Add(".png")
$listBoxExtensions.Items.Add(".doc")
$listBoxExtensions.Items.Add(".xlsx")
$listBoxExtensions.Items.Add(".pdf")

# Add controls to the form
$form.Controls.Add($labelStartingDir)
$form.Controls.Add($textBoxStartingDir)
$form.Controls.Add($labelLogDir)
$form.Controls.Add($textBoxLogDir)
$form.Controls.Add($checkBoxCrawlSub)
$form.Controls.Add($buttonStart)
$form.Controls.Add($buttonOpenLog)
$form.Controls.Add($listBoxExtensions)

# Show the form
$form.ShowDialog()

# Dispose of the form when done
$form.Dispose()
