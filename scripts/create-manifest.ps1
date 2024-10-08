# Parse parameters
param (
    [string]$OutputPath = "./tools-manifest.md"
)


# Command-Let
function ConvertTo-BuildToolsManifest {
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

# tools dark and 7zip are excluded from the manifest since
# they are used only fdor Scoop installation process; not used in build
$apps = (scoop list) | Where-Object { 
    ($_.Name -notlike "7zip" ) -and 
    ($_.Name -notlike "dark" ) 
}
foreach ($app in $apps) {
    $manifest += [PSCustomObject]@{
        Name = $app.Name
        Version = $app.Version
    }
}

$manifest | Format-Table -Property Name, Version
$manifest | ConvertTo-BuildToolsManifest | Out-File -FilePath $OutputPath -Encoding utf8
