#Save-Module -Name VstsTaskSdk -Path ..\chromium-task\ps_modules\


#Import-Module ..\chromium-task\ps_modules\VstsTaskSdk


Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create('. ..\chromium-task\download-chromium.ps1')) -Verbose