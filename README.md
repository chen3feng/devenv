# 我的开发环境配置

这里是我的一些开发环境相关的配置和辅助工具。我平时开发的代码主要运行在 Linux 下，但是开发机则有
iMac、MacBook、Windows 7、Linux 服务器等多种不同环境。除了 Linux 服务器环境是公司内使用的外，其余
的个人使用较多，这部分配置主要是针对这些环境服务的。

我平时编辑代码虽然也在增加用 VS Code 的时间，但是由于强大的习惯力量，还是以 vim 为主，zsh 也是最近
刚开始使用。

这些配置主要是给 Linux（包括 docker 里的 Linux）使用，但是大部分功能也适用于 Mac 下的终端。

`_` 开头的文件都是原本应该以`.`开头的放在 HOME 目录下的，由于某些 git 平台的限制，改为了下划线 `_`。
使用时需要恢复成正确的文件名，或者用符号链接的方式使用，更方便。
`git pull` 即可升级。方法如下：

## 安装

在你自己的开发机上 clone 本仓库：
```bash
git clone https://github.com/chen3feng/devenv.git
```

然后，创建你自己的配置文件：

- 你的 ~/.bashrc（如果你用 zsh）：
  ```bash
  source /path/to/this/devenv/_bashrc
  ```
- 你的 ~/.inputrc（如果你用 bash）：
  ```inputrc
  $include /path/to/this/devenv/_inputrc
  ```
- 你的 ~/.zshrc（如果你用 zsh）：
  ```zsh
  source /path/to/this/devenv/_zshrc
  ```
- 你的 ~/.vimrc（如果你用 vim）：
  ```vim
  source /path/to/this/devenv/_vimrc
  ```

我也提供了一个简单的 `install` 命令以自动安装。

## Shell

### .bashrc

bash 基本配置。

### .zshrc

最近在试用 zsh，配合 zinit，开启了语法高亮和智能补全，感觉还不错（试过 oh-my-zsh 感觉太慢，放弃了），
也配置了以上的按键支持。

### 一些自定义的便利的命令

#### trash\_rm

对 `rm` 命令增加回收站功能，根据系统不同，被删除的文件或者目录会被移到不同的回收站目录里：

- MacOS：系统垃圾篓，也就是 `~/.Trash` 目录，可以用 `Finder.app` 查看
- 其他系统：`~/.local/trash` 目录

使用 `-D` 参数绕过回收站直接删除。

#### find\_sources

对 `find` 命令的包装，用于搜索源代码文件：
```bash
# 查找所有的 c/c++ 源代码（包括头文件）
findallcc | xargs grep '#include'
```

#### 常用命令的设置

grep 自动带彩色，排除 `.svn`、`.git` 目录。

#### mkcd 命令

创建并立即进入目录，支持 `mkdir` 的各种参数，比如 `-p` 等，只允许支持一个目录名参数。

示例：

```
mkcd 123
mkcd -p 1/2/3
```

#### mytop 命令

在 top 命令中只显示自己用户的进程。

#### pinstall 命令

统一的包管理命令别名，根据系统的不同，实际可能是 `apt install`、`yum install`、`brew install`。
此命令仅为减少一点输入量，没有任何其他功能。
（当前为实验状态）

## .inputrc

