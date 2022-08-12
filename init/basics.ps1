# Varialbles
$user_path = if (Test-Path env:OneDrive) {
    (Get-Item $env:OneDrive).Parent.FullName
}
else {
    (Get-Item $env:HOMEPATH).FullName
}

# Alias
## System function
Set-Alias exp      explorer.exe
Set-Alias poweroff Stop-Computer
Set-Alias reboot   Restart-Computer
## Unix-shell-like command
Set-Alias touch    New-Item
Set-Alias grep     findstr

# Shortcut
Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit
Set-PSReadLineOption -EditMode Emacs

# Function
## Show all{
function la { Get-ChildItem -Force }
## Call explore.exe
function exp. { explorer . }
## Code page
function chcp {
    if ($args.Count -eq 0) {
        chcp.com
    }
    else {
        try {
            $OutputEncoding =
            [System.Console]::InputEncoding =
            [System.Console]::OutputEncoding =
            [Text.Encoding]::GetEncoding($args[0])
        }
        catch {
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
        }
        catch { }
    }
    return 0
}
## Set-Location
function cdd { Set-Location $user_path\Desktop }
function cdh { Set-Location $user_path }
function cdg {
    $git_root = git_root
    if ($git_root -eq 0) {
        "Not a git repository"
    }
    else {
        Set-Location $git_root
    }
}
## Proxy
function editConfig {
    if ($args.Count -eq 3) {
        $file_path = $args[0]
        $pattern = $args[1]
        $new_line = $args[2]
        $file_content = Get-Content $file_path
        if (($file_content | ForEach-Object { $_ -match $pattern }) -contains $true) {
            $file_content -replace $pattern, $new_line | Set-Content $file_path
        }
        else {
            Add-Content -Path $file_path -Value $new_line
        }
    }
    elseif ($args.Count -eq 2) {
        $file_path = $args[0]
        $pattern = $args[1]
        $file_content -replace $pattern, "" | Set-Content $file_path
    }
    else {
        "Invalid argument"
    }
}
function proxy {
    git.exe config --global http.proxy http://127.0.0.1:10809
    git.exe config --global https.proxy http://127.0.0.1:10809
    editConfig $HOME\.curlrc '^proxy\s*=\s*.*$' "proxy=http://127.0.0.1:10809"
}
function unproxy {
    git.exe config --global --unset http.proxy
    git.exe config --global --unset https.proxy
    editConfig $HOME\.curlrc '^proxy\s*=\s*.*$'
}