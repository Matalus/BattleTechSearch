
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

$SystemDef = Get-ChildItem $RunDir\Data\starsystem

$SystemData = @()

Log "Importing Star System Data..."
ForEach ($star in $SystemDef) {
    $SystemData += (Get-Content $star.FullName) -join "`n" | ConvertFrom-Json
}

Log "System Data Imported..."

ForEach ($System in $SystemData[0..9]) {
    ""
    $TagExceptions = @(
        "planet_progress_2",
        "planet_name_aea_flipped",
        "planet_name_antias"
    )

    $Tags = (($System.Tags.items | Where-Object {
                $_ -notin $TagExceptions -and
                $_ -notlike "planet_name*" 
            }) -join ", ").Replace("planet_", "").Replace("_", " ").Replace("industry", "").Replace("other", "").Replace("faction", " <p><b>Faction:")
    $Employers = $System.ContractEmployers -join ", "
    $Biomes = $System.SupportedBiomes -join ", "
    $SystemStr = @"
    <p>System Name: http://System.Description.Name </p>
    <p>Star Type: $($System.StarType)
    <p>Description: $($System.Description.Details)</p>
    <p>Owner: $($System.Owner)</p>
    <p>Tags: $Tags</p>
    <p>Employers: $Employers</p>
    <p>Biomes: $Biomes</p>
"@
    $SystemStr
}
