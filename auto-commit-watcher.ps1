# auto-commit-watcher.ps1
# Script to automatically commit and push changes to git repository
# Run this in the terminal to start auto-committing changes

param(
    [int]$IntervalSeconds = 30,  # Check for changes every 30 seconds
    [string]$CommitMessage = "Auto-commit: Changes saved"
)

# Navigate to repo
$repoPath = "c:\Users\laven\repos\Facebook-ads-lose-effiency-after-audience-saturation\Facebook-ads-lose-efficiency-after-audience-saturation"
Set-Location $repoPath

$gitPath = "C:\Program Files\Git\cmd\git.exe"

Write-Host "🔄 Auto-commit watcher started" -ForegroundColor Green
Write-Host "📁 Repository: $repoPath" -ForegroundColor Green
Write-Host "⏱️  Checking for changes every $IntervalSeconds seconds" -ForegroundColor Green
Write-Host "💾 Commit message: $CommitMessage" -ForegroundColor Green
Write-Host ""
Write-Host "Press Ctrl+C to stop the watcher" -ForegroundColor Yellow
Write-Host ""

$previousCommit = & $gitPath rev-parse HEAD

while ($true) {
    Start-Sleep -Seconds $IntervalSeconds
    
    # Check if there are any changes
    $status = & $gitPath status --porcelain
    
    if ($status) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 📝 Changes detected, committing..." -ForegroundColor Yellow
        
        # Add all changes
        & $gitPath add .
        
        # Commit changes
        $output = & $gitPath commit -m "$CommitMessage - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" 2>&1
        
        if ($output -match "create mode|changed|deleted") {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✅ Committed successfully" -ForegroundColor Green
            
            # Push to remote
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 🚀 Pushing to remote..." -ForegroundColor Cyan
            $pushOutput = & $gitPath push origin main 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✅ Pushed to remote successfully" -ForegroundColor Green
            } else {
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ⚠️  Push failed: $pushOutput" -ForegroundColor Red
            }
        } else {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ℹ️  No changes to commit" -ForegroundColor Gray
        }
    }
}
