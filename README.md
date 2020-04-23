tools
=====

Put develop tools here, such as style check and editing.

一些开发相关的配置和辅助工具。

由于某些 git 平台的限制，`.` 开头的文件名改为了下划线 `_`，使用时需要恢复，或者用符号链接的方式使用。

# .vimrc
功能
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
* 编辑时，<kbd>Ctrl</kbd>+<kbd>P</kbd>触发代码补全
* 多Tab编辑文件时，<kbd>Shift</kbd>+<kbd>Left</kbd>到上一个文件，<kbd>Shift</kbd>+<kbd>Right</kbd>到下一个文件
* 修改过的文件自动被分到 `~/.vimbackup` 目录下
* 保存时，自动删除行尾空白字符，对unix格式文本文件自动删除多余的 `\r` 字符
* [QuickFix模式](http://vimcdoc.sourceforge.net/doc/quickfix.html)快捷键：<kbd>F5</kbd> 构建代码(执行blade build命令)，<kbd>F3</kbd> 上一个错误，<kbd>F4</kbd> 下一个错误，<kbd>F9</kbd> 切换QuickFix窗口
* `:Blade` 自定义命令，不离开 vim，编译代码，并进入 QuickFix 模式
* `:PlaybackBuildlog` 自定义命令，用于加载任意类似编译错误的代码构建检查日志文件，进入 QuickFix 模式

## QuickFix模式
Vim 里自动分析编译错误信息，在不离开 Vim 的情况下，定位到各个出错行的一种快速代码修复模式

## PlaybackBuildlog
这里的 `build.log` 是指任何类似编译器错误信息格式的文本文件，包含文件名，行号，（列号），错误信息，除了编译器，`grep` 带上 `-n` 参数，以及很多代码检查工具，都能生成这种格式。

# .bashrc

## trash\_rm
对 `rm` 和 `mv` 命令增加回收站功能

## find\_sources
对 `find` 命令的包装，用于搜索源代码文件
```bash
# 查找所有的 c/c++ 源代码（包括头文件）
findallcc | xargs grep '#include'
```

## 常用命令的设置
grep 自动带彩色，排除 `.svn`、`.git` 目录

## mytop
在 top 命令中只显示自己用户的进程

# .inputrc
输入命令的前缀，然后按上下箭头就只出匹配前缀的历史命令。
