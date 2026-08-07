# check_utf8.ps1
$c = [System.IO.File]::ReadAllText('index.html', [System.Text.Encoding]::UTF8)
$i = $c.IndexOf('tutorialSteps')
Write-Host "Length: $($c.Length), tutorialSteps at: $i"
Write-Host $c.Substring($i, 500)
