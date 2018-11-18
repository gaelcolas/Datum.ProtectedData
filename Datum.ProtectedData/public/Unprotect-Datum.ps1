#Requires -Modules ProtectedData

function Unprotect-Datum {
    <#
    .SYNOPSIS
    Decrypt a previously encrypted object

    .DESCRIPTION
    This command decrypts the string representation of an object previously encrypted
    by Protect-Datum. You can decrypt a credential object, a secure string or simply
    a string. It uses Dave Wyatt's ProtectedData module under the hood.

    .PARAMETER Base64Data
    The encrypted data is represented in a Base 64 string to be easily stored in a text document.
    This is the input to be decrypted and restored as an object.

    .PARAMETER Password
    ! FOR TESTS ONLY !
    You can use a password to encrypt and decrypt the data you want to secure when doing test
    with this module

    .PARAMETER Certificate
    You can pass the certificate (thumbprint, file, file path, cert provider path...) containing the
    private key to be used to decrypt the secured data.

    .PARAMETER Header
    Header to strip off when encapsulated in a file. default is [ENC=

    .PARAMETER Footer
    Footer to strip off when encapsulated in a file. default is ]

    .PARAMETER NoEncapsulation
    Switch to attempt the decryption when there is no encapsulation

    .EXAMPLE
    $encryptedstring | Unprotect-Datum -NoEncapsulation -Password P@ssw0rd

    #>
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param (
        # Serialized Protected Data represented on Base64 encoding
        [Parameter(
            Mandatory
            , Position = 0
            , ValueFromPipeline
            , ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Base64Data,

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

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [String]
        $Header = '[ENC=',

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [String]
        $Footer = ']',

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $NoEncapsulation
    )

    begin {
    }

    process {
        if (!$NoEncapsulation) {
            Write-Verbose "Removing $header DATA $footer "
            $Base64Data = $Base64Data -replace "^$([regex]::Escape($Header))" -replace "$([regex]::Escape($Footer))$"
        }

        Write-Verbose "Deserializing the Object from Base64"
        $bytes = [System.Convert]::FromBase64String($Base64Data)
        $xml = [System.Text.Encoding]::UTF8.GetString($bytes)
        $obj = [System.Management.Automation.PSSerializer]::Deserialize($xml)
        $UnprotectDataParams = @{
            InputObject = $obj
        }
        Write-verbose "Calling Unprotect-Data $($PSCmdlet.ParameterSetName)"
        Switch ($PSCmdlet.ParameterSetName) {
            'ByCertificae' { $UnprotectDataParams.Add('Certificate', $Certificate)}
            'ByPassword' { $UnprotectDataParams.Add('Password', $Password)      }
        }
        Unprotect-Data @UnprotectDataParams
    }

}