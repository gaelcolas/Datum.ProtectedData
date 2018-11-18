$here = $PSScriptRoot
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$modulePath = "$here\..\..\.."
$moduleName = Split-Path -Path $modulePath -Leaf

InModuleScope $moduleName {
    Describe Test-ProtectedDatumFilter {
        #Mock Get-PrivateFunction { $PrivateData }

        Context 'Return values' {
            It 'true' {
                $true | Should -be $true
            }
        }
    }
}