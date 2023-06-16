# Windows

一些 Windows 命令行下的便利工具。

## 目录列表

### 类 Unix 命令别名

在 Windows 命令提示符下支持 `ls`、`pwd`、`cat`、`mkdir`、`rm` 等命令别名。

### CD 命令增强

- cd -  ::返回先前目录
- cd ~  ::进入HOME目录
- ..    ::进入上一级目录
- ...   ::进入上上一级目录
- ....  ::依此类推...

### Git 增强

在命令提示符中显示当前分支

```console
C:\Work\code\devenv (master) > git push
```

## 安装

```console
.\install.bat
```

## 查询

```console
reg query "HKCU\Software\Microsoft\Command Processor" /v Autorun
```
