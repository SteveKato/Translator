###
#
#    Author: MaWCin (MaW/MrCin)
#    This code comes from repository https://github.com/MaWCin/ParseStrings
#    You can use it, redistribute and/or modify it under the terms of the GNU
#    General Public License as published by the Free Software Foundation,
#    either version 3 of the License, or (at your option) any later version.
# 
###

function Parse-StringToTimeValue ([string] $value, [switch] $returnString=$false)
{
    [string] $value_  = ""
    [System.Collections.ArrayList] $output_ = @()

    [int[]] $maxPosVal_ = @(24,60,60)
    [string] $subVal_ = "00"
    [bool] $isTimeVal = $true

    If ($value.Length -ge 8)
    {
        $value_ = $value.Substring(0,8)
    }
    else
    {
        $value_ = $value
    }
     
    switch ($value.Length)
    {
        0   {
                $output_ = @("00","00","00")
                break
            }
        #if there are only numbers...
        {($value -replace '\D+').Length -eq $_} 
            {
            do {
               switch ($value_.length)
                {
                    1 {
                        #Write-host "# length 1"
                        $output_.Add("0"+$value_)|Out-Null
                        $value_ = ""
                       }
              default {
                        #Write-host "# `"$value_`" ($($value_.Length))"
                        $subVal_ = $value_.Substring(0,2)
                        #Write-Host "$subVal_ [$($maxPosVal_[$output_.Count])] ($($output_.Count)) $([int]$subVal_ -lt $maxPosVal_[$output_.Count])"
                        if ([int]$subVal_ -lt $maxPosVal_[$output_.Count])
                        {
                            $output_.Add($subVal_)|Out-Null
                            $value_ = $value_.Substring(2,$value_.Length-2)
                        }
                        else
                        {
                            $output_.Add( "0"+$value_[0])|Out-Null
                            $value_ = $value_.Substring(1,$value_.Length-1)
                        }
                    }
                }
            } while ($isTimeVal -and ($output_.Count -lt 3) -and ($value_.Length))
        #
        break
        }

        #if there are digital substrings of length less than 3
        {([regex]::Matches($value_, '\d{3,}')).Count -eq 0}
            {
                #Write-Host "[$value_]"
                $output_ = [regex]::Matches($value_, '\d+') | %{ $_.Value }

                for ([int] $i=0;$i -lt $output_.Count;$i++)
                {
                    if($output_[$i].Length -eq 1) 
                    {
                        $output_[$i] = "0" +  $output_[$i]
                    }
                }
            #
        break
        }

        default {
            $output_ = (,$subVal_*3)
        }
    }
    #Write-Host $output_

    if ($output_.Count -lt 3)
    {
        #Write-Host $output_
        $output_.Add("00")|Out-Null
    }
    if ($returnString)
    {
        return ($output_ -join ":")
    }
    else
    {
        return [datetime] ($output_ -join ":")
    }
}

Write-Host "parse string to time script"