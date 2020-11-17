## Frequently used app
Set-Alias vi       nvim.exe
Set-Alias vim      nvim.exe
Set-Alias gvim     nvim-qt.exe
Set-Alias emx      runemacs.exe
Set-Alias bld      blender.exe

# Emacs(Win) really sucks!
function enw {
    chcp 936
    emacs.exe -nw $args
}

# For vim worksession
function vims  { nvim.exe -S $args }
function vim.  { nvim.exe $executionContext.SessionState.Path.CurrentLocation }
function gvims { nvim-qt.exe -- -S $args }