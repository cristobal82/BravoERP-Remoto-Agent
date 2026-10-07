# Microsoft Store / MSIX

Esta carpeta prepara el agente de Windows como un MSIX para Microsoft Store.
El paquete no se instala ni reemplaza el agente que actualmente esta en
produccion.

## Por que existe `--storeMode=1`

Windows instala los archivos MSIX en una ubicacion inmutable. En modo Store,
el agente guarda su configuracion, base de datos y logs en:

`C:\ProgramData\BravoERP\RemotoAgent`

El manifiesto tambien desactiva la actualizacion del ejecutable desde el
servidor (`--disableUpdate=1`), porque las nuevas versiones del binario deben
llegar por Microsoft Store.

## Crear el paquete local

```powershell
.\packaging\msix\Build-Msix.ps1 `
  -BinaryPath .\Release\MeshService64.exe `
  -Publisher 'CN=VALOR EXACTO DE PARTNER CENTER' `
  -IdentityName 'VALOR EXACTO DE PARTNER CENTER' `
  -Version 1.0.0.0
```

El resultado queda en `artifacts\BravoERP-Remoto-Agent.msix`, junto con su
SHA-256. Microsoft Store sustituye la firma de desarrollo por su firma de
confianza durante la certificacion.

## Datos que faltan antes del envio

1. Reservar el nombre del producto en Partner Center.
2. Copiar exactamente `Package/Identity/Name` y `Package/Identity/Publisher`
   asignados por Microsoft.
3. Justificar las capacidades restringidas `packagedServices` y
   `localSystemServices`; son necesarias porque el agente funciona como
   servicio LocalSystem para poder prestar soporte antes del inicio de sesion.
4. Definir el flujo de enrolamiento. El MSIX es generico y no debe contener las
   credenciales de un grupo de dispositivos concreto.

## Limite conocido de certificacion

Microsoft indica que las capacidades de servicios empaquetados requieren una
revision especial y que normalmente no se aprueban para aplicaciones publicas.
Por eso este paquete es una implementacion verificable, pero su publicacion no
se puede prometer hasta que Partner Center apruebe dichas capacidades.
