# 我的开发环境配置

这里是我的一些开发环境相关的配置和辅助工具。我平时开发的代码主要运行在 Linux 下，但开发机则有
iMac、MacBook、Windows、Linux 服务器等多种不同环境。

这些配置主要给 Linux（包括 docker 里的 Linux）使用，但大部分功能也适用于 macOS 下的终端。

`_` 开头的文件原本应该以 `.` 开头放在 HOME 目录下，由于某些 git 平台会隐藏 `.` 开头的文件，
改为了下划线 `_`。使用时需要恢复成正确的文件名，或者用符号链接的方式，更便于 `git pull` 升级。

## 安装

克隆本仓库：

```bash
git clone https://github.com/chen3feng/devenv.git
```

然后，创建你自己的配置文件：

- `~/.bashrc`（如果你用 bash）：
  ```bash
  source /path/to/this/devenv/_bashrc
  ```
- `~/.zshrc`（如果你用 zsh）：
  ```zsh
  source /path/to/this/devenv/_zshrc
  ```
- `~/.inputrc`（用于 readline，bash/python 等交互环境）：
  ```text
  $include /path/to/this/devenv/_inputrc
  ```
- `~/.vimrc`（如果你用 vim）：
  ```vim
  source /path/to/this/devenv/_vimrc
  ```

也提供了一个 [install](install) 脚本（Windows: [install.bat](install.bat)）用于自动安装。

## Shell

### shellrc

[shellrc](shellrc) 是 bash 和 zsh 共享的配置文件，由 `_bashrc` 和 `_zshrc` 分别 source。

### 自定义命令

详见 [shell/README.md](shell/README.md)。

| 命令 | 说明 |
| --- | --- |
| [alt_screen](shell/alt_screen) | 切换终端备用屏幕缓冲区 |
| [compare_version](shell/compare_version) | 比较两个点分版本号字符串 |
| [find_sources](shell/find_sources) | 查找指定后缀的源代码文件 |
| [path_manager](shell/path_manager) | 管理 PATH 等冒号分隔的环境变量 |
| [proxy](shell/proxy) | 开启/关闭 http_proxy / https_proxy / all_proxy |
| [trash_rm](shell/trash_rm) | 带回收站功能的 rm 命令 |
| [macos](shell/macos) | macOS 下载文件相关：移除隔离属性、签名放行应用 |

#### mkcd 命令

创建并进入目录，支持 `mkdir` 的各种参数（如 `-p`），最后一个参数为目标目录：

```console
$ mkcd 123
$ mkcd -p 1/2/3
```

#### mytop 命令

`top` 命令的别名，只显示当前用户的进程。

#### pinstall 命令

统一的包管理别名，根据系统不同，自动映射为 `apt install`、`yum install` 或 `brew install`。
（实验状态）

#### 常用设置

grep 自动带彩色，排除 `.svn`、`.git` 目录。

## .inputrc

