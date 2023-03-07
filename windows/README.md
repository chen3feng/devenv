# Windows

一些 Windows 下的便利工具。

## DOSKEY

在 Windows 命令提示符下支持 `ls`、`pwd`、`cat`、`mkdir`、`rm` 等命令别名。

安装：

```console
reg add "HKCU\Software\Microsoft\Command Processor" /v Autorun /d "doskey /macrofile=\"C:\Users\chen3\doskey.macros\"" /f
```

查询：

```console
reg query "HKCU\Software\Microsoft\Command Processor" /v Autorun
```
