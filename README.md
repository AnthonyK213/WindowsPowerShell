# Configuration of powershell
* Allow scripts at first (in admin mode)
  ``` ps1
  Set-ExecutionPolicy RemoteSigned
  # `Set-ExecutionPolicy Restricted` by default
  ```