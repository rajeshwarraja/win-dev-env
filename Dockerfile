# escape=`

# tags from: https://mcr.microsoft.com/en-us/artifact/mar/windows/servercore/tags
FROM mcr.microsoft.com/windows/servercore:ltsc2025

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

RUN `
    # Download build tools bootstrapper
    # Download link from: https://learn.microsoft.com/en-us/visualstudio/releases/2026/release-history
    curl.exe -fSLo vs_buildtools.exe https://download.visualstudio.microsoft.com/download/pr/e05c0bc8-d058-4b2b-937c-1c80073d7633/b62e8829c6a6c043aacf2ef657456213ab71099c7e46a610f95d6778bfc9beb0/vs_BuildTools.exe`
    `
    # Install Build Tools
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
      --installPath C:\BuildTools `
      `
      --add Microsoft.VisualStudio.Workload.VCTools `
      --remove Microsoft.VisualStudio.Component.VC.CMake.Project `
      --remove Microsoft.VisualStudio.Component.TestTools.BuildTools `
      `
      --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools `
    ) `
    `
    # Cleanup
    && del /q vs_buildtools.exe

RUN `
   powershell `
   # Enable long paths
   Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name LongPathsEnabled -Value 1 -Type DWord -Force

RUN `
   powershell -ExecutionPolicy RemoteSigned `
   # Install Scoop
   Invoke-WebRequest -Uri https://get.scoop.sh -outfile C:\scoop.ps1; C:\scoop.ps1 -RunAsAdmin; `
   # Install NuGet, CMake, Ninja and Conan
   scoop install nuget cmake ninja python conan git; `
   && (del /q C:\scoop.ps1)

LABEL maintainer="Rajeshwar Raja <rajeshwarraja@gmail.com>"

# Define the entry point for the container.
ENTRYPOINT [ "C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass" ]
