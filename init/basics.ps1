# Varialbles
try {
    $user_path = (Get-Item $env:OneDrive).Parent.FullName
} catch {
    $user_path = (Get-Item $env:HOMEPATH).FullName
}

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
        if (@(Get-ChildItem -Force -Path $dir -Name) -contains ".git") { return $dir }
        try { $dir = (Get-Item -Force $dir).Parent.FullName } catch { break }
    }
    return 0
}
function git_branch {
    $git_root = git_root
    if ($git_root -ne 0) {
        try {
            $git_head = Get-Item -Force $git_root\.git\HEAD
            return @(@(Get-Content $git_head)[0] -split "/")[-1]
        } catch { }
    }
    return 0
}
## Set-Location
function cda {Set-Location D:\App}
function cdd {Set-Location $user_path\Desktop}
function cdh {Set-Location $user_path}
function cdr {Set-Location $user_path\Documents\Repos}
function cdt {Set-Location $user_path\TimeLine}
function cdg {
    $git_rt = git_root
    if ($git_rt -eq 0) {
        "Not a git repository."
    } else {
        Set-Location $git_rt
    }
}
