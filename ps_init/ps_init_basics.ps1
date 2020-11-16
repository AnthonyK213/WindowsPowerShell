# Varialbles
$user_path = (Get-Item $env:OneDrive).Parent.FullName

# Alias
## System function
Set-Alias exp      explorer.exe
Set-Alias poweroff Stop-Computer
Set-Alias reboot   Restart-Computer
## Xnix-shell-like command
Set-Alias touch    New-Item
Set-Alias grep     findstr

# Shortcut
Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit

# Function
## Show all
function la  {Get-ChildItem -Force}
## Call explorer.exe
function exp. {explorer .}
## Code page
function chcp {
    if ($args.Count -eq 0) {
        chcp.com
    } else {
        try {
            $OutputEncoding = 
            [System.Console]::InputEncoding = 
            [System.Console]::OutputEncoding =  
            [Text.Encoding]::GetEncoding($args[0])
        } catch {
            "Invalid code page"
        }
    } 
}
## Git util
function git_root {
    $dir = $executionContext.SessionState.Path.CurrentLocation.Path
    while (1) {
        $child = @(Get-ChildItem -Force -Path $dir -Name)
        if ($child -contains ".git") { return $dir }
        try {
            $crt = $dir
            $dir = (Get-Item -Force $dir).Parent.FullName
        } catch {
            break
        }    
    }
    #Write-Host "Not a git repository."
    return 0
}
function git_branch {
    $git_root = git_root
    if ($git_root -ne 0) {
        try {
            $git_head = Get-Item -Force $git_root\.git\HEAD
            $content = @(Get-Content $git_head)[0]
            $branch = @($content -split "/")[-1]
            return $branch
        } catch {
            #"Not a valid git repository."
        }
    }
    return 0
}
## Set-Location
function cda {Set-Location D:\App}
function cdd {Set-Location $user_path\Desktop}
function cdh {Set-Location $user_path}
function cdr {Set-Location $user_path\Documents\Repos}
function cdt {Set-Location $user_path\TimeLine}
