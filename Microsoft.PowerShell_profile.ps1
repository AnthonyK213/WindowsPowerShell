# Source config
if (Test-Path $PSScriptRoot\config.ps1 -PathType Leaf) {
  . $PSScriptRoot\config.ps1
}

# Key bindings.
Set-PSReadLineOption     -EditMode Emacs
Set-PSReadlineKeyHandler -Key Tab        -Function MenuComplete
Set-PSReadlineKeyHandler -Key UpArrow    -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow  -Function HistorySearchForward
Set-PSReadlineKeyHandler -Chord "Ctrl+d" -Function DeleteCharOrExit

# Alias
## System function
Set-Alias exp      explorer.exe
Set-Alias poweroff Stop-Computer
Set-Alias reboot   Restart-Computer
## Unix-like command
Set-Alias touch New-Item
Set-Alias grep  findstr

# Set-Location
function cdd {
  $desktopPath = [Environment]::GetFolderPath("Desktop")
  Set-Location $desktopPath
}
function cdh {
  $personalPath = [Environment]::GetFolderPath("Personal")
  Set-Location (Get-Item $personalPath).Parent.FullName
}
function cdg {
  $gitRoot = get_git_root
  if ($gitRoot -eq 0) {
    "Not a git repository"
  } else {
    Set-Location $gitRoot
  }
}

# Change code page.
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
function exp. { explorer.exe . }

# Get git root. If not a git repository, return 0.
function get_git_root {
  $dir = $executionContext.SessionState.Path.CurrentLocation.Path
  while (1) {
    if (Test-Path "$dir\.git" -PathType Container) { return $dir }
    try { $dir = (Get-Item -Force $dir).Parent.FullName } catch { break }
  }
  return 0
}

# Get git branch. If not a git repository, return 0.
function get_git_branch {
  $gitRoot = get_git_root
  if ($gitRoot -ne 0) {
    try {
      $gitHead = Get-Item -Force $gitRoot\.git\HEAD
      return @(@(Get-Content -Encoding utf8 $gitHead)[0] -split "/")[-1]
    }
    catch { }
  }
  return 0
}

# Edit a config file according to a regex pattern.
# edit_config_file(filePath, pattern, replace)
function edit_config_file {
  if ($args.Count -eq 3) {
    $filePath = $args[0]
    $pattern  = $args[1]
    $newLine  = $args[2]
    if (Test-Path $filePath -PathType Leaf) {
      $fileContent = Get-Content $filePath
      if (($fileContent | ForEach-Object { $_ -match $pattern }) -contains $true) {
        $fileContent -replace $pattern, $newLine | Set-Content $filePath
      } else {
        Add-Content -Path $filePath -Value $newLine
      }
    }
  } elseif ($args.Count -eq 2) {
    $filePath = $args[0]
    $pattern  = $args[1]
    if (Test-Path $filePath -PathType Leaf) {
      $fileContent -replace $pattern, "" | Set-Content $filePath
    }
  } else {
    "Invalid argument"
  }
}

# Set porxy.
function proxy {
  if ($null -eq $USER_PROXY) {
    Write-Host "USER_PROXY was not set"
    return
  }
  $env:HTTPS_PROXY = $USER_PROXY
  $env:HTTP_PROXY  = $USER_PROXY
  $env:ALL_PROXY   = $USER_PROXY
  git config --global http.proxy  $USER_PROXY
  git config --global https.proxy $USER_PROXY
  edit_config_file $HOME\.curlrc '^proxy\s*=\s*.*$' "proxy=$USER_PROXY"
  Write-Host "Set proxy to $USER_PROXY"
}

# Unset proxy.
function unproxy {
  $env:HTTPS_PROXY = $null
  $env:HTTP_PROXY  = $null
  $env:ALL_PROXY   = $null
  git config --global --unset http.proxy
  git config --global --unset https.proxy
  edit_config_file $HOME\.curlrc '^proxy\s*=\s*.*$'
  Write-Host "Unset proxy"
}

# Neovim
function vim  { nvim --cmd "let g:nvim_init_src=''"     $args }
function nano { nvim --cmd "let g:nvim_init_src='nano'" $args }

# Prompt style, color scheme from `onedark`.
function prompt {
  $exitOk    = $?
  $exitCode  = $LASTEXITCODE
  $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal] $identity
  $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
  $isAdmin   = $principal.IsInRole($adminRole)

  $location  = $executionContext.SessionState.Path.CurrentLocation
  $dirName   = Split-Path $location -leaf
  $time      = Get-Date -Format "HH:mm"
  $OutputEnc = [System.Console]::InputEncoding = [System.Console]::OutputEncoding
  $codepage  = $OutputEnc.BodyName
  $gitBranch = get_git_branch
  $gitStatus = $(git status --porcelain)

  $host.UI.RawUI.WindowTitle = if ($isAdmin) { "[ADMIN] $dirName" } else { "$dirName" }

  $ESC        = [char]27
  $FG_DEFAULT = "$ESC[39m"
  $FG_BLACK   = "$ESC[30m"
  $FG_RED     = "$ESC[38;5;204m"
  $FG_YELLOW  = "$ESC[38;5;180m"
  $FG_BLUE    = "$ESC[38;5;39m"
  $FG_CYAN    = "$ESC[38;5;38m"
  $FG_GREY    = "$ESC[38;5;8m"
  $FG_GREEN   = "$ESC[38;5;114m"

  $gitInfo = if ($gitBranch -ne 0) {
    "$FG_GREY" + "on$FG_DEFAULT git:$FG_CYAN$gitBranch" +
      $(if ($gitStatus -match '^\?\?') { "$FG_YELLOW U " }
          elseif ($gitStatus -match '^ M') { "$FG_RED M " }
          else { "$FG_GREEN o " }) 
  }

  Write-Host("$FG_DEFAULT$env:CONDA_PROMPT_MODIFIER" +
        "$FG_BLUE" + "PS-[$codepage]" + $(if ($isAdmin)
        { "$FG_RED [ADMIN] $FG_GREY@ $FG_RED$env:ComputerName" } else
        { "$FG_CYAN $env:UserName $FG_GREY@ $FG_GREEN$env:ComputerName" }) +
      "$FG_GREY in $FG_YELLOW$location $gitInfo" + "$FG_DEFAULT[$time]" +
      $(if (-Not $exitOk) { "$FG_DEFAULT C: $FG_RED$exitCode " }))

  return "$FG_RED>" * ($nestedPromptLevel + 1) + "$FG_DEFAULT "
}
