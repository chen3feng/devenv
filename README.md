tools
=====

Put develop tools here, such as style check and editing

# .vimrc
功能
* 设置基于google代码规范的格式控制
* 创建c++头文件时自动插入符合google代码规范的inclusion guard
* 创建C++ test文件时，自动插入#include gtest头文件的包含
* 打开文件时自动识别GNU代码风格的路径，采用gnu代码风格
* 打开文件时插入符自动跳到上次退出时的位置
* 显示80/100列标尺，防止代码行太长
* 自动识别不同文件的中文编码，避免解码错误导致的乱码
* 自动识别终端编码，避免显示乱码
* 高亮显示代码中的TAB字符
* 以彩色高亮显示glog日志文件中的错误，警告等信息
* 编辑时，<Ctrl-P>触发代码补全
* 编辑多Tab文件时，<C-S-Left>到上一个文件，<C-S-Right到下一个文件>
* 修改过的文件自动被分到~/.vimbackup目录下
* 保存时，自动删除行尾空白字符，对unix格式文本文件自动删除多余的\r字符
* [QuickFix模式](http://vimcdoc.sourceforge.net/doc/quickfix.html)快捷键：F5构建代码(执行blade build命令)，F3上一个错误，F4下一个错误，F9切换QuickFix窗口
* `:Blade`自定义命令，不离开vim，编译代码，并进入QuickFix模式
* `:PlaybackBuildlog`自定义命令，用于加载任意类似编译错误的代码构建检查日志文件，进入QuickFix模式

## QuickFix模式
Vim里自动分析编译错误信息，在不离开Vim的情况下，定位到各个出错行的一种快速代码修复模式

## PlaybackBuildlog
这里的build.log是指任何类似编译器错误信息格式的文本文件，包含文件名，行号，（列号），错误信息，除了编译器，grep带上-n参数，以及很多代码检查工具，都能生成这种格式。
