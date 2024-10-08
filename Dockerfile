# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

RUN `
    # Download build tools bootstrapper
    curl.exe -fSLo vs_buildtools.exe https://download.visualstudio.microsoft.com/download/pr/1ddfd51d-41a3-4a5f-bb23-a614eadbe85a/0424cf7a010588b8dd9a467c89c57045a24c0507c5c6b6ffc88cead508b5f972/vs_BuildTools.exe `
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
   scoop install nuget@5.11.1 cmake@3.25.1 ninja@1.12.1 python@3.10.6 conan@2.8.0 git@2.31.1; `
   && (del /q C:\scoop.ps1)

LABEL maintainer="Rajeshwar Raja <rajeshwarraja@gmail.com>"

# Define the entry point for the container.
ENTRYPOINT [ "C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass" ]