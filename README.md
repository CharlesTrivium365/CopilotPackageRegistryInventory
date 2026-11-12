# CopilotPackageRegistryInventory

Cet outil PowerShell interroge Microsoft Graph en lecture seule pour lister le registre des paquets Copilot d'un locataire. Chaque entrée représente un paquet visible dans le centre d'administration (skills, connecteurs et agents). L'outil ne modifie jamais le locataire.

## Pourquoi maintenant

Le 27 octobre 2026, Microsoft a publié avec la firme Keystone une étude sur la coordination des agents d'IA en entreprise. La première pratique décrite est un registre d'agents tenu à jour. Le centre d'administration Microsoft 365 expose un registre des paquets Copilot interrogeable par Microsoft Graph, en préversion. Cet outil en donne une première trace lisible sans rien changer au locataire.

## Prérequis

- PowerShell 5.1 ou une version plus récente
- Module Microsoft.Graph.Authentication (Connect-MgGraph, Invoke-MgGraphRequest)
- Permission Microsoft Graph CopilotPackages.Read.All
- Rôle AI Administrator
- Licence Microsoft Agent 365 pour l'API de gestion des paquets

## Installation

```powershell
Install-Module Microsoft.Graph.Authentication -Scope CurrentUser
Import-Module ./CopilotPackageRegistryInventory/CopilotPackageRegistryInventory.psd1
```

## Utilisation

Ouvrir une session puis lister le registre:

```powershell
Get-CopilotPackageRegistry -Connect
```

Réutiliser une session Microsoft Graph déjà ouverte:

```powershell
Connect-MgGraph -Scopes 'CopilotPackages.Read.All'
Get-CopilotPackageRegistry | Format-Table
```

Produire un rapport HTML simple:

```powershell
Get-CopilotPackageRegistry -Connect |
    Export-CopilotPackageRegistryReport -Path './registre-copilot.html'
```

Prévisualiser l'écriture du rapport sans créer le fichier:

```powershell
Get-CopilotPackageRegistry |
    Export-CopilotPackageRegistryReport -Path './registre-copilot.html' -WhatIf
```

## Exemple de sortie

Sortie fictive présentée à titre d'illustration. Les propriétés réelles proviennent de l'API en préversion et peuvent différer de celles montrées ici. Elles ne sont pas détaillées dans l'article source.

```
id          : 11111111-1111-1111-1111-111111111111
displayName : Paquet de démonstration (fictif)
packageType : agent
```

## Limites connues

- L'API porte le libellé « preview » (préversion) à la date de rédaction de l'article (29 octobre 2026) et peut changer ou être retirée.
- Une erreur de licence ou une liste vide signifie que l'API n'est pas disponible dans le locataire.
- L'API de gestion des paquets exige une licence Microsoft Agent 365 selon la documentation Microsoft Learn.
- Les propriétés retournées ne sont pas détaillées dans l'article source.
- L'outil fonctionne en lecture seule. Il n'applique aucune modification au locataire.

## Sources

- Article de Charles Jenkins: https://trivium365.com/blog/colonne-de-connaissances-agents-copilot-pme/
- Jared Spataro, « The AI advantage your company can keep », blogue Microsoft Copilot, 27 octobre 2026: https://www.microsoft.com/en-us/copilot/blog/2026/10/27/the-ai-advantage-your-company-can-keep/
- Keystone et Harvard Business School, « Organizing AI at Enterprise Scale », document de travail no 27-038, octobre 2026 (cité par le blogue Microsoft)
- Documentation Microsoft Learn pour le point de terminaison GET /v1.0/copilot/admin/catalog/packages

## Licence

Ce projet est distribué sous licence MIT. Voir le fichier LICENSE.


## Démonstration en vidéo

https://www.youtube.com/watch?v=6iSf4Suj-00
