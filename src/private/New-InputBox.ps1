Function New-InputBox {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="Just an Test Module")]
    Param (
        [String]$Title = 'Something',
        [String]$Msg = 'You should enter something'
    )
    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $Output  = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
    Return $Output
}