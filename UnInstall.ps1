if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Check-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

Write-Host ""
Write-Host "Remove 'This PC' Desktop Icon..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$thisPCIconRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$thisPCRegValname = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" 
$item = Get-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -ErrorAction SilentlyContinue 
if ($item) { 
    Remove-ItemProperty  -Path $thisPCIconRegPath -name $thisPCRegValname  
} 

# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "UnInstalling IIS..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Disable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument -All
Disable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionDynamic -All
Disable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic -All
Disable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets -All
Disable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit -All
Disable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -All
Disable-WindowsOptionalFeature -Online -FeatureName IIS-ServerSideIncludes
Disable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
Disable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication

if (Check-Command -cmdname 'choco') {
    Write-Host "Choco is already installed, skip installation."
}
else {
    Write-Host ""
    Write-Host "Installing Chocolate for Windows..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

Write-Host ""
Write-Host "Un-Installing Applications..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

$Apps = @(
    "7zip.install",
    "adobereader",
    "audacity",
    "azure-cli",
    "beyondcompare",
    "brave",
    "buffalo-nas-navigator",
    "chrome",
    "dotnetcore-sdk",
    "edge",
    "eraser",
    "ffmpeg",
    "fiddler",
    "filezilla",
    "firefox",
    "git",
    "github-desktop",
    "handbrake",
    "irfanview",
    "jenkins",
    "lightshot.install",
    "linqpad",
    "microsoft-teams.install",
    "miktex",
    "mongodb",
    "msbuild-structured-log-viewer",
    "msbuild.communitytasks",
    "msbuild.extensionpack",
    "nodejs",
    "notepadplusplus.install",
    "ojdkbuild",
    "ojdkbuild8",
    "openssl.light",
    "postman",
    "powershell-core",
    "putty",
    "resharper",
    "sketchup",
    "slack",
    "sql-server-management-studio",
    "sqlite",
    "sysinternals",
    "tortoisegit",
    "virtualbox",
    "visualstudio2017professional",
    "visualstudio2019professional",
    "vlc",
    "vnc-viewer",
    "vscode",
    "webex-meetings",
    "wget",
    "winmerge",
    "wixedit",
    "wixtoolset",
    "yarn",
    "zoom",
    "zoom-outlook")

foreach ($app in $Apps) {
    choco uninstall $app -y
}

Write-Host "------------------------------------" -ForegroundColor Green
Read-Host -Prompt "Setup is done, restart is needed, press [ENTER] to restart computer."
Restart-Computer