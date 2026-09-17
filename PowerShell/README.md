# PowerShell

## Fonte da verdade

O profile ativo vive no **OneDrive**, em:

```
OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

E ele que propaga entre as maquinas: mexeu na config local, o OneDrive sincroniza.

Os arquivos aqui neste diretorio sao:

| Arquivo | Papel |
|---|---|
| `Microsoft.PowerShell_profile.ps1` | Snapshot versionado do profile do OneDrive. Serve para semear uma maquina nova e para ter historico. **Nao e o arquivo que roda.** |
| `profile-shim.ps1` | Ponte instalada em `Documents\PowerShell\` nas maquinas onde Documentos NAO esta redirecionado para o OneDrive. |

Para atualizar o snapshot depois de mexer no profile:

```powershell
Copy-Item "$env:OneDriveConsumer\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" `
          .\PowerShell\Microsoft.PowerShell_profile.ps1
```

## O que o profile usa

| Item | Origem |
|---|---|
| `PSReadLine` | Ja vem com o PowerShell 7 |
| `posh-git` | PSGallery |
| `F7History` | PSGallery (traz `Microsoft.PowerShell.ConsoleGuiTools` junto) |
| `Terminal-Icons` | PSGallery, carregado pelo shim |
| Oh My Posh | winget, tema `jandedobbeleer` |
| `CaskaydiaCove NF` | `oh-my-posh font install CascadiaCode` |

Tudo isso e instalado por [`../scripts/windows/install.ps1`](../scripts/windows/README.md).
