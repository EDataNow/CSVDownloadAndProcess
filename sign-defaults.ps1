$defaultScripts = '.\csv_download_and_process.ps1', '.\config\config.ps1', '.\functions.ps1', '.\process_hook.ps1', '.\failure_hook.ps1', '.\finish_hook.ps1'
$autoSign = '.\sign-script.ps1'

forEach ($script in $defaultScripts){
    &$autoSign $script
}