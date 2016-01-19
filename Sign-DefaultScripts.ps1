$defaultScripts = '.\DAPr-CSV.ps1', '.\config\Config.ps1', '.\Functions.ps1', '.\Hook-Process.ps1', '.\Hook-Failure.ps1', '.\Hook-Finish.ps1'
forEach ($script in $sefaultScripts){
    Set-AuthenticodeSignature $script @(Get-ChildItem cert:\CurrentUser\My -codesign)[0]
}