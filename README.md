<p align="center">
  <img alt="Neovim" src="https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/ps_black_64.svg" height="80" />
  <p align="center">Powershell Configuration</p>
</p>

---

# Installation

- Requirements
  - [Powershell](https://github.com/PowerShell/PowerShell), any version
  - [Git](https://github.com/git/git)
  - Allow scripts (in admin mode)
    ``` ps1
    Set-ExecutionPolicy RemoteSigned
    # `Set-ExecutionPolicy Restricted` to reset
    ```

- Clone repository
  ``` ps1
  $MyDocuments = [Environment]::GetFolderPath("MyDocuments")
  git clone --depth=1 https://github.com/AnthonyK213/WindowsPowerShell `
                      "$MyDocuments\PowerShell"
  ```

# Configuration

You can add personal configurations in `.\config.ps1`.

| variable   | description                   |
|------------|-------------------------------|
| USER_PROXY | Proxy to set for applications |
