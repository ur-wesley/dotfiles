# Wesley's PowerShell 7 profile — full fish-parity aliases and prompt.
# Synced by stow to ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1.
# Loaded automatically when pwsh starts.

# ---- Oh-My-Posh / PSReadLine / Predictive Intellisense -------------
# PSReadLine ships with PowerShell 7. Predictive IntelliSense gives us
# fish-like autosuggestions from history. Syntax highlighting too.
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -ShowToolTips

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key "Ctrl+d" -Function DeleteCharOrExit
Set-PSReadLineKeyHandler -Key "Ctrl+a" -Function BeginningOfLine
Set-PSReadLineKeyHandler -Key "Ctrl+e" -Function EndOfLine
Set-PSReadLineKeyHandler -Key "Ctrl+k" -Function KillLine
Set-PSReadLineKeyHandler -Key "Ctrl+u" -Function BackwardKillLine
Set-PSReadLineKeyHandler -Key "Ctrl+l" -Function ClearScreen
Set-PSReadLineKeyHandler -Key "Ctrl+r" -Function ReverseSearchHistory
Set-PSReadLineKeyHandler -Key "Alt+f" -Function ForwardWord
Set-PSReadLineKeyHandler -Key "Alt+b" -Function BackwardWord

# ---- External tools init (if available) ----------------------------
# starship — Catppuccin Mocha prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# zoxide — smart cd (`z` instead of `cd`)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (&zoxide init powershell | Out-String)
}

# fzf — Ctrl+R history, Ctrl+T files
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    Invoke-Expression (&fzf --man | Out-Null)
    $env:FZF_DEFAULT_OPTS = "--height 60% --layout=reverse --border --preview-window=right:60%"
}

# mise — runtime manager (shims are on PATH automatically after install)
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise use --global pwsh@latest | Out-Null
}

# atuin — history search (Ctrl+R replaces native search if installed)
if (Get-Command atuin -ErrorAction SilentlyContinue) {
    Invoke-Expression (&atuin init powershell | Out-String)
}

# ---- PATH additions ------------------------------------------------
$env:PATH = "$HOME\.local\bin;$HOME\scoop\shims;$env:PATH"

# ---- Sudo-like elevation via gsudo ---------------------------------
function gs { & gsudo @args }
function gse { & gsudo --edit @args }
function gsu { & gsudo -s @args }

# ---- File listing aliases (eza with icons) -------------------------
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ll { eza --icons --group-directories-first -l @args }
    function l  { eza --icons --group-directories-first @args }
    function lt { eza --icons --group-directories-first --tree --level=2 @args }
    function lta { eza --icons --group-directories-first --tree @args }
    function la { eza --icons --group-directories-first -la @args }
} else {
    # Fallback to built-in ls with color
    function ll { Get-ChildItem -Force @args | Format-Wide }
    function l  { Get-ChildItem @args }
}

# ---- File content aliases (bat / ripgrep / fd) ---------------------
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat { bat --style=plain --paging=never @args }
    function catp { bat --plain @args }
} else {
    function catp { Get-Content @args }
}

if (Get-Command rg -ErrorAction SilentlyContinue) {
    function grep { rg @args }
    Set-Alias -Name search -Value rg -Force
} else {
    function grep { Select-String @args }
}

if (Get-Command fd -ErrorAction SilentlyContinue) {
    function find { fd @args }
} else {
    function find { Get-ChildItem -Recurse @args }
}

# ---- System utilities ---------------------------------------------
if (Get-Command dust -ErrorAction SilentlyContinue) {
    function du { dust @args }
}
if (Get-Command duf -ErrorAction SilentlyContinue) {
    function df { duf @args }
}
if (Get-Command procs -ErrorAction SilentlyContinue) {
    function ps { procs @args }
}
if (Get-Command btop -ErrorAction SilentlyContinue) {
    function top { btop }
}

# ---- Editor / IDE --------------------------------------------------
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name vim -Value nvim -Force
    Set-Alias -Name vi -Value nvim -Force
    function v { nvim @args }
}
Set-Alias -Name code -Value code -Force
function code-wsl { wsl -d NixOS -- code @args }

# ---- Git aliases + helper -----------------------------------------
if (Get-Command git -ErrorAction SilentlyContinue) {
    function g { & git @args }
    function gst { git status @args }
    function gco { git checkout @args }
    function gp  { git push @args }
    function gl  { git pull @args }
    function gc  { git commit @args }
    function ga  { git add @args }
    function gd  { git diff @args }
    function gds { git diff --staged @args }
    function gb  { git branch @args }
    function glg { git log --oneline --graph --decorate -20 @args }

    Set-Alias -Name lg -Value lazygit -Scope Global -Force -ErrorAction SilentlyContinue
}

# ---- Docker / k8s --------------------------------------------------
if (Get-Command docker -ErrorAction SilentlyContinue) {
    function d  { docker @args }
    function dc { docker compose @args }
}
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    function k { kubectl @args }
}
if (Get-Command kubectx -ErrorAction SilentlyContinue) {
    function kctx { kubectx @args }
}
if (Get-Command kubens -ErrorAction SilentlyContinue) {
    function kns { kubens @args }
}
if (Get-Command lazydocker -ErrorAction SilentlyContinue) {
    Set-Alias -Name ld -Value lazydocker -Scope Global -Force
}

# ---- AI tools ------------------------------------------------------
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Set-Alias -Name cc -Value claude -Scope Global -Force
}
if (Get-Command opencode -ErrorAction SilentlyContinue) {
    Set-Alias -Name oc -Value opencode -Scope Global -Force
}
if (Get-Command gentle-ai -ErrorAction SilentlyContinue) {
    Set-Alias -Name ga -Value gentle-ai -Scope Global -Force
}
if (Get-Command tv -ErrorAction SilentlyContinue) {
    Set-Alias -Name tv -Value tv -Scope Global -Force
}

# ---- Cheatsheet ----------------------------------------------------
if (Get-Command navi -ErrorAction SilentlyContinue) {
    Set-Alias -Name cheat -Value navi -Scope Global -Force
}
if (Get-Command tldr -ErrorAction SilentlyContinue) {
    function tldr { & tldr @args }
}

# ---- Helpers -------------------------------------------------------
function mkcd { param($dir) New-Item -ItemType Directory -Path $dir -Force | Out-Null; Set-Location $dir }
function extract { param($file)
    if ($file -match '\.tar\.gz$|\.tgz$') { tar -xzf $file }
    elseif ($file -match '\.tar\.bz2$')    { tar -xjf $file }
    elseif ($file -match '\.zip$')          { Expand-Archive -Path $file -DestinationPath . }
    elseif ($file -match '\.gz$')           { gunzip $file }
    else { Write-Error "Unknown archive: $file" }
}

# ---- Zellij --------------------------------------------------------
if (Get-Command zellij -ErrorAction SilentlyContinue) {
    function zj { zellij attach --create @args }
}

# ---- NixOS rebuild (called from WSL) -------------------------------
function nrs {
    wsl -d NixOS -u wesley -- bash -lc "cd ~ && sudo nixos-rebuild switch --flake ~/nix-config#nixos-wsl"
}

# ---- Welcome message ------------------------------------------------
Write-Host "PowerShell 7 — fish-parity profile loaded. Type 'll' to test eza." -ForegroundColor DarkGray