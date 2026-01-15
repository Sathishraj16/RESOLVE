# Flutter Repair Script
# This script will help repair your corrupted Flutter installation

Write-Host "Flutter Repair Script" -ForegroundColor Cyan
Write-Host "=====================`n" -ForegroundColor Cyan

# Step 1: Backup old Flutter (if you want to keep settings)
Write-Host "Step 1: Checking Flutter installation..." -ForegroundColor Yellow
$oldFlutter = "C:\D_drive\App_Devolopment\flutter_sdk\flutter"
$backupFlutter = "C:\D_drive\App_Devolopment\flutter_sdk\flutter_old_" + (Get-Date -Format "yyyyMMdd_HHmmss")

if (Test-Path $oldFlutter) {
    Write-Host "Found existing Flutter at: $oldFlutter" -ForegroundColor Green
    $backup = Read-Host "Do you want to backup the old Flutter? (y/n)"
    if ($backup -eq 'y') {
        Write-Host "Backing up to: $backupFlutter..." -ForegroundColor Yellow
        Rename-Item -Path $oldFlutter -NewName $backupFlutter
        Write-Host "Backup complete!" -ForegroundColor Green
    } else {
        Write-Host "Deleting old Flutter installation..." -ForegroundColor Yellow
        Remove-Item -Path $oldFlutter -Recurse -Force
        Write-Host "Deleted!" -ForegroundColor Green
    }
}

# Step 2: Extract new Flutter
Write-Host "`nStep 2: Extracting new Flutter SDK..." -ForegroundColor Yellow
$zipFile = "C:\D_drive\App_Devolopment\flutter_backup.zip"

if (Test-Path $zipFile) {
    Write-Host "Extracting $zipFile..." -ForegroundColor Yellow
    Expand-Archive -Path $zipFile -DestinationPath "C:\D_drive\App_Devolopment\flutter_sdk\" -Force
    Write-Host "Extraction complete!" -ForegroundColor Green
} else {
    Write-Host "ERROR: Flutter zip not found at $zipFile" -ForegroundColor Red
    Write-Host "Please download Flutter manually from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    exit 1
}

# Step 3: Run flutter doctor
Write-Host "`nStep 3: Running flutter doctor..." -ForegroundColor Yellow
cd C:\D_drive\App_Devolopment\flutter_sdk\flutter
.\bin\flutter doctor -v

Write-Host "`nStep 4: Clearing pub cache..." -ForegroundColor Yellow
.\bin\flutter pub cache clean

# Step 5: Navigate to project and reinstall dependencies
Write-Host "`nStep 5: Reinstalling project dependencies..." -ForegroundColor Yellow
cd "C:\Users\Thejesh M\Desktop\Resolve"
C:\D_drive\App_Devolopment\flutter_sdk\flutter\bin\flutter pub get

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Flutter repair complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nYou can now try running your app with:" -ForegroundColor Yellow
Write-Host "  flutter run -d windows" -ForegroundColor White
Write-Host "or" -ForegroundColor Yellow
Write-Host "  flutter run -d chrome" -ForegroundColor White
