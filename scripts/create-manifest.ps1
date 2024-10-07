# Parse parameters
param (
    [string]$OutputPath = "./tools-manifest.md"
)


# Command-Let
function ConvertTo-Markdown {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject[]]$InputObject
    )

    begin {
        $markdown = @()
        $markdown += "## Build Tools Manifest"
        $markdown += "| Name | Version |"
        $markdown += "| ---- | ------- |"
    }

    process {
        foreach ($object in $InputObject) {
            $markdown += "| $($object.Name) | $($object.Version) |"
        }
    }

    end {
        $markdown -join "`r`n"
    }
}

# Gather manifest information for the current environment
$os = Get-WmiObject -Class Win32_OperatingSystem
$manifest = @(
    [PSCustomObject]@{
        Name = $os.Caption
        Version = $os.Version
    }
)

$sdks = Get-ChildItem -Path "C:\Program Files (x86)\Windows Kits\10\Include" -Directory
foreach ($sdk in $sdks) {
    $manifest += [PSCustomObject]@{
        Name = "Microsoft Windows SDK"
        Version = $sdk.Name
    }
}

$manifest += [PSCustomObject]@{
    Name = "Microsoft Visual Studio 2022 Build Tools"
    Version = $env:VSCMD_VER
}

$frameworks = Get-ChildItem -Path "C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework" -Directory | Where-Object { $_.Name -match "v4\.8(.\d+)?" }
foreach ($framework in $frameworks) {
    $manifest += [PSCustomObject]@{
        Name = "Microsoft .NET Framework"
        Version = $framework.Name
    }
}

$apps = (scoop list) | Where-Object { 
    ($_.Name -like "nuget" ) -or 
    ($_.Name -like "cmake" ) -or
    ($_.Name -like "ninja" ) -or
    ($_.Name -like "python") -or
    ($_.Name -like "conan" ) -or
    ($_.Name -like "git"   )
}
foreach ($app in $apps) {
    $manifest += [PSCustomObject]@{
        Name = $app.Name
        Version = $app.Version
    }
}

$manifest | Format-Table -Property Name, Version

$markdown = $manifest | ConvertTo-Markdown
Write-Output $markdown | Out-File -FilePath $OutputPath