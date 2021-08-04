## Frequently used app
Set-Alias vi       nvim.exe
Set-Alias vim      nvim.exe
Set-Alias emx      runemacs.exe
Set-Alias bld      blender.exe

# Emacs(Win) really sucks!
function enw {
    chcp 936
    emacs.exe -nw $args
}

# Neovim
function gvim  { nvim-qt.exe -- }
function vims  { nvim.exe -S $args }
function gvims { nvim-qt.exe -- -S $args }
function vim.  { nvim.exe $executionContext.SessionState.Path.CurrentLocation }
function gvim. { nvim-qt.exe $executionContext.SessionState.Path.CurrentLocation }
function nano  { nvim.exe --cmd "let g:init_src='nano'" $args }
function gnano { nvim-qt.exe -qwindowgeometry 720x900 -- --cmd "let g:nvim_init_src='nano'" $args }

# Rust
$RUSTUP_DIST_SERVER = "https://mirrors.tuna.tsinghua.edu.cn/rustup"
