# VS Code

我平时写代码主要在无 GUI 的 Linux 开发服务器上，通过 SSH 登录上去进行开发，过去基本是以 Vim 为主，
目前正在逐渐增 VS Code 的使用，VS Code 的远程开发和丰富的插件支持是主要吸引我的地方。
特别是编辑 Markdown 文件时的预览功能，非常方便，远程开发时，终端下的 vim 是难以做到的（也许远程起个 web 服务器可以？）。

## 设置

大部分设置可以通过进入设置选单【Mac:Code/Perference/Settings, Windows:File/Perference/Settings】进行图形界面配置，并可输入配置项的名字进行搜索。

- 文件浏览器缩进宽度：默认缩进太小看不清，"tree.indent"，从 8 改为 16，[来源](https://github.com/microsoft/vscode/issues/35447#issuecomment-455461013)。
- 区别显示空格和 Tab 字符：设置 "editor.renderWhitespace"，改为 "all", [来源](https://stackoverflow.com/a/30140625/364334)
- 显示垂直标尺：设置 "editor.rulers": [80,100]，[来源](https://stackoverflow.com/a/29972073/364334)
- 文件浏览器中隐藏某些类型的文件：设置"files:exclude"，[来源](https://stackoverflow.com/a/30142299/364334)
- 中文字体和英文字体对不齐：下载安装`更纱黑体`或者`M+ FONTS`字体，并在"editor.fontFamily" 里设置（参见[来源](https://zhuanlan.zhihu.com/p/110945562)），不过这样会导致代码里的英文变得过于细小，因此可以[单独针对 markdown 设置](https://moe.best/gotagota/vscode-monospaced.html)

## 常用插件

- cpplint
- pylint
- protobuf
- markdownlint 自动提示 markdown 文件的错误，是编写 Markdown 的利器。

## 文档

- [官方文档](https://code.visualstudio.com/docs)
- [Microsoft Visual Studio Code 中文手册](https://jeasonstudio.gitbooks.io/vscode-cn-doc/content/)

