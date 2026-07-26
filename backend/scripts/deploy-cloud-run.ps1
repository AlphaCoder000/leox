$ErrorActionPreference = "Stop"

$ProjectId = "studio-7488920972-4ef9c"
$Region = "asia-south1"
$ServiceName = "leox-backend"
$ServiceAccount = "firebase-adminsdk-fbsvc@studio-7488920972-4ef9c.iam.gserviceaccount.com"
$Image = "gcr.io/$ProjectId/$ServiceName"

Write-Host "==> Setting gcloud project to $ProjectId"
gcloud config set project $ProjectId | Out-Null

Write-Host "==> Building container image"
Push-Location (Split-Path $PSScriptRoot -Parent)
gcloud builds submit --tag $Image .
Pop-Location

Write-Host "==> Reading existing Razorpay env vars from current revision"
$ExistingEnv = gcloud run services describe $ServiceName --region $Region --format="json(spec.template.spec.containers[0].env)" | ConvertFrom-Json
$RazorpayKeyId = ($ExistingEnv | Where-Object { $_.name -eq "RAZORPAY_KEY_ID" }).value
$RazorpayKeySecret = ($ExistingEnv | Where-Object { $_.name -eq "RAZORPAY_KEY_SECRET" }).value
$RazorpayWebhookSecret = ($ExistingEnv | Where-Object { $_.name -eq "RAZORPAY_WEBHOOK_SECRET" }).value

$EnvFile = Join-Path $env:TEMP "leox-backend-cloudrun-env.yaml"
$EnvLines = @(
  "FIREBASE_PROJECT_ID: $ProjectId",
  "NODE_ENV: production"
)
if ($RazorpayKeyId) { $EnvLines += "RAZORPAY_KEY_ID: $RazorpayKeyId" }
if ($RazorpayKeySecret) { $EnvLines += "RAZORPAY_KEY_SECRET: $RazorpayKeySecret" }
if ($RazorpayWebhookSecret) { $EnvLines += "RAZORPAY_WEBHOOK_SECRET: $RazorpayWebhookSecret" }
$EnvLines | Set-Content -Path $EnvFile -Encoding ascii

Write-Host "==> Deploying Cloud Run service (ADC via Firebase service account)"
gcloud run deploy $ServiceName `
  --image $Image `
  --region $Region `
  --platform managed `
  --allow-unauthenticated `
  --service-account $ServiceAccount `
  --port 8080 `
  --memory 512Mi `
  --cpu 1 `
  --env-vars-file $EnvFile

Remove-Item $EnvFile -Force

$ServiceUrl = gcloud run services describe $ServiceName --region $Region --format="value(status.url)"
Write-Host ""
Write-Host "Deployed: $ServiceUrl"
Write-Host "Health:   $ServiceUrl/api/health?deep=true"

Write-Host ""
Write-Host "==> Running deep health check"
Start-Sleep -Seconds 5
curl.exe -s "$ServiceUrl/api/health?deep=true"
