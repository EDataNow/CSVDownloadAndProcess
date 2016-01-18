#requires -version 3
param([DateTime]$timeFinished)

# Modify the code below to suit your needs

if ($useFinishHook){
    &$finishPath $timeFinished
}