## Prompt
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

    $host.UI.RawUI.WindowTitle = if ($isAdmin) { "[ADMIN] $dirName" } else { "$dirName" }

    ### Text Formatting
    $ESC = [char]27

    $a_deft = "$ESC[0m"
    $f_deft = "$ESC[39m"
    $b_deft = "$ESC[49m"

    $f_black  = "$ESC[30m"
    $f_red    = "$ESC[38;5;204m"
    $f_yellow = "$ESC[38;5;180m"
    $f_blue   = "$ESC[38;5;39m"
    #$f_cyan   = "$ESC[38;5;38m"
    $f_grey   = "$ESC[38;5;59m"

    $b_red    = "$ESC[48;5;204m"
    $b_yellow = "$ESC[48;5;180m"
    $b_blue   = "$ESC[48;5;39m"
    #$b_cyan   = "$ESC[48;5;38m"
    $b_grey   = "$ESC[48;5;59m"

    $SegmentSymbol = [char]::ConvertFromUtf32(0xE0B8)
    
    Write-Host("$b_grey $time $f_grey$b_blue$SegmentSymbol$f_black$b_blue PS-[$codepage] " + 
               $(if ($isAdmin) { 
                     "$f_blue$b_red$SegmentSymbol $f_deft[ADMIN]@$env:ComputerName $f_red$b_deft$SegmentSymbol" 
                 } else { 
                     "$f_blue$b_yellow$SegmentSymbol $f_black$env:UserName@$env:ComputerName $f_yellow$b_deft$SegmentSymbol" 
                 }) + " $a_deft$location")
    return ">" * ($nestedPromptLevel + 1) + " "
}
