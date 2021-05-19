function prompt {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $isAdmin   = $principal.IsInRole($adminRole)

    $location = $executionContext.SessionState.Path.CurrentLocation
    $dirName = Split-Path $location -leaf
    $time = Get-Date -Format "HH:mm"
    $OutputEncoding = [System.Console]::InputEncoding = [System.Console]::OutputEncoding
    $codepage = $OutputEncoding.BodyName
    $git_branch = git_branch
    $git_status = $(git status --porcelain)

    $host.UI.RawUI.WindowTitle = if ($isAdmin) { "[ADMIN] $dirName" } else { "$dirName" }

    $ESC = [char]27
    $f_deft   = "$ESC[39m"
    $f_black  = "$ESC[30m"
    $f_red    = "$ESC[38;5;204m"
    $f_yellow = "$ESC[38;5;180m"
    $f_blue   = "$ESC[38;5;39m"
    $f_cyan   = "$ESC[38;5;38m"
    $f_grey   = "$ESC[38;5;8m"
    $f_green  = "$ESC[38;5;114m"

    # Git information
    $git_info = if ($git_branch -ne 0) {
                    "$f_grey" + "on$f_deft git:$f_cyan$git_branch" +
                    $(if ($git_status -match '^\?\?') { "$f_yellow U " }
                      elseif ($git_status -match '^ M') { "$f_red M " }
                      else { "$f_green o " }) }


    Write-Host("$f_blue" + "PS-[$codepage]" + $(if ($isAdmin)
               { "$f_red [ADMIN] $f_grey@ $f_red$env:ComputerName" } else
               { "$f_cyan $env:UserName $f_grey@ $f_green$env:ComputerName" }) +
                 "$f_grey in $f_yellow$location $git_info" + "$f_deft[$time]")

    return "$f_red>" * ($nestedPromptLevel + 1) + "$f_deft "
}
