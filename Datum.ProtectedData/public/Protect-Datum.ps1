#Requires -Modules ProtectedData

function Protect-Datum {
    <#
    .SYNOPSIS
    Protects an object into an encrypted string ready to use in a text file (yaml, JSON, PSD1)

    .DESCRIPTION
    This command will serialize (i.e. Export-CLIXml) and object, base 64 encode it and then encrypt
    so that it can be used as a string in a text-based file, like a Datum config file.

    .PARAMETER InputObject
    The object to provide to be encrypted and secured.

    .PARAMETER Password
    ! FOR TESTING ONLY! Password to encrypt the data.

    .PARAMETER Certificate
    Certificate as supported by Dave Wyatt's ProtectedData module: Certificate File, thumbprint, path to file...

    .PARAMETER MaxLineLength
    Allow to format somehow the line so that the blob of text is spread on several lines.

    .PARAMETER Header
    Adds an encapsulation Header, [ENC= by default

    .PARAMETER Footer
    Adds an encapsulation footer, ] by default

    .PARAMETER NoEncapsulation
    Generate the encrypted data block without encapsulating with header/footer.
    Useful to test.

    .EXAMPLE
    Protect-Datum -InputObject $credential -Password P@ssw0rd

    .NOTES
    This function is a helper to build your file containing a secret.
    #>
    [CmdletBinding()]
    [OutputType([String])]
    Param (
        # Serialized Protected Data represented on Base64 encoding
        [Parameter(
            Mandatory
            , Position = 0
            , ValueFromPipeline
            , ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $InputObject,

        # By Password only for development / Test purposes
        [Parameter(
            ParameterSetName = 'ByPassword'
            , Mandatory
            , Position = 1
            , ValueFromPipelineByPropertyName
        )]
        [System.Security.SecureString]
        $Password,

        # Specify the Certificate to be used by ProtectedData
        [Parameter(
            ParameterSetName = 'ByCertificate'
            , Mandatory
            , Position = 1
            , ValueFromPipelineByPropertyName
        )]
        [String]
        $Certificate,

        # Number of columns before inserting newline in chunk
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Int]
        $MaxLineLength = 100,

        # Number of columns before inserting newline in chunk
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [String]
        $Header = '[ENC=',

        # Number of columns before inserting newline in chunk
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [String]
        $Footer = ']',

        # Number of columns before inserting newline in chunk
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $NoEncapsulation

    )

    begin {
    }

    process {
        Write-Verbose "Deserializing the Object from Base64"

        $ProtectDataParams = @{
            InputObject = $InputObject
        }
        Write-verbose "Calling Protect-Data $($PSCmdlet.ParameterSetName)"
        Switch ($PSCmdlet.ParameterSetName) {
            'ByCertificate' { $ProtectDataParams.Add('Certificate', $Certificate)}
            'ByPassword' { $ProtectDataParams.Add('Password', $Password)      }
        }

        $securedData = Protect-Data @ProtectDataParams
        $xml = [System.Management.Automation.PSSerializer]::Serialize($securedData, 5)
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($xml)
        $Base64String = [System.Convert]::ToBase64String($bytes)

        if ($MaxLineLength -gt 0) {
            $Base64DataBlock = [regex]::Replace($Base64String, "(.{$MaxLineLength})", "`$1`r`n")
        }
        else {
            $Base64DataBlock = $Base64String
        }
        if (!$NoEncapsulation) {
            $Header, $Base64DataBlock, $Footer -join ''
        }
        else {
            $Base64DataBlock
        }
    }
}