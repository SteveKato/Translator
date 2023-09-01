Add-Type -AssemblyName System.Windows.Forms

. $PSScriptRoot\libs\Parse-StringToTimeValue.ps1
. $PSScriptRoot\libs\translator1.ps1

try 
{
    $timer.Dispose()
    $form.Dispose()
}
catch
{
    If ($psISE -and ($testInISE -ne $true)) {
        start-process powershell -ArgumentList ('-WindowStyle hidden -File "'+$script:MyInvocation.MyCommand.Path+'"') 
        return
    }
}

[System.Windows.Forms.Application]::EnableVisualStyles()

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Tłumacz polsko-angielski'
$form.TopMost = $true
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.Width = 350
$form.Height = 200
$form.Location.X = 0
$form.Location.Y = 0
# Create labels and fields

# |-.....[__ł________]---

$labelWordToTranslate = New-Object System.Windows.Forms.Label
$labelWordToTranslate.Width = 160
$labelWordToTranslate.Text = 'Słowo po polsku'
$labelWordToTranslate.TextAlign = 'MiddleLeft'
$labelWordToTranslate.Location = New-Object System.Drawing.Point(120, 5)

$fieldWordToTranslate = New-Object System.Windows.Forms.TextBox
$fieldWordToTranslate.Enabled = $true
$fieldWordToTranslate.Text = ""
$fieldWordToTranslate.Width = 160
$fieldWordToTranslate.TextAlign = 'MiddleLeft'
$fieldWordToTranslate.Location = New-Object System.Drawing.Point(95,35) #0.5*(350-200), ...

# |---...---[---------]---.....[__________]---


$labelTranslatedWord = New-Object System.Windows.Forms.Label
$labelTranslatedWord.Text = 'Słowo po angielsku'
$labelTranslatedWord.Width = 160
$labelTranslatedWord.TextAlign = 'MiddleLeft'
$labelTranslatedWord.Location = New-Object System.Drawing.Point(120, 95)
$labelTranslatedWord.Visible = $false

$fieldTranslatedWord = New-Object System.Windows.Forms.TextBox
$fieldTranslatedWord.Enabled = $false
$fieldTranslatedWord.TextAlign = 'MiddleLeft'
$fieldTranslatedWord.Width = 160
$fieldTranslatedWord.Location = New-Object System.Drawing.Point(95, 125)
$fieldTranslatedWord.Visible = $false

# |-.....[__________]---
function Translate-Click ()
{
    [string] $wordToTranslate = $fieldWordToTranslate.Text

    #ustawienie widoku
    $fieldTranslatedWord.Text = "Czekam na tłumaczenie..."
    $fieldTranslatedWord.Visible = $true
    $labelTranslatedWord.Visible = $true

    #wysłanie danych do tłumaczenia
    $response = Load-TranslatorData($wordToTranslate); #Load-TranslatorData -translateThisWord $wordToTranslate [-url www.translate.google.com]
     $translation_data = Parse-TranslatorData($response) #if no data Write-Host "podaj słowo do przetłumaczenia"
    # Write-Host $translation_data
     $translation = Get-TranslatedData($translation_data)# [-element 6]
     #
     #Write-Output "Tłumaczenie `'$wordToTranslate`' na język angielski to: $translation"
     $fieldTranslatedWord.Text = $translation

}
$ButtonTranslate_Click = { Translate-Click }
$ButtonTranslate = New-Object System.Windows.Forms.Button
$ButtonTranslate.Location = New-Object System.Drawing.Size(110,70)
$ButtonTranslate.Size = New-Object System.Drawing.Size(120,23)
$ButtonTranslate.Enabled = $false
$ButtonTranslate.Text = "Tłumacz"
$ButtonTranslate.Add_Click($ButtonTranslate_Click)
#$ButtonTranslate.Visible = $false

# |---...---[---------]---.....[__________]---
function Copy-Click ()
{
    [string] $wordToCopy = $fieldTranslatedWord.Text

     #Write-Output "Tłumaczenie `'$wordToTranslate`' na język angielski to: $translation"
     #$wordToCopy|clip
     Set-Clipboard $wordToCopy
}
$ButtonCopy_Click = { Copy-Click }
$ButtonCopy = New-Object System.Windows.Forms.Button
$ButtonCopy.Location = New-Object System.Drawing.Size(260,125)
$ButtonCopy.Size = New-Object System.Drawing.Size(60,23)
$ButtonCopy.Enabled = $false
$ButtonCopy.Text = "Kopiuj"
$ButtonCopy.Add_Click($ButtonCopy_Click)
$ButtonCopy.Visible = $false

# Add controls to the form
$form.Controls.AddRange(@(
    $labelTranslatedWord, $fieldTranslatedWord,
    $labelWordToTranslate, $fieldWordToTranslate,
    $labelOriginalDelay, $fieldOriginalDelay,
    $labelAddDelay, $fieldAddDelay,
    $labelNewDelay, $fieldNewDelay,
    $labelNewTime, $fieldNewTime,
    $fieldCounter,
    $ButtonTranslate, $ButtonCopy
))

function RestrictToFilled($control) {
    $control.Add_KeyPress({
        $keyChar = [System.Windows.Forms.Control]::ModifierKeys -bor $_.KeyChar
            $keyChar = ([regex]::Matches($keyChar,'D(\d+)?')).Value
        if ([string]::IsNullOrEmpty($keyChar)) {
            $_.Handled = $true
        }
    })
}

# Attach the event handler to the desired fields
RestrictToDigits $fieldOriginalDelay
RestrictToDigits $fieldAddDelay
# Add more fields here as needed

function updateFields ()
{

    if ($fieldWordToTranslate.Focused)
    {
        if ([string]::IsNullOrEmpty($fieldWordToTranslate.Text))
        {
            $ButtonTranslate.Enabled = $false
        }
        else
        {
            $ButtonTranslate.Enabled = $true
        }
    }

    
        if ([string]::IsNullOrEmpty($fieldTranslatedWord.Text))
        {
            $ButtonCopy.Enabled = $false
        }
        else
       {
           $ButtonCopy.Enabled = $true
       }
     $ButtonCopy.Visible = $fieldTranslatedWord.Visible

}


# Timer for updating the fields
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500
$timer.Enabled = $false

# Event handler for the form closed event
$form.add_FormClosed({
    # Stop and dispose the timer when the form is closed
    $timer.Stop()
    $timer.Dispose()
})

# Event handler for form load
$form.add_Load(
{
    $timer.Enabled = $true
    $timer.Add_Tick(
        {
            #Write-Host "tick"
            updateFields
        }
    )
    #$timer.Start()
})

# Start the form
$form.ShowDialog() | Out-Null
#$timer.Dispose()
$form.Dispose()
