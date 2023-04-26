$directories = Get-ChildItem -Path "{somepath}" -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

if(Test-Path .\output)
{
    Remove-Item .\output -recurse
}

New-Item -path .\output  -ItemType Directory

foreach($dir in $directories){
	$d = $dir -replace '@{FullName=', '' -replace '}', ''
	$o = $d.split('\')[-1]
	
	node features2html.js -i $d create -o output\$o.html
}

$outputFeatureFiles = Get-ChildItem -Path ".\output" -Recurse -File -Force -ErrorAction SilentlyContinue | Select-Object FullName

New-Item -path .\output\index.html  -ItemType File -Force

$links = @()

foreach($file in $outputFeatureFiles){
	
	$FileName = Split-Path $file -leaf
	
	$linkText = $fileName -replace '.html}', ''
	
	$f = $file -replace '@{FullName=', '<li><a href ="' -replace '}', "`">$($linkText)</a></li></br>"`
	
	$links += $f
}

Set-Content -Path .\output\index.html -Value "<html><head><link rel='stylesheet' href= '../default/templates/style.css'></head><body><h1>Vision Anywhere Feature Index</h1><div>$($links)</div></body></html>"




