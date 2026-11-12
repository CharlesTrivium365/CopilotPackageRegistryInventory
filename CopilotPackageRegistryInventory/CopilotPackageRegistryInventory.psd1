@{
    RootModule        = 'CopilotPackageRegistryInventory.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'c7a1e9d2-4b36-4f8a-9c21-6d5e8f0a1b23'
    Author            = 'Charles Jenkins'
    CompanyName       = 'Charles Jenkins'
    Copyright         = '(c) 2026 Charles Jenkins'
    Description       = 'Liste en lecture seule le registre des paquets Copilot (skills, connecteurs et agents) d''un locataire via Microsoft Graph.'
    PowerShellVersion = '5.1'
    RequiredModules   = @('Microsoft.Graph.Authentication')
    FunctionsToExport = @('Get-CopilotPackageRegistry', 'Export-CopilotPackageRegistryReport')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Copilot', 'Microsoft365', 'MicrosoftGraph', 'Inventory', 'ReadOnly')
        }
    }
}
