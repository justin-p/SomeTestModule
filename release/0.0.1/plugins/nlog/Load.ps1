Import-Module (Join-Path $MyModulePath 'plugins\nlog\nlogmodule\nlogmodule.psd1') -Force -Scope:Global
Register-NLog -FileName (Join-Path $ENV:TEMP 'SomeTestModule.log') -LoggerName 'SomeTestModule'
