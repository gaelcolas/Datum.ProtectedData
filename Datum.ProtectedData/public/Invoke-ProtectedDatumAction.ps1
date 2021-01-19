function Invoke-ProtectedDatumAction
{
    <#
    .SYNOPSIS
    Action that decrypt the secret when the Datum Handler is triggered

    .DESCRIPTION
    When Datum uses this handler and a piece of data pass the associated filter, this
    action will decrypt the data.

    .PARAMETER InputObject
    Datum data to be decrypted

    .PARAMETER PlainTextPassword
    !! FOR TESTING ONLY!!
    Plain text password used for decrypting the password when you want to easily test.
    You can configure the password in the Datum.yml file in the DatumHandler section when
    doing tests.

    .PARAMETER Certificate
    Provide the Certificate in a format supported by Dave Wyatt's ProtectedData module:
    It can be a thumbprint, certificate file, path to a certificate file or to cert provider...

    .PARAMETER Header
    Header of the Datum data string that encapsulates the encrypted data. The default is [ENC= but can be
    customized (i.e. in the Datum.yml configuration file)

    .PARAMETER Footer
    Footer of the Datum data string that encapsulates the encrypted data. The default is ]

    .EXAMPLE
    $objectToDecrypt | Invoke-ProtectedDatumAction

    .NOTES
    The arguments you can set in the Datum.yml is directly related to the arguments of this function.

    #>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
    Param
    (
        # Serialized Protected Data represented on Base64 encoding
        [Parameter(
            Mandatory
            , Position = 0
            , ValueFromPipeline
            , ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $InputObject,

        # By Password only for development / Test purposes
        [Parameter(
            ParameterSetName = 'ByPassword'
            , Mandatory
            , Position = 1
            , ValueFromPipelineByPropertyName
        )]
        [String]
        $PlainTextPassword,

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
        [String]
        $Header = '[ENC=',

        # Number of columns before inserting newline in chunk
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [String]
        $Footer = ']'
    )
    begin
    {
        if ($null -eq $script:DecryptedPasswords)
        {
            $script:DecryptedPasswords = @{}
        }
    }
    process
    {
        Write-Debug "Decrypting Datum using ProtectedData"
        if ($script:DecryptedPasswords.ContainsKey($InputObject))
        {
            return $script:DecryptedPasswords.$InputObject
        }
        else
        {
            $params = @{}
            foreach ($ParamKey in $PSBoundParameters.keys)
            {
                if ($ParamKey -in @('InputObject', 'PlainTextPassword'))
                {
                    switch ($ParamKey)
                    {
                        'PlainTextPassword' { $params.add('password', (ConvertTo-SecureString -AsPlainText -Force $PSBoundParameters[$ParamKey])) }
                        'InputObject' { $params.add('Base64Data', $InputObject) }
                    }
                }
                else
                {
                    $params.add($ParamKey, $PSBoundParameters[$ParamKey])
                }
            }

            $result = UnProtect-Datum @params
            $script:DecryptedPasswords.$InputObject = $result
            return $result
        }
    }
}