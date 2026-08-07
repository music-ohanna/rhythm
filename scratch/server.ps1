$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:9999/")
$listener.Start()
Write-Host "Server listening on http://localhost:9999/"

$root = "c:\Users\playv\OneDrive\바탕 화면\workplace\rhythm2\final-rhythm"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    
    $localPath = $request.Url.LocalPath
    if ($localPath -eq "/") { $localPath = "/index.html" }
    
    $filePath = Join-Path $root $localPath.TrimStart('/')
    if (Test-Path $filePath -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        if ($filePath.EndsWith(".html")) { $response.ContentType = "text/html; charset=utf-8" }
        elseif ($filePath.EndsWith(".css")) { $response.ContentType = "text/css; charset=utf-8" }
        elseif ($filePath.EndsWith(".js")) { $response.ContentType = "text/javascript; charset=utf-8" }
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $response.StatusCode = 404
    }
    $response.OutputStream.Close()
}
