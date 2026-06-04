# Auto-Commit & Push Setup Guide

This repository is configured for automatic commit and push. Here are all the components:

## ✅ What's Enabled

### 1. **VS Code Auto-Save** 
- Files auto-save after 1 second of inactivity
- Configured in `.vscode/settings.json`

### 2. **Git Post-Commit Hook**
- Automatically pushes changes after each commit
- Located at `.git/hooks/post-commit`
- Works for all commits (manual or auto-commit)

### 3. **Auto-Commit Watcher Script**
- Monitors repository for changes every 30 seconds
- Automatically commits and pushes changes
- Customizable commit message and interval

## 🚀 Quick Start

### Option A: Using the Auto-Commit Watcher (Recommended)

1. **Start the watcher in PowerShell**:
   ```powershell
   # Navigate to repo directory
   cd "c:\Users\laven\repos\Facebook-ads-lose-effiency-after-audience-saturation\Facebook-ads-lose-efficiency-after-audience-saturation"
   
   # Run the watcher
   .\auto-commit-watcher.ps1
   ```

2. **Or use the batch file** (easier):
   - Double-click `start-auto-commit.bat` in your repository folder
   - The watcher will start monitoring for changes

3. **Customization** (optional):
   ```powershell
   # Change check interval (e.g., every 60 seconds) and message
   .\auto-commit-watcher.ps1 -IntervalSeconds 60 -CommitMessage "My custom commit message"
   ```

### Option B: Manual Workflow + Auto-Push

- Just make changes in VS Code
- Use `Ctrl+Shift+G` to open Git panel
- Click commit button
- The post-commit hook will automatically push to GitHub

## ⚙️ How It Works

```
You edit files in VS Code
         ↓
Files auto-save (1 second)
         ↓
Auto-commit watcher detects changes (every 30 seconds)
         ↓
Runs: git add .
         ↓
Runs: git commit -m "Auto-commit: ..."
         ↓
Post-commit hook triggers
         ↓
Runs: git push origin main
         ↓
Changes appear on GitHub
```

## 📊 Monitoring

When the watcher is running, you'll see output like:

```
🔄 Auto-commit watcher started
📁 Repository: c:\Users\laven\...
⏱️  Checking for changes every 30 seconds
💾 Commit message: Auto-commit: Changes saved

[14:23:45] 📝 Changes detected, committing...
[14:23:46] ✅ Committed successfully
[14:23:46] 🚀 Pushing to remote...
[14:23:47] ✅ Pushed to remote successfully
```

## 🛑 Stopping the Watcher

- Press `Ctrl+C` in the PowerShell terminal
- Or close the batch file window

## ⚠️ Important Notes

- **Internet required** for auto-push to work
- **GitHub credentials** must be configured (SSH keys or PAT)
- Keep the watcher terminal open while working
- If push fails (e.g., network issue), watcher continues monitoring

## 🔧 Troubleshooting

### "Permission Denied" Error
Enable PowerShell script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
```

### Push Fails
- Check internet connection
- Verify GitHub credentials are cached
- Run `git push origin main` manually to see the error

### Hook Not Working
Ensure `.git/hooks/post-commit` is executable and has no `.bat` or `.ps1` extension

## 📝 Viewing Commit History

```powershell
# See all auto-commits
git log --oneline | head -20

# See detailed commit info
git log --stat
```

---

**That's it!** Your repository is now set up for automatic commit and push. Just save your files in VS Code and watch them sync to GitHub automatically! 🎉
