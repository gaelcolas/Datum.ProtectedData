$here = $PSScriptRoot
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$modulePath = "$here\..\..\.."
$moduleName = Split-Path -Path $modulePath -Leaf

InModuleScope $moduleName {
    Describe Protect-Datum {
        #Mock Get-PrivateFunction { $PrivateData }

        Context 'true' {

            It 'Does not call Get-PrivateFunction if WhatIf is set' {
                $true | SHould -be $true
            }
        }
    }
}