这是 bash，python 交互环境等用的 [readline](https://zh.wikipedia.org/zh-cn/GNU_Readline) 库的配置文件。
功能：
- 输入命令的前缀，然后按<kbd>↑</kbd><kbd>↓</kbd>箭头就只出匹配前缀的历史命令。
- 输入 <kbd>Shift</kbd>-<kbd>←</kbd> 和 <kbd>Shift</kbd>-<kbd>→</kbd> 以词为单位移动光标
- 同上，只是换为 <kbd>Ctrl</kbd> 键，因为 Windows 上的 XShell 默认无法输入以上组合键
- Mac 上支持 <kbd> Delete</kbd> 键和 <kbd>Home</kbd> 和 <kbd>End</kbd> 键

修改后输入 <kbd>Ctrl</kbd>-<kbd>X</kbd> <kbd>Ctrl</kbd>-<kbd>R</kbd> 或者执行 `bind -f  ~/.inputrc`
生效，如果不行，尝试重新登录。

## .vimrc

VIM 的配置文件，功能：
* 设置基于 [google 代码规范](http://google.github.io/styleguide/)的格式控制
* 创建 c++ 头文件时自动插入符合 google代码规范的 inclusion guard
* 创建 C++ test 文件时，自动插入 #include gtest 头文件的包含
* 打开文件时自动识别GNU代码风格的路径，采用 gnu 代码风格
* 打开文件时插入符自动跳到上次退出时的位置
* 显示 80/100 列标尺，防止代码行太长
* 自动识别不同文件的中文编码，避免解码错误导致的乱码
* 自动识别终端编码，避免显示乱码
* 高亮显示代码中的 TAB 字符
* 以彩色高亮显示 glog 日志文件中的错误，警告等信息
* 编辑时，<kbd>Ctrl</kbd>-<kbd>P</kbd>触发代码补全
* 多Tab编辑文件时，<kbd>Shift</kbd>-<kbd>←</kbd> 到上一个文件，<kbd>Shift</kbd>-<kbd>→</kbd> 到下一
  个文件
* 修改过的文件自动备份到 `~/.vimbackup` 目录下
* 保存时，自动删除行尾空白字符，对unix格式文本文件自动删除多余的 `\r` 字符
* [QuickFix模式](http://vimcdoc.sourceforge.net/doc/quickfix.html)快捷键：<kbd>F5</kbd> 构建代码
  (执行blade build命令)，<kbd>F3</kbd> 上一个错误，<kbd>F4</kbd> 下一个错误，<kbd>F9</kbd> 切换
  QuickFix 窗口
* `:Build` 自定义命令，不离开 vim，编译代码，并进入 QuickFix 模式，比如 `:Build blade build ...`
* `:PlaybackBuildlog` 自定义命令，用于加载任意类似编译错误的代码构建检查日志文件，进入 QuickFix 模式

### QuickFix模式

是指 Vim 里自动分析编译错误信息，在不离开 Vim 的情况下，定位到各个出错行的一种快速代码修复模式。

### PlaybackBuildlog

这里的 `build.log` 是指任何类似编译器错误信息格式的文本文件，包含文件名，行号，（列号），错误信息，
除了编译器，`grep` 带上 `-n` 参数，以及很多代码检查工具，都能生成这种格式。

## XShell 的问题

我在 Windows 上主要使用 XShell，但是发现它不能输入 <kbd>Shift</kbd>-<kbd>←</kbd> 和
<kbd>Shift</kbd>-<kbd>→</kbd> 组合键，用以下方法可以解决：

- 点击打开【工具/按键对应】菜单
- 按【新建】按钮
- 输入需要增加的组合键，就会弹出【编辑】窗口
- 在【操作/类型】里选择【发送字符串】
- 在【字串】编辑框里输入要发送的内容，如何知道应该发送什么按键呢？也许可以查表，但是我用的是更直接的方式：
  - 在其他能输入该组合键的终端（比如 Mac 上的 iTerm）里输入 `cat` 命令，按键就会以
    [ANSI 转义序列](https://zh.wikipedia.org/wiki/ANSI%E8%BD%AC%E4%B9%89%E5%BA%8F%E5%88%97)的方式显示出来
  - 比如如果输入 <kbd>Shift</kbd>-<kbd>←</kbd> 就会显示 `^[[1;2D`
  - 如果你真照着输入就错了，因为开头的 `^[` 实际上是 [<kbd>ESC</kbd>](https://zh.wikipedia.org/wiki/%E9%80%80%E5%87%BA%E9%94%AE)
    字符，需要通过按<kbd>Alt</kbd>+小键盘“27”来输入
  - 但是 XShell 的这个编辑框不支持这么输入特殊字符，所以得换个编辑器，比如【记事本】，输入后复制过来
- 输入完成后，点击【确定】生效

## 目录结构

### [bin 目录](bin)

一些便利的辅助工具，通过本仓库初始化 shell 后就会被自动纳入 `PATH` 环境变量，可以直接使用。

### [docker 目录](docker)

基于 docker 的 Linux 开发环境，方便在 Mac/Windows 下进行 Linux 开发，并确保使用相同的工具集合。

### [shell 目录](shell)

shell 辅助函数等，使用时无需关心。

### [vscode 目录](vscode)

由于 VS Code 支持了远程开发，我就在学习和逐渐转移到上面去，记录一些相关的信息。

### [xshell 目录](xshell)
xshell 的一些配置文件，主要是一些主题。
