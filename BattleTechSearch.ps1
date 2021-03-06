
##Auto-Generated using "PSProject Builder" Created by Matt Hamende 2018
#######################################################################
#Description: generates wireframe powershell projects
#Features:
## Define ScriptRoot
## Standard Function Libraries
## PSModule Prerequities Loader
## JSON Config File
########################################################################

#Set Default Error Handling - Set to Continue for Production
$ErrorActionPreference = "Stop"

#Define Logger Function
Function Log($message) {
    "$(Get-Date -Format u) | $message"
}

#Define Script Root for relative paths
$RunDir = split-path -parent $MyInvocation.MyCommand.Definition
Log "Setting Location to: $RunDir"
Set-Location $RunDir # Sets directory

## Script Below this line #######################################################

## BATTLETECH SHOP SEARCH
# searches Shop Definition Files and correlates them with System Data
# allows wildcard search of special shop items and returns results of systems
# that spawn these items in the shop

# NOTE: Shops are very RNG as is
# Still low probability the shop has what you want, but you at least know where is spawns

"####### Battletech  Shop Search ##########"
""

$SearchStr = Read-Host -Prompt "Enter Search String (I.E.)'Highlander','AC20_3'"
""

$ShopDef = Get-ChildItem $RunDir\Data\Shops

Log "Importing Shop Item Data..."

$ShopData = @()

ForEach ($obj in $ShopDef) {
    $ShopData += (Get-Content $obj.FullName) -join "`n" | ConvertFrom-Json
}

Log "Shop Data Imported"

$SystemDef = Get-ChildItem $RunDir\Data\starsystem

$SystemData = @()

Log "Importing Star System Data..."
ForEach ($star in $SystemDef) {
    $SystemData += (Get-Content $star.FullName) -join "`n" | ConvertFrom-Json
}

Log "System Data Imported..."

Log "Searching for [ $SearchStr ] ..." "Yellow"
""

[array]$itemMatches = $ShopData | Where-Object {
    $_.Specials.ID -like "*$SearchStr*"
}

"Found: $($itemMatches.count) items"

$ItemCount = 0
ForEach ($item in $itemMatches) {
    $itemStr = ($item.Specials | where-Object {
            $_.ID -like "*$SearchStr*"
        }).ID -join ", "
    

    [array]$SystemReqs = $item.RequirementTags.items
    [array]$SystemExc = $item.ExclusionTags.items

    $InvSystems = @()

    ForEach ($StarSystem in $SystemData) {
        #if bool remains true system is added to array
        $contains_req = $True
        #checks if System Tags contain all Req Tags
        ForEach ($Req in $SystemReqs) {
            if ($StarSystem.Tags.items -notcontains $Req) {
                $contains_req = $false
            } 
        }
        # If Exclusion Tags checks that array doesn't contain any
        if ($SystemExc.count -ge 1) {
            ForEach ($Req in $SystemExc) {
                if ($StarSystem.Tags.items -contains $Req) {
                    $contains_req = $false
                }
            }
        }


        if ($contains_req -eq $true) {
            $InvSystems += $StarSystem
        }
    }
    if ($InvSystems -ne $null) {
        $ItemCount++
        Write-Host -ForegroundColor Yellow "Match : $ItemCount : $($item.ID)"
        Write-Host -ForegroundColor Magenta "$itemStr"
        Write-Host -ForegroundColor White "System Tags:"
        ForEach ($tag in $SystemReqs) {
            Write-Host -ForegroundColor DarkCyan "   + $($Tag)"
        }
        Write-Host -ForegroundColor White "Exclude Tags:"
        ForEach ($tag in $SystemExc) {
            Write-Host -ForegroundColor Red "   + $($Tag)"
        }
        Write-Host -ForegroundColor Green "Potential Systems:"
        Write-Host -ForegroundColor Gray "   Name | Owner | Position"
        ForEach ($System in $InvSystems) {
            Write-Host -ForegroundColor Cyan "   + $($System.Description.Name) : $($System.Owner) : $($System.Position)"
        }
        ""
    }
}






