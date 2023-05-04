param ([Parameter(Mandatory)]$pathToFeatureFiles, [Parameter(Mandatory)]$productName, [Parameter(Mandatory)]$companyName)

$directories = Get-ChildItem -Path $pathToFeatureFiles  -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName
$mainDir = "features" # default to features

if(Test-Path .\output)
{
    Remove-Item .\output -recurse
}

New-Item -path .\output  -ItemType Directory

## handle feature files in main feature folder
$rootFeatureFiles = (Get-ChildItem -Path $pathToFeatureFiles -force | Where-Object Extension -in ('.feature') | Measure-Object).Count

if(!$rootFeatureFiles -eq 0)
{
	$files = Get-ChildItem -Path $($pathToFeatureFiles) -File -Force -ErrorAction SilentlyContinue | Select-Object Name
	
	foreach($file in $files)
	{
		$fileName = $file -replace '@{Name=', "" -replace '.feature', "" -replace '}', ""

		node features2html.js -p $productName -a $companyName create -o output\$fileName.html
	}
}

## handle feature files in directories
foreach($dir in $directories)
{
	$d = $dir -replace '@{FullName=', '' -replace '}', ''
	$parentDir = (Get-Item $d).Parent

	if($parentDir.Name -eq $mainDir)
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

### files to HTML elements ###

$buttons = @()
$content = "" 

## handle feature files in main output folder
$outputFeatures = Get-ChildItem -Path ".\output" -File -Force -ErrorAction SilentlyContinue | Select-Object Name

if(!$outputFeatures -eq 0)
{
	$files = Get-ChildItem -Path ".\output" -File -Force -ErrorAction SilentlyContinue | Select-Object Name
	
	foreach($file in $files)
	{
		$fileName = Split-Path $file -leaf
		$linkText = $fileName -replace '.html}', '' -replace '@{Name=', ''
		$link = $file -replace '@{Name=', '<a href ="' -replace '}', "`">$($linkText)</a></br></br>"`

		$content += $link
	}

	$buttons += $content
}

## handle feature files in folders
$outputFeatureFolders = Get-ChildItem -Path ".\output" -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

foreach($folder in $outputFeatureFolders)
{	
	$folderName = Split-Path $folder -leaf
	$fn = $folderName -replace '}', ""
	$f = $folder -replace '@{FullName=', '' -replace '}', ''

	$parentDir = (Get-Item $f).Parent

	if($parentDir.Name -eq "output")
	{
		$button = "<button type='button' class='collapsible'>$($fn)</button><div class='content'>"
	
		$path = $folder -replace '@{FullName=', "" -replace '}', ""

		$outputFeatureFiles = Get-ChildItem -Path $($path) -File -Force -ErrorAction SilentlyContinue | Select-Object FullName
		
		foreach($file in $outputFeatureFiles)
		{
			$fileName = Split-Path $file -leaf
			$linkText = $fileName -replace '.html}', ''
			$link = $file -replace '@{FullName=', '<a href ="' -replace '}', "`">$($linkText)</a></br></br>"`

			$content = $button + $link

			$hasAnySubdir = (Get-ChildItem -Directory $f).Count
			
			if ($file -eq $outputFeatureFiles[-1] -And $hasAnySubdir -eq 0) 
			{
				$content += "</div>" 
			}
		}
	}
	else
	{
		$button = "<button type='button' class='collapsible2'>$($fn)</button><div class='content2'>"
	
		$path = $folder -replace '@{FullName=', "" -replace '}', ""

		$outputFeatureFiles = Get-ChildItem -Path $($path) -File -Force -ErrorAction SilentlyContinue | Select-Object FullName
		
		foreach($file in $outputFeatureFiles)
		{
			$fileName = Split-Path $file -leaf
			$linkText = $fileName -replace '.html}', ''
			$link = $file -replace '@{FullName=', '<a href ="' -replace '}', "`">$($linkText)</a></br></br>"`

			$content = $button + $link

			if ($file -eq $outputFeatureFiles[-1]) 
			{
				$content += "</div>" 
			}
		}
	}

	$buttons += $content
}

### create index page for all of our feature files to be displayed

New-Item -path .\output\index.html  -ItemType File -Force

$html = "<html><head><title>Feature documentation</title><link rel='stylesheet' href= '../default/templates/style.css'></head><header>
<div>Feature documentation</div></header>
<body><h1>Feature Index</h1>
<p>To gain an understanding of product functionality please select a feature</p>
<div class='contentIndex'>$($buttons)</div> 
<script>
var coll = document.getElementsByClassName('collapsible');
var i;
for (i = 0; i < coll.length; i++) {
  coll[i].addEventListener('click', function () {
	this.classList.toggle('active');
	var content = this.nextElementSibling;
	if (content.style.maxHeight) {
	  content.style.maxHeight = null;
	} else {
	  content.style.maxHeight = content.scrollHeight + 'px';
	}
  });
}
</script>

<script>
var coll = document.getElementsByClassName('collapsible2');
var i;
for (i = 0; i < coll.length; i++) {
  coll[i].addEventListener('click', function () {
	this.classList.toggle('active');
	var content = this.nextElementSibling;
	if (content.style.maxHeight) {
	  content.style.maxHeight = null;
	} else {
	  content.style.maxHeight = content.scrollHeight + 'px';
	}
  });
}
</script>
</html>"

Set-Content -Path .\output\index.html -Value $html

