$resourceNonce = [System.Guid]::NewGuid().ToString().Substring(0, 8)
$resourceGroupName = "AzSDK-Demo"
$deployLocation = "eastus"
$webServicePlanName = "azsdkdemoasp" + $resourceNonce
$webAppName = "azsdkdemowa" + $resourceNonce
$storageAccountName = "azsdkdemosa" + $resourceNonce

Write-Host "Setting up demo resources. This will take few minutes..."

$resourceGroup = New-AzureRmResourceGroup -Name $resourceGroupName -Location $deployLocation

$webServicePlan = New-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName `
                            -Name $webServicePlanName `
                            -Location $deployLocation `
                            -Tier Basic

$webApp = New-AzureRmWebApp -ResourceGroupName $resourceGroupName `
                    -Name $webAppName `
                    -AppServicePlan $webServicePlanName `
                    -Location $deployLocation

$storageAccount = New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
                            -Name $storageAccountName `
                            -SkuName Standard_LRS `
                            -Location $deployLocation `
                            -Kind Storage

$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName `
                            -Name $storageAccountName

$storageAccountConnectionString = "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$($storageAccountKey[0].Value);EndpointSuffix=core.windows.net"

$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
                            -Name $storageAccountName

$container = New-AzureStorageContainer -Context $storageAccount.Context `
                            -Name "patent-images" `
                            -Permission Container

$wc = [System.Net.WebClient]::new()
$fileName = "secret" + ".jpg";
$tempFilePath = Join-Path $env:TEMP $fileName
$wc.DownloadFile("https://raw.githubusercontent.com/azsdk/azsdk-demo-app/master/helper-files/secret.png", $tempFilePath)
$na = Set-AzureStorageBlobContent -Context $storageAccount.Context `
                            -Container $container.Name `
                            -BlobType Block `
                            -Blob $fileName `
                            -File $tempFilePath `
                            -Force

Remove-Item $tempFilePath -Force

Write-Host "Setup completed`n"

Write-Host "Parameters:`n"
Write-Host "Resource Group : " -NoNewline
Write-Host "$resourceGroupName" -ForegroundColor Yellow
Write-Host "App Service Plan : " -NoNewline
Write-Host " $webServicePlanName" -ForegroundColor Yellow
Write-Host "Web App Name : " -NoNewline
Write-Host " $webAppName" -ForegroundColor Yellow
Write-Host "Storage Account Connection String : "
Write-Host "$storageAccountConnectionString`n" -ForegroundColor Yellow

$storageAccountConnectionString | clip.exe

Write-Host "Storage Account Connection String is copied to your clipboard"