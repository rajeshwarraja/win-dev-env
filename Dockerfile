# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

RUN `
    # Download build tools bootstrapper
    curl.exe -fSLo vs_buildtools.exe https://aka.ms/vs/17/release.ltsc.17.8/vs_buildtools.exe `
    `
    # Install Build Tools
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
      --installPath C:\BuildTools `
      `
      --includeRecommended `
      `
      --add Microsoft.VisualStudio.Workload.VCTools `
      --remove Microsoft.VisualStudio.Component.VC.CMake.Project `
      --remove Microsoft.VisualStudio.Component.TestTools.BuildTools `
      --add Microsoft.VisualStudio.Component.VC.ATL `
      --add Microsoft.VisualStudio.Component.VC.ATLMFC `
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