#
# --- wysyła zapytanie do strony i podaje dale odpowiedź
#
function Load-TranslatorData ([string] $translateThisWord, [string] $url = "https://www.diki.pl/slownik-angielskiego?q=$translateThisWord")
{    
    [Microsoft.PowerShell.Commands.HtmlWebResponseObject] $response_ = $null #lokalna zmienna, do której zgarniemy dane z zapytania

    $response_ = Invoke-WebRequest -Uri $url
    
    #wypycha na zewnątrz dane zapisane do $response_
    return $response_
}

#
# --- 
#
function Parse-TranslatorData ([string] $translatorData)
{

    [string[]] $splitSeparators_ = @(  '<h2 class="dictionarySectionHeader">',
                            '<span class="dictionaryEntryHeaderAdditionalInformation">',
                            "`r`n")
    # [<HTML><BODY>aaaaa];[[b|b|b|b|b|b|b|b|b]#[xfgndcnmxdjgbhshdkjvgs,kjvbhsefdjv</BODY></HTML>]]
    [string] $parsed_data_ =  (
            ($translatorData -split ($splitSeparators_[0])
        )[1] -split ($splitSeparators_[1])
    )[0]
    #CZYSZCZENIE Z TAGÓW html-OWYCH i dzielenie na elementy do odczytu
    [System.Collections.ArrayList] $translation_data = ($parsed_data_ -replace '<[^>]+>',$splitSeparators_[2]) -split $splitSeparators_[2]

    #Write-Host $translatorData
    if ([string]::IsNullOrEmpty($translation_data) -eq $true)
    {
        Write-Error "Parse-TrasnslatorData: no data in `$translatorData"
        return "no data"
    }

    #czyścimy - usuwamy niepotrzebne puste komórki z danych
    [int] $i = 0
    do
    {
        if (([string]::IsNullOrEmpty($translation_data[$i])) -eq $true) 
        {
            $translation_data.RemoveAt($i)
        }
        elseif (([string]::IsNullOrEmpty(($translation_data[$i]).Trim())) -eq $true)
        {
            $translation_data.RemoveAt($i)
        }
        else
        {
            $i++
        }
    } while ($i -lt $translation_data.Count)

    return $translation_data
}

#
# --- 
#
function Get-TranslatedData ([string[]] $translationData, [int]$element = 6)
{ 
    return $translationData[$element]
}

#
# --- główna metoda ---
#
function StartTranslate ()
{
    [string] $wordToTranslate = ""
    [string[]] $prompts = @("Podaj słowo do przetłumaczenia na angielski",
                            "Czy chcesz przetłumaczyć inne słowo? ")
    #
    [Microsoft.PowerShell.Commands.HtmlWebResponseObject] $response = $null
    [System.Collections.ArrayList] $translation_data = @()
    #
    [string] $translation = ""
    [string] $answer = ""

    do
    {
        cls
        #
        #if ([string]::IsNullOrEmpty($wordToTranslate) -eq $false)
        if ($wordToTranslate -eq "")

        {
        $answer = Read-Host "$($prompts[0])" #czyta dane używając treści pytania przechowywanego w $prompts
        $translation = ""
        }
        else  
        {
        
            $response = Load-TranslatorData($wordToTranslate); #Load-TranslatorData -translateThisWord $wordToTranslate [-url www.translate.google.com]
            $translation_data = Parse-TranslatorData($response) #if no data Write-Host "podaj słowo do przetłumaczenia"
           # Write-Host $translation_data
            $translation = Get-TranslatedData($translation_data)# [-element 6]
            #
            Write-Output "Tłumaczenie `'$wordToTranslate`' na język angielski to: $translation"

            $answer = Read-Host $prompts[1]
        }
        
        if (($answer -eq "") -or ($answer.ToUpper() -eq "N"))
        {                   
            $answer = "nie"
        }
        elseif (($answer.ToUpper() -eq "T") -or (($answer.ToUpper() -eq "TAK") -and ($translation -ne "")))
        {
        #$translation = ""
        $wordToTranslate = ""
        }
        else 
        {
            $wordToTranslate = $answer
        }
    } while (($answer -ne "nie") -or ($translation  -eq ""))

    return $void
}

#StartTranslate
