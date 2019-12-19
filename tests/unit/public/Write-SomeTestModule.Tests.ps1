#Requires -Modules Pester
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

# Since we match the srs/tests stucture we can use this to dotsource the function.
$here = $here -replace 'tests\\unit', 'src'

. "$here\$sut"

Describe "Testing Write-SomeTestModule" -Tags @('UnitTest') {
    it "Should return a specific string: (Yerp. This is a function.)" {
        $result = Write-SomeTestModule
        $result | Should -Be "Yerp. This is a function."
    }
}