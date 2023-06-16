# Windows

一些 Windows 下的便利工具。

## DOSKEY

在 Windows 命令提示符下支持 `ls`、`pwd`、`cat`、`mkdir`、`rm` 等命令别名。

## Git

在命令提示符中显示当前分支

```console
C:\Work\code\devenv (master) > git push
```

安装：

```console
.\install.bat
```

查询：

```console
reg query "HKCU\Software\Microsoft\Command Processor" /v Autorun
```
