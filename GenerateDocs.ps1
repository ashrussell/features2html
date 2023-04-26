$directories = Get-ChildItem -Path "{somepath}" -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

if(Test-Path .\output)
{
    Remove-Item .\output -recurse
}

New-Item -path .\output  -ItemType Directory

foreach($dir in $directories){
	$d = $dir -replace '@{FullName=', '' -replace '}', ''
	$o = $d.split('\')[-1]
	
	node features2html.js -p ProductName -a ProductAuthor -i $d create -o output\$o.html
}

$outputFeatureFiles = Get-ChildItem -Path ".\output" -Recurse -File -Force -ErrorAction SilentlyContinue | Select-Object FullName

New-Item -path .\output\index.html  -ItemType File -Force

$links = @()

foreach($file in $outputFeatureFiles){
	
	$FileName = Split-Path $file -leaf
	
	$linkText = $fileName -replace '.html}', ''
	
	$f = $file -replace '@{FullName=', '<a href ="' -replace '}', "`">$($linkText)</a></br></br>"`
	
	$links += $f
}

Set-Content -Path .\output\index.html -Value "<html><head><title>Feature documentation</title><link rel='stylesheet' href= '../default/templates/style.css'></head><header><div>Feature documentation</div></header><body><h1>Feature Index</h1><p>To gain an understanding of product functionality please select a feature</p><div class='contentIndex'>$($links)</div></body></html>"




