# Windows

一些 Windows 命令行下的便利工具。

## 目录列表

### 类 Unix 命令

在 Windows 命令提示符下支持一些 Unix 命令：

- `cat`
- `clear`
- `cp`
- `ls`
- `mkdir`
- `pwd`
- `rm`
- `sleep`
- `touch`
- `wc`
- `which`
- `whoami`
- `xargs`

### CD 命令增强

- `cd -`  ::返回先前目录
- `cd ~`  ::进入HOME目录
- `..`    ::进入上一级目录
- `...`   ::进入上上一级目录
- `....`  ::依此类推...

### sudo

用管理员权限执行

```console
sudo notepad C:\Windows\System32\drivers\etc\hosts
```

### timer

类似于 Linux 下的 `time` 命令，衡量命令的执行时间。不能叫 `time` 是因为 Windows 上已经存在 `time`。

### Git 增强

在命令提示符中显示当前分支名，红色表示有未提交的修改，绿色表示没有。

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
