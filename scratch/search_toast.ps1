$indexPath = "C:\Users\playv\OneDrive\바탕 화면\workplace\rhythm2\final-rhythm\index.html"
$lines = [System.IO.File]::ReadAllLines($indexPath, [System.Text.Encoding]::UTF8)
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "showToast|Toast|길어|짧|초과|박자|오류|경고") {
        Write-Host "Line $($i+1): $($lines[$i])"
    }
}
