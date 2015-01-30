# https://github.com/driftyco/front-page/
# git@github.com:driftyco/front-page.git

[CmdletBinding(DefaultParameterSetName = 'URI',
			   SupportsShouldProcess = $true,
			   ConfirmImpact = 'Medium')]
Param
(
	[Parameter(Mandatory = $true,
			   ValueFromPipeline = $true,
			   HelpMessage = '请输入 ID，多个 ID 请用逗号隔开')]
	[string[]]
	$Uri
)

$DebugPreference = 'Continue' # Continue, SilentlyContinue
# $ProgressPreference='SilentlyContinue'
# $WhatIfPreference = $true # $true, $false

function ReformatUri($uri) {
    if ($uri -cmatch '^[\w-]+/[\w-]+$') {
        $uri = 'git@github.com:{0}.git' -f $uri
    }

    return $uri
}

function CloneProject($uri) {
    git.exe clone $uri
    return $LASTEXITCODE -eq 0
}

function GetDirectoryName($uri) {
    if ($uri -cmatch '[^:/](?<USER_NAME>[\w-]+)/(?<REPO_NAME>[\w-]+)(?:\.git)?/?$') {
        return $Matches.REPO_NAME
    } else {
        return $null
    }
}

$Uri | ForEach-Object {
    Push-Location
    
    $uriItem = $_
    $uriItem = ReformatUri($uriItem)
    Write-Debug $uriItem

    $result = CloneProject($uriItem)
    if (!$result) {
        #Pop-Location
        #return
    }

    $dirName = GetDirectoryName($uriItem)
    Set-Location $dirName

    npm.cmd install

    bower.cmd install

    Pop-Location
    # 7z a archive2.zip .\subdir\*
    $allArgs = @('a', "$dirName.7z", ".\$dirName\*")
    & 'util\7za.exe' $allArgs

    Remove-Item $dirName -Recurse -WhatIf
}