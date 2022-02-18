# https://allthings.how/how-to-disable-xbox-game-bar-on-windows-11/
# https://www.windowsdigitals.com/how-to-remove-xbox-game-bar-from-windows-11/
# gamebar
Get-AppxPackage -AllUsers *Microsoft.XboxGameOverlay* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.XboxGamingOverlay* | Remove-AppxPackage
# disable popup Game DVR
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR -Name AppCaptureEnabled -Value 0
Set-ItemProperty -Path HKCU:\System\GameConfigStore -Name GameDVR_Enabled -Value 0

# other apps
Get-AppxPackage *Microsoft.Xbox.TCUI* | Remove-AppxPackage
Get-AppxPackage *Microsoft.XboxApp* | Remove-AppxPackage
Get-AppxPackage *Microsoft.GamingServices* | Remove-AppxPackage
Get-AppxPackage *Microsoft.XboxIdentityProvider* | Remove-AppxPackage
Get-AppxPackage *Microsoft.XboxSpeechToTextOverlay* | Remove-AppxPackage