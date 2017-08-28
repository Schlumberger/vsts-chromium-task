# Schlumberger Public

#[CmdletBinding()]
#param(
#    [string] $account,
#    [string] $accesstoken,
#    [string] $matchProcessTemplates
#)
#$account = Get-VstsInput -Name account -Require
#$matchProcessTemplates = Get-VstsInput -Name matchProcessTemplates -Require
#$accesstoken = Get-VstsInput -Name processTemplateService -Require

#Write-VstsTaskVerbose "Account: $account" 
#Write-VstsTaskVerbose "matchProcessTemplates: $matchProcessTemplates" 
#Write-VstsTaskVerbose "accesstoken: $accesstoken" 

Trace-VstsEnteringInvocation $MyInvocation

try {

    [string] $InstallPath = Get-VstsInput -Name "unpackFolder"

    function UnescapeUri($uriString) {
        $uri = New-Object System.Uri -ArgumentList ($uriString)
        $UnEscapeDotsAndSlashes = 0x2000000;
        $SimpleUserSyntax = 0x20000;

        $type = $uri.GetType();
        $fieldInfo = $type.GetField("m_Syntax", ([System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic));

        $uriParser = $fieldInfo.GetValue($uri);
        $typeUriParser = $uriParser.GetType().BaseType;
        $fieldInfo = $typeUriParser.GetField("m_Flags", ([System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::FlattenHierarchy));
        $uriSyntaxFlags = $fieldInfo.GetValue($uriParser);

        $uriSyntaxFlags = $uriSyntaxFlags -band (-bnot $UnEscapeDotsAndSlashes);
        $uriSyntaxFlags = $uriSyntaxFlags -band (-bnot $SimpleUserSyntax);
        $fieldInfo.SetValue($uriParser, $uriSyntaxFlags);
        
        return $uri
    }

    $LastChangeUri = UnescapeUri "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Win_x64%2FLAST_CHANGE?alt=media"
    $Revision = "496644" # Current latest (23.08.2017) as fallback

    Write-VstsTaskVerbose "Getting latest revision from '$LastChangeUri'"
    try {
        $Revision = (Invoke-WebRequest $LastChangeUri -UseBasicParsing).Content
    }
    catch {
        Write-Output $_.Exception|format-list -force
    }

    Write-VstsTaskVerbose "Latest revision is '$Revision'"

    $CurrentPath = Join-Path $MyInvocation.MyCommand.Path .. -Resolve
    $ZipUri = UnescapeUri "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Win_x64%2F$Revision%2Fchrome-win32.zip?&alt=media"
    $ZipFile = Join-Path $CurrentPath "chrome.zip"

    Write-VstsTaskVerbose "Downloading '$ZipUri' to '$ZipFile'"
    try {
        Invoke-WebRequest -Uri $ZipUri -OutFile $ZipFile
    }
    catch {
        Write-Output $_.Exception|format-list -force
    }

    if (-not $InstallPath) {
        $InstallPath = Join-Path $env:LOCALAPPDATA "Chromium"
    }

    Write-Output "Extracting Chromium to '$InstallPath'."

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $InstallPath)

    $ChromePath = "$InstallPath\chrome-win32\chrome.exe"

    Write-VstsTaskVerbose "Setting environment variables CHROMIUM_BIN and CHROME_BIN to '$ChromePath'."

    Set-VstsTaskVariable "CHROMIUM_BIN" $ChromePath
    Set-VstsTaskVariable "CHROME_BIN" $ChromePath
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}