这是 bash、python 交互环境等使用的 [readline](https://zh.wikipedia.org/zh-cn/GNU_Readline) 库的配置文件。

功能：
- 输入命令前缀后按 <kbd>↑</kbd><kbd>↓</kbd> 箭头，只匹配前缀相同的的历史命令
- <kbd>Shift</kbd>-<kbd>←</kbd> / <kbd>Shift</kbd>-<kbd>→</kbd> 以词为单位移动光标
- <kbd>Ctrl</kbd>-<kbd>←</kbd> / <kbd>Ctrl</kbd>-<kbd>→</kbd> 同上（Windows 上的 XShell 默认无法输入 Shift 组合键）
- macOS 上支持 <kbd>Delete</kbd>、<kbd>Home</kbd>、<kbd>End</kbd> 键
- `completion-ignore-case on`：补全忽略大小写
- `show-all-if-ambiguous on`：有歧义时直接显示所有补全选项

修改后执行 `bind -f ~/.inputrc` 或重新登录生效。

## .vimrc

VIM 的配置文件，功能：

- 基于 [Google 代码规范](http://google.github.io/styleguide/) 的格式控制
- 创建 C++ 头文件时自动插入 inclusion guard
- 创建 C++ test 文件时自动插入 gtest 头文件包含
- 打开文件时自动识别 GNU 代码风格路径，采用 GNU 代码风格
- 打开文件时光标自动跳到上次退出时的位置
- 显示 80/100 列标尺
- 自动识别不同文件的中文编码
- 自动识别终端编码
- 高亮显示代码中的 TAB 字符
- 彩色高亮 glog 日志文件中的错误、警告等信息
- <kbd>Ctrl</kbd>-<kbd>P</kbd> 触发代码补全
- 多 Tab 编辑：<kbd>Shift</kbd>-<kbd>←</kbd> 上一个文件，<kbd>Shift</kbd>-<kbd>→</kbd> 下一个文件
- 修改过的文件自动备份到 `~/.vimbackup` 目录
- 保存时自动删除行尾空白字符和多于的 `\r` 字符
- [QuickFix](http://vimcdoc.sourceforge.net/doc/quickfix.html) 快捷键：<kbd>F5</kbd> 构建，<kbd>F3</kbd>/<kbd>F4</kbd> 上/下一个错误，<kbd>F9</kbd> 切换 QuickFix 窗口
- `:Build` 自定义命令：不离开 vim 编译代码并进入 QuickFix 模式
- `:PlaybackBuildlog` 自定义命令：加载类似编译错误格式的日志文件，进入 QuickFix 模式

### QuickFix 模式

Vim 自动分析编译错误信息，在不离开 Vim 的情况下定位到出错行的一种快速代码修复模式。

### PlaybackBuildlog

`build.log` 泛指任何类似编译器错误格式的文本文件（包含文件名、行号、列号、错误信息），
编译器输出、`grep -n` 以及很多代码检查工具都能生成这种格式。

## XShell 的按键配置

Windows 上使用 XShell 时，如果不能输入 <kbd>Shift</kbd>-<kbd>←</kbd> 和
<kbd>Shift</kbd>-<kbd>→</kbd> 组合键，可用以下方法解决：

1. 打开【工具/按键对应】菜单
2. 点击【新建】按钮
3. 输入需要增加的组合键，弹出【编辑】窗口
4. 在【操作/类型】中选择【发送字符串】
5. 在【字串】编辑框中输入要发送的内容。如何知道应该发送什么？
   - 在能输入该组合键的终端（如 macOS 上的 iTerm）里执行 `cat` 命令，按键就会以
     [ANSI 转义序列](https://zh.wikipedia.org/wiki/ANSI%E8%BD%AC%E4%B9%89%E5%BA%8F%E5%88%97) 形式显示
   - 例如输入 <kbd>Shift</kbd>-<kbd>←</kbd> 会显示 `^[[1;2D`
   - 开头的 `^[` 是 [ESC](https://zh.wikipedia.org/wiki/%E9%80%80%E5%87%BA%E9%94%AE) 字符，
     需要通过 <kbd>Alt</kbd>+小键盘"27"输入
   - XShell 的编辑框不支持直接输入特殊字符，可以用记事本输入后复制粘贴
6. 点击【确定】生效

## 目录结构

| 目录 | 说明 |
| --- | --- |
| [bin/](bin) | 辅助工具，初始化 shell 后自动纳入 `PATH` |
| [docker/](docker) | 基于 Docker 的 Linux 开发环境，方便在 Mac/Windows 下进行 Linux 开发 |
| [git/](git) | Git hooks 和安装脚本 |
| [shell/](shell) | Shell 辅助函数和脚本，详见 [shell/README.md](shell/README.md) |
| [vs/](vs) | Visual Studio 相关配置 |
| [vscode/](vscode) | VS Code 远程开发相关配置 |
| [windows/](windows) | Windows 命令行相关配置和辅助脚本 |
| [xshell/](xshell) | XShell 配置文件，主要是主题 |
