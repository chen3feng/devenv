# Windows

一些 Windows 命令行下的便利工具。

## 目录列表

### 类 Unix 命令

在 Windows 命令提示符下支持一些 Unix 命令：

- `cat`
- `clear`
- `cp`
- `history`
- `kill`
- `killall`
- `ls`
- `ll`
- `mkdir`
- `pwd`
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

### alt-screen

同 Linux 版。

### lsr

类似 POSIX 的 `find . -name 'pattern'`，递归查找当前目录及子目录下所有匹配的文件：

不带参数列出所有文件：

```console
C:\Work\code\devenv>lsr
...
```

带参数列出匹配的文件：

```console
C:\Work\code\devenv>lsr *.bat
C:\Work\code\devenv\install.bat
C:\Work\code\devenv\git\install.bat
C:\Work\code\devenv\windows\autorun.bat
C:\Work\code\devenv\windows\cd-wrapper.bat
...
```

带参数列出匹配的文件：

```console
C:\Work\code\devenv>lsr *.bat
C:\Work\code\devenv\install.bat
C:\Work\code\devenv\git\install.bat
C:\Work\code\devenv\windows\autorun.bat
C:\Work\code\devenv\windows\cd-wrapper.bat
...
```

通配符可以有目录前缀：

```console
C:\Work\code\devenv>lsr windows\kill*.bat
C:\Work\code\devenv\windows\bin\kill.bat
C:\Work\code\devenv\windows\bin\killall.bat
```

### npp

用 [Notepad++](https://notepad-plus-plus.org/) 打开文件。

### rm

删除到回收站，用法和 Linux 下的一样。

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

PowerShell 下同样支持，分支名的红/绿含义一致。采用两行布局，第一行显示「仓库相对路径 + 分支」，第二行输入命令，这样无论路径或分支名多长，光标都从最左侧开始：

```console
devenv  (master)
> git push
```

### PowerShell 路径变量管理

`shell/path_manager` 的 PowerShell 版，管理 `PATH` 这类以 `;` 分隔的路径变量，去重后追加/前置：

```powershell
Add-Path C:\tools                 # 追加到 PATH（默认变量），仅当前会话（默认 Process）
Add-Path C:\tools -Prepend        # 放到最前
Add-Path C:\tools -Scope User     # 持久化到用户级，并同步到当前会话
Add-Path D:\lib -Name LIB -Scope Machine   # 系统级（需管理员）
Remove-Path C:\tools              # 移除
Get-Path                          # 列出 PATH，每行一条（可接管道过滤）
Get-Path PSModulePath -Scope User # 列出指定变量、指定作用域
```

- 默认变量为 `PATH`，默认作用域为 `Process`（只影响当前交互）。
- 已存在的路径会**提示并忽略**（大小写、结尾斜杠不敏感）。
- `Get-Path` 返回字符串数组，可 `Get-Path | Where-Object { ... }` 过滤。

### SSH 公钥授权

让别的机器（如 Mac）用密钥免密登录本机的 OpenSSH。当 Windows 账户没设密码时尤其有用——Windows 禁止空密码账户走网络登录，密钥是唯一的路。[Authorize-SshKey.ps1](Authorize-SshKey.ps1) 会自动按账户类型选对位置和 ACL：

```powershell
# 管理员账户需在「管理员 PowerShell」里运行（写 C:\ProgramData\ssh）
.\Authorize-SshKey.ps1 'ssh-ed25519 AAAA... user@mac'
.\Authorize-SshKey.ps1 -Path C:\Users\cf\mac.pub
```

- 管理员账户 → `C:\ProgramData\ssh\administrators_authorized_keys`，并把 ACL 限制为 Administrators + SYSTEM。
- 普通账户 → `%USERPROFILE%\.ssh\authorized_keys`。
- 账户类型按**组成员身份**判断（不受是否提权影响），管理员账户在非提权窗口运行会提示需要提权，避免把公钥误写到读不到的位置。
- 同一公钥重复授权会自动跳过。

## 安装

```console
.\install.bat
```

## 查询

```console
reg query "HKCU\Software\Microsoft\Command Processor" /v Autorun
```
