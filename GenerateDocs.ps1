param ([Parameter(Mandatory)]$pathToFeatureFiles, [Parameter(Mandatory)]$productName, [Parameter(Mandatory)]$companyName)

$directories = Get-ChildItem -Path $pathToFeatureFiles  -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

if(Test-Path .\output)
{
    Remove-Item .\output -recurse
}

New-Item -path .\output  -ItemType Directory

foreach($dir in $directories)
{
	$d = $dir -replace '@{FullName=', '' -replace '}', ''
	$parentDir = (Get-Item $d).Parent

	if($parentDir.Name -eq "features")
	{
		# handle features, example structure features\featureNameFolder\featurefile.feature
		$o = $d.split('\')[-1]
		New-Item -path .\output\$o  -ItemType Directory

		node features2html.js -p $productName -a $companyName -i $d create -o output\$o\$o.html
	}
	else
	{
		# handle nested features, sometimes file structures can go something like: features\featureNameFolder\specificPartOfFeatureFolder\featurefile.feature
		$o = $d.split('\')[-1]
		New-Item -path .\output\$parentDir\$o  -ItemType Directory

		node features2html.js -p $productName -a $companyName -i $d create -o output\$parentDir\$o\$o.html
	}
}

# below will need some tweeking to work with nested elements.  i might cry
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




