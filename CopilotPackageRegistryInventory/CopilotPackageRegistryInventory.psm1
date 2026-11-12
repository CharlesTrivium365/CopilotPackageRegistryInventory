#Requires -Modules Microsoft.Graph.Authentication

Set-StrictMode -Version Latest

function Get-CopilotPackageRegistry {
<#
.SYNOPSIS
    Liste en lecture seule le registre des paquets Copilot d'un locataire.

.DESCRIPTION
    Interroge le point de terminaison Microsoft Graph
    /v1.0/copilot/admin/catalog/packages et retourne chaque paquet
    (skills, connecteurs et agents) du registre sous forme d'objet
    PowerShell. La fonction ne modifie jamais le locataire.

    L'API porte le libelle preview (preversion) a la date de redaction de
    l'article source (29 octobre 2026) et l'API de gestion des paquets
    exige une licence Microsoft Agent 365 selon la documentation Microsoft
    Learn. Une liste vide ou une erreur de licence indique que l'API n'est
    pas disponible dans le locataire.

.PARAMETER Connect
    Etablit une connexion Microsoft Graph avec Connect-MgGraph avant la
    requete. Sans ce parametre, la session Microsoft Graph deja ouverte
    est reutilisee.

.PARAMETER Scopes
    Permissions demandees a Connect-MgGraph lorsque -Connect est present.
    Valeur par defaut : CopilotPackages.Read.All.

.PARAMETER ApiVersion
    Version de Microsoft Graph a utiliser. Valeur par defaut : v1.0.

.EXAMPLE
    Get-CopilotPackageRegistry -Connect

    Ouvre une session Microsoft Graph puis affiche le registre des paquets.

.EXAMPLE
    Connect-MgGraph -Scopes 'CopilotPackages.Read.All'
    Get-CopilotPackageRegistry | Format-Table

    Reutilise une session existante et presente le resultat en tableau.

.OUTPUTS
    System.Management.Automation.PSCustomObject

.NOTES
    Permissions minimales : CopilotPackages.Read.All ; role AI Administrator.
    Module requis : Microsoft.Graph.Authentication.
    Licence requise : Microsoft Agent 365 pour l'API de gestion des paquets.
#>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [switch]$Connect,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]$Scopes = @('CopilotPackages.Read.All'),

        [Parameter()]
        [ValidateSet('v1.0')]
        [string]$ApiVersion = 'v1.0'
    )

    if ($Connect) {
        Write-Verbose "Connexion a Microsoft Graph avec les permissions : $($Scopes -join ', ')."
        Connect-MgGraph -Scopes $Scopes | Out-Null
    }

    $uri = "https://graph.microsoft.com/$ApiVersion/copilot/admin/catalog/packages"
    Write-Verbose "Requete GET : $uri"

    do {
        $response = Invoke-MgGraphRequest -Method GET -Uri $uri

        $items = $null
        if ($response.ContainsKey('value')) {
            $items = $response['value']
        }

        foreach ($item in $items) {
            if ($item -is [System.Collections.IDictionary]) {
                [pscustomobject]$item
            }
            else {
                $item
            }
        }

        $uri = $null
        if ($response.ContainsKey('@odata.nextLink')) {
            $uri = $response['@odata.nextLink']
            Write-Verbose "Page suivante : $uri"
        }
    } while ($uri)
}

function Export-CopilotPackageRegistryReport {
<#
.SYNOPSIS
    Genere un rapport HTML simple du registre des paquets Copilot.

.DESCRIPTION
    Recoit les objets produits par Get-CopilotPackageRegistry et ecrit un
    fichier HTML a l'emplacement indique. La fonction ecrit sur le disque
    local seulement et ne modifie pas le locataire. Elle prend en charge
    -WhatIf et -Confirm pour l'ecriture du fichier.

.PARAMETER Package
    Objets de paquet a inclure dans le rapport, par exemple la sortie de
    Get-CopilotPackageRegistry. Accepte l'entree par pipeline.

.PARAMETER Path
    Chemin du fichier HTML a creer.

.PARAMETER Title
    Titre affiche en tete du rapport. Valeur par defaut :
    Registre des paquets Copilot.

.EXAMPLE
    Get-CopilotPackageRegistry | Export-CopilotPackageRegistryReport -Path './registre.html'

    Produit un rapport HTML a partir du registre.

.EXAMPLE
    Get-CopilotPackageRegistry | Export-CopilotPackageRegistryReport -Path './registre.html' -WhatIf

    Montre l'action d'ecriture sans creer le fichier.

.OUTPUTS
    System.IO.FileInfo
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IO.FileInfo])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject[]]$Package,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Title = 'Registre des paquets Copilot'
    )

    begin {
        $collected = [System.Collections.Generic.List[psobject]]::new()
    }

    process {
        foreach ($entry in $Package) {
            $collected.Add($entry)
        }
    }

    end {
        $generatedOn = (Get-Date).ToString('yyyy-MM-dd HH:mm')
        $preContent = "<h1>$Title</h1><p>Paquets : $($collected.Count). Genere le $generatedOn.</p>"

        $html = $collected | ConvertTo-Html -Title $Title -PreContent $preContent

        if ($PSCmdlet.ShouldProcess($Path, 'Ecrire le rapport HTML')) {
            $html | Out-File -FilePath $Path -Encoding utf8
            Get-Item -LiteralPath $Path
        }
    }
}

Export-ModuleMember -Function 'Get-CopilotPackageRegistry', 'Export-CopilotPackageRegistryReport'
