#requires -version 3
param([DateTime]$TimeFinished)

# Modify the code below to suit your needs

if ($UseFinishHook){
    &$FinishPath $TimeFinished
}