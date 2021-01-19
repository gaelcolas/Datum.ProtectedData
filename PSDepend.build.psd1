@{
    # Set up a mini virtual environment...
    PSDependOptions  = @{
        AddToPath  = $True
        Target     = 'BuildOutput\modules'
        Parameters = @{
        }
    }

    buildhelpers     = 'latest'
    invokeBuild      = 'latest'
    pester           = '4.10.1'
    PSScriptAnalyzer = 'latest'
    PlatyPS          = 'latest'
    psdeploy         = 'latest'

    ProtectedData    = 'latest'
}