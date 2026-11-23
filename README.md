# Portafolio personal — Wendy Ramírez

Aplicación sencilla con Vue 3, TypeScript, Vite, FastAPI y Supabase PostgreSQL. Incluye pruebas unitarias, de integración y E2E, Docker Compose, Terraform, Ansible y despliegue de Cloudflare Workers en una URL gratuita workers.dev.

## Ejecución local

Requisitos: Docker Desktop y Git.

1. Copiar .env.example como .env (PowerShell: Copy-Item .env.example .env).
2. Ejecutar: docker compose -f docker-compose.yml -f docker-compose.local.yml --profile local up --build.
3. Abrir http://localhost:8080.

El perfil local usa PostgreSQL en Docker. Para usar Supabase, configura DATABASE_URL con la cadena de conexión Session pooler. No pongas claves secretas en variables VITE_*.

## Pruebas

Frontend unitario y E2E:

~~~powershell
cd frontend
npm install
npm run test:unit
npm run test:e2e
~~~

Backend unitario e integración:

~~~powershell
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
pytest -m "unit or integration"
~~~

Las pruebas E2E usan Playwright y requieren la aplicación levantada por Docker Compose. GitHub Actions ejecuta las pruebas en cada push a dev y en cada pull request hacia main.

## Flujo de GitHub Actions

- Push a dev: compila y ejecuta unitarias, integración y E2E.
- Push a main: repite las pruebas; publica frontend y API ARM64 en Docker Hub; prepara el estado remoto en OCI Object Storage; crea VM, VCN, subred pública e IP pública con Terraform; configura Docker, Git, UFW e iptables con Ansible; despliega el sitio a workers.dev.
- La URL final se imprime en el resumen de la ejecución de Actions.

## Preparar GitHub

En Settings → Secrets and variables → Actions, configura estos valores. No los pongas en el código ni los envíes por chat.

### Repository secrets

| Secreto | Uso |
|---|---|
| DOCKERHUB_USERNAME | Usuario de Docker Hub |
| DOCKERHUB_TOKEN | Token Docker Hub con escritura |
| CLOUDFLARE_API_TOKEN | Token de Workers Scripts Edit y Account Settings Read |
| OCI_TENANCY_OCID | OCID de la tenancy OCI |
| OCI_USER_OCID | OCID del usuario OCI |
| OCI_FINGERPRINT | Fingerprint de la clave de API OCI |
| OCI_PRIVATE_KEY | Clave privada PEM para la API OCI |
| OCI_COMPARTMENT_OCID | OCID del compartment de destino |
| OCI_SSH_PUBLIC_KEY | Clave pública para entrar a la VM |
| SSH_PRIVATE_KEY | Clave privada SSH correspondiente |
| OCI_OBJECT_STORAGE_ACCESS_KEY | Access key S3 de OCI Customer Secret Key |
| OCI_OBJECT_STORAGE_SECRET_KEY | Secret key S3 de OCI Customer Secret Key |
| SUPABASE_DATABASE_URL | URI Session pooler de Supabase |

CLOUDFLARE_API_TOKEN ya está guardado en el repositorio. El token creado vence aproximadamente 90 días después de su creación. No compartas aquí su valor.

### Repository variables

| Variable | Contenido |
|---|---|
| CLOUDFLARE_ACCOUNT_ID | ID de la cuenta Cloudflare |
| OCI_REGION | Región OCI habilitada, por ejemplo sa-santiago-1 |
| OCI_IMAGE_OCID | OCID de Ubuntu 24.04 ARM64/AArch64 en esa región |
| OCI_ADMIN_CIDR | Tu IP pública con /32 para restringir SSH |
| OCI_NAMESPACE | Namespace de Object Storage de OCI |
| TF_STATE_BUCKET | Nombre del bucket privado del estado, por ejemplo portfolio-tfstate |

CLOUDFLARE_ACCOUNT_ID ya está guardada como variable.

## Supabase

1. En tu proyecto Supabase, abre SQL Editor y ejecuta database/schema.sql.
2. Copia la cadena Session pooler de conexión PostgreSQL y guárdala en GitHub como SUPABASE_DATABASE_URL.
3. No es necesario que compartas conmigo esa cadena. El flujo local no modifica tu proyecto Supabase.

## OCI y estado remoto

El backend remoto usa un bucket privado de OCI Object Storage con su API compatible con S3. Así no depende de crear una organización HCP Terraform, que alcanzó el límite de cuenta.

1. En OCI, crea un bucket privado para el estado antes de correr Terraform. No lo hagas público ni lo elimines mientras haya recursos Terraform asociados.
2. En OCI, genera una Customer Secret Key de Object Storage compatible con S3. Guarda su Access Key ID y Secret Key como los dos secretos indicados arriba.
3. Anota el namespace de Object Storage y configura OCI_NAMESPACE. El bucket debe estar en la misma región de OCI_REGION.
4. Crea una clave API OCI y guarda la clave privada, fingerprint, tenancy OCID y user OCID como secrets. Obtén el compartment OCID donde crearás la red y la VM.
5. Crea una clave SSH y guarda ambas partes en los secrets correspondientes. Configura OCI_ADMIN_CIDR con tu IP confiable.
6. Selecciona el OCID de una imagen Ubuntu Server 24.04 ARM64/AArch64 y agrégalo como OCI_IMAGE_OCID.

Terraform crea una instancia VM.Standard.A1.Flex de 1 OCPU, 2 GB y disco de arranque de 50 GB, además de VCN, internet gateway, subnet pública, rutas, reglas de red e IP pública. SSH se restringe a tu CIDR y al runner durante el despliegue; la red pública abre 80 y 443. Ansible instala Docker, Git, UFW e iptables, permite los puertos 80/443 y publica los contenedores.

### Costo orientativo

La tarifa pública de Oracle para Ampere A1 es US$0.01 por OCPU-hora y US$0.0015 por GB-hora; 1 OCPU y 2 GB durante 730 horas representa cerca de US$9.50 al mes solo en cómputo. OCI publica una asignación mensual sin costo para ciertas cantidades A1, pero disponibilidad, elegibilidad, disco, tráfico y otros cargos dependen de tu tenancy y región. Verifica el total en el estimador de OCI antes de ejecutar el primer despliegue a main. El workflow hace terraform apply con aprobación automática, por eso un push a main puede crear recursos facturables.

## Cloudflare Workers

El repositorio publica Vue mediante Wrangler a https://portafolio-wendy.<tu-subdominio>.workers.dev y redirige las rutas /api a la IP pública de OCI por HTTP. El navegador se conecta por HTTPS al Worker. No necesitas comprar dominio ni añadir una zona DNS. Activa una vez el subdominio gratuito workers.dev en Workers & Pages de Cloudflare antes del primer despliegue.

## Antes del primer push a main

Completa los secretos y variables anteriores, crea el bucket de estado y ejecuta database/schema.sql en Supabase. Al fusionar la PR a main, se activará el despliegue de Docker Hub, OCI, Ansible y Cloudflare Workers; el costo depende de la región y los recursos disponibles.
