@echo off
setlocal

rem install https://www.nuget.org/packages/dotnet-mgfxc/

del *.mgfxo

mgfxc ..\TextureCubeDrawEffect.fx TextureCubeDrawEffect.ogl.mgfxo
mgfxc ..\TextureCubeDrawEffect.fx TextureCubeDrawEffect.dx11.mgfxo /Profile:DirectX_11

endlocal
pause