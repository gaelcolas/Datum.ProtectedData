$here = $PSScriptRoot
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$modulePath = "$here\..\..\.."
$moduleName = Split-Path -Path $modulePath -Leaf

InModuleScope $moduleName {
    Describe Invoke-ProtectedDatumAction {
       # Mock Get-PrivateFunction { $PrivateData }

        Context 'True' {

            It 'true' {
                $true | Should -be $true
            }
        }
    }
}