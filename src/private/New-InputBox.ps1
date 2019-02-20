Function New-InputBox {
    [CmdletBinding()]
    Param (
        [String]$Title = 'Something',
        [String]$Msg = 'You should enter something'
    )
    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $Output  = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
    Return $Output
}