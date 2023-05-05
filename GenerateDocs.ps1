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
$content = "" 

## handle feature files in main output folder
$mainOutputFeatures = Get-ChildItem -Path ".\output" -File -Force -ErrorAction SilentlyContinue | Select-Object Name

if(!$mainOutputFeatures -eq 0)
{
	$mainOutputFiles = Get-ChildItem -Path ".\output" -File -Force -ErrorAction SilentlyContinue | Select-Object Name
	
	foreach($outputFeatureFile in $mainOutputFiles)
	{
		$mainOutputFileName = Split-Path $outputFeatureFile -leaf
		$mainOutputFileLinkText = $mainOutputFileName -replace '.html}', '' -replace '@{Name=', ''
		$mainOutputLink = $outputFeatureFile -replace '@{Name=', '<a href ="' -replace '}', "`">$($mainOutputFileLinkText)</a></br></br>"`

		$content += $mainOutputLink
	}
}

## Do stuff with folders that have no sub folders
$outputFeatureFoldersFirstPass = Get-ChildItem -Path ".\output" -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

foreach($firstPassFolder in $outputFeatureFoldersFirstPass)
{	
	$name = Split-Path $firstPassFolder -leaf
	$fol = $name -replace '}', ""
	$fPath = $firstPassFolder -replace '@{FullName=', '' -replace '}', ''

	$hasAnySubdir = Get-ChildItem -Path $fPath -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName
	
	Write-Host 'Checking folder ' $fol

	if($hasAnySubdir.Count -gt 0)
	{
		Write-Host $fol 'has' $hasAnySubdir.count 'subfolders, skipping until next pass'
	}
	else
	{
		Write-Host $fol 'has' $hasAnySubdir.count 'subfolders, creating html for index page'

		# create main folder button
		$button = "<button type='button' class='collapsible'>$($fol)</button><div class='content'>"
		$content += $button

		#get feature files in that folder
		$outputFeatureFiles = Get-ChildItem -Path $($fPath) -File -Force -ErrorAction SilentlyContinue | Select-Object FullName
		
		foreach($feature in $outputFeatureFiles)
		{
			$featureName = Split-Path $feature -leaf
			$linkText = $featureName -replace '.html}', ''
			$link = $feature -replace '@{FullName=', '<a href ="' -replace '}', "`">$($linkText)</a></br></br>"`

			$content += $link

			if ($feature -eq $outputFeatureFiles[-1]) 
			{
				$content += "</div>" 
			}
		}
	}
}


## Do stuff with folders that have sub folders
$outputFeatureFolders = Get-ChildItem -Path ".\output" -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

foreach($folder in $outputFeatureFolders)
{	
	$folderName = Split-Path $folder -leaf
	$fn = $folderName -replace '}', ""
	$f = $folder -replace '@{FullName=', '' -replace '}', ''

	$hasAnySubdir = Get-ChildItem -Path $f -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName
	
	if($hasAnySubdir.Count -eq 0)
	{
		Write-Host $fn 'has' $hasAnySubdir.count 'subfolders, skipping'
	}
	else
	{
		Write-Host $fn 'has' $hasAnySubdir.count 'subfolders, creating html for index page'

		# create main folder button
		$button = "<button type='button' class='collapsible'>$($fn)</button><div class='content'>"
		$content += $button

		#get feature files in that folder
		$path = $folder -replace '@{FullName=', "" -replace '}', ""
		$outputFeatureFiles = Get-ChildItem -Path $($path) -File -Force -ErrorAction SilentlyContinue | Select-Object FullName
		
		foreach($file in $outputFeatureFiles)
		{
			$fileName = Split-Path $file -leaf
			$linkText = $fileName -replace '.html}', ''
			$link = $file -replace '@{FullName=', '<a href ="' -replace '}', "`">$($linkText)</a></br></br>"`

			$content += $link
		}
		
		foreach($sub in $hasAnySubdir)
		{
			$subName = Split-Path $sub -leaf
			$sn = $subName -replace '}', ""
			$sd = $sub -replace '@{FullName=', '' -replace '}', ''

			Write-Host 'Creating index html for' $fn '/' $sn

			$subButton = "<button type='button' class='collapsible2'>$($sn)</button><div class='content2'>"

			$content += $subButton

			$subOutputFeatureFiles = Get-ChildItem -Path $($sd) -File -Force -ErrorAction SilentlyContinue | Select-Object FullName
		
			foreach($subFile in $subOutputFeatureFiles)
			{
				$subFileName = Split-Path $subFile -leaf
				$subLinkText = $subFileName -replace '.html}', ''
				$subLink = $subFile -replace '@{FullName=', '<a href ="' -replace '}', "`">$($subLinkText)</a></br></br>"`

				$content += $subLink

				if ($file -eq $outputFeatureFiles[-1]) 
				{
					$content += "</div>" 
				}
			}
		}
		
		$content += "</div>" 	
	}
}

### create index page for all of our feature files to be displayed

New-Item -path .\output\index.html  -ItemType File -Force

$html = "<html><head><title>Feature documentation</title><link rel='stylesheet' href= '../default/templates/style.css'></head><header>
<div>Feature documentation</div></header>
<body><h1>Feature Index</h1>
<p>To gain an understanding of product functionality please select a feature</p>
<div class='contentIndex'>$($content)</div> 
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

