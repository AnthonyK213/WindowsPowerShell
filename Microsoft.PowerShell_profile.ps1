# Varialbles
if (Test-Path $PSScriptRoot\config.ps1 -PathType Leaf) {
  . $PSScriptRoot\config.ps1
}
$user_path = if (Test-Path env:OneDrive) {
  (Get-Item $env:OneDrive).Parent.FullName
} else {
  (Get-Item $env:HOMEPATH).FullName
}
$RUSTUP_DIST_SERVER = "https://mirrors.tuna.tsinghua.edu.cn/rustup"

# Key bindings.
Set-PSReadLineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit

# Alias
## System function
Set-Alias exp      explorer.exe
Set-Alias poweroff Stop-Computer
Set-Alias reboot   Restart-Computer
## Unix-shell-like command
Set-Alias touch New-Item
Set-Alias grep  findstr
# Applications
Set-Alias vi  nvim.exe
Set-Alias vim nvim.exe
Set-Alias bld blender.exe

# Set-Location
function cdd { Set-Location $user_path\Desktop }

function cdh { Set-Location $user_path }

function cdg {
  $git_root = git_root
  if ($git_root -eq 0) {
    "Not a git repository"
  } else {
    Set-Location $git_root
  }
}

# Code page.
function chcp {
  if ($args.Count -eq 0) {
    chcp.com
  } else {
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

# `ls -a`
function la { Get-ChildItem -Force }

# Launch `explore.exe`.
function exp. { explorer . }

# Get git root. If not a git repository, return 0.
function git_root {
  $dir = $executionContext.SessionState.Path.CurrentLocation.Path
  while (1) {
    if (Test-Path "$dir\.git" -PathType Container) { return $dir }
    try { $dir = (Get-Item -Force $dir).Parent.FullName } catch { break }
  }
  return 0
}

# Get git branch. If not a git repository, return 0.
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

# Edit a config file according to a regex pattern.
# editConfig(file_path, pattern, replace)
function editConfig {
  if ($args.Count -eq 3) {
    $file_path = $args[0]
    $pattern = $args[1]
    $new_line = $args[2]
    $file_content = Get-Content $file_path
    if (($file_content | ForEach-Object { $_ -match $pattern }) -contains $true) {
      $file_content -replace $pattern, $new_line | Set-Content $file_path
    } else {
      Add-Content -Path $file_path -Value $new_line
    }
  } elseif ($args.Count -eq 2) {
    $file_path = $args[0]
    $pattern = $args[1]
    $file_content -replace $pattern, "" | Set-Content $file_path
  } else {
    "Invalid argument"
  }
}

# Configure the porxy.
function proxy {
  git.exe config --global http.proxy $user_proxy
  git.exe config --global https.proxy $user_proxy
  editConfig $HOME\.curlrc '^proxy\s*=\s*.*$' "proxy=$user_proxy"
}

# No proxy.
function unproxy {
  git.exe config --global --unset http.proxy
  git.exe config --global --unset https.proxy
  editConfig $HOME\.curlrc '^proxy\s*=\s*.*$'
}

# Neovim
function gvim { nvim-qt.exe -- }

function vims { nvim.exe -S $args }

function gvims { nvim-qt.exe -- -S $args }

function vim. { nvim.exe $executionContext.SessionState.Path.CurrentLocation }

function gvim. { nvim-qt.exe $executionContext.SessionState.Path.CurrentLocation }

function nano { nvim.exe --cmd "let g:nvim_init_src='nano'" $args }

function gnano { nvim-qt.exe -qwindowgeometry 1280x800 -- --cmd "let g:nvim_init_src='nano'" $args }

# Prompt style, color scheme from `onedark`.
function prompt {
  $exitOk = $?
  $exitCode = $LASTEXITCODE
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal] $identity
  $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
  $isAdmin = $principal.IsInRole($adminRole)

  $location = $executionContext.SessionState.Path.CurrentLocation
  $dirName = Split-Path $location -leaf
  $time = Get-Date -Format "HH:mm"
  $OutputEncoding = [System.Console]::InputEncoding = [System.Console]::OutputEncoding
  $codepage = $OutputEncoding.BodyName
  $git_branch = git_branch
  $git_status = $(git status --porcelain)

  $host.UI.RawUI.WindowTitle = if ($isAdmin) { "[ADMIN] $dirName" } else { "$dirName" }

  $ESC = [char]27
  $f_deft = "$ESC[39m"
  $f_black = "$ESC[30m"
  $f_red = "$ESC[38;5;204m"
  $f_yellow = "$ESC[38;5;180m"
  $f_blue = "$ESC[38;5;39m"
  $f_cyan = "$ESC[38;5;38m"
  $f_grey = "$ESC[38;5;8m"
  $f_green = "$ESC[38;5;114m"

  $git_info = if ($git_branch -ne 0) {
    "$f_grey" + "on$f_deft git:$f_cyan$git_branch" +
      $(if ($git_status -match '^\?\?') { "$f_yellow U " }
          elseif ($git_status -match '^ M') { "$f_red M " }
          else { "$f_green o " }) 
  }

  Write-Host("$f_blue" + "PS-[$codepage]" + $(if ($isAdmin)
        { "$f_red [ADMIN] $f_grey@ $f_red$env:ComputerName" } else
        { "$f_cyan $env:UserName $f_grey@ $f_green$env:ComputerName" }) +
      "$f_grey in $f_yellow$location $git_info" + "$f_deft[$time]" +
      $(if (-Not $exitOk) { "$f_deft C: $f_red$exitCode " }))

  return "$f_red>" * ($nestedPromptLevel + 1) + "$f_deft "
}
