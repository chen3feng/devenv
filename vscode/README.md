# VS Code

我平时写代码主要在无 GUI 的 Linux 开发服务器上，通过 SSH 登录上去进行开发，过去基本是以 Vim 为主，
目前正在逐渐增 VS Code 的使用，VS Code 的远程开发和丰富的插件支持是主要吸引我的地方。
特别是编辑 Markdown 文件时的预览功能，非常方便，远程开发时，终端下的 vim 是难以做到的（也许远程起个 web 服务器可以？）。

## 设置

大部分设置可以通过进入设置选单【Mac:Code/Perference/Settings, Windows:File/Perference/Settings】进行图形界面配置，并可输入配置项的名字进行搜索。

- 文件浏览器缩进宽度：默认缩进太小看不清，"tree.indent"，从 8 改为 16，[来源](https://github.com/microsoft/vscode/issues/35447#issuecomment-455461013)。
- 区别显示空格和 Tab 字符：设置 "editor.renderWhitespace"，改为 "all", [来源](https://stackoverflow.com/a/30140625/364334)
- 保存时自动删除行尾多余的空格：设置 "files.trimTrailingWhitespace": true，[来源](https://stackoverflow.com/questions/30884131/remove-trailing-spaces-automatically-or-with-a-shortcut)
- 显示垂直标尺：设置 "editor.rulers": [80,100]，[来源](https://stackoverflow.com/a/29972073/364334)
- 文件浏览器中隐藏某些类型的文件：设置"files:exclude"，[来源](https://stackoverflow.com/a/30142299/364334)
- 中文字体和英文字体对不齐：下载安装`更纱黑体`或者`M+ FONTS`字体，并在"editor.fontFamily" 里设置（参见[来源](https://zhuanlan.zhihu.com/p/110945562)），不过这样会导致代码里的英文变得过于细小，因此可以[单独针对 markdown 设置](https://moe.best/gotagota/vscode-monospaced.html)，不过如果开启了配置同步，在没有安装该字体的系统里则会变成非等宽字体。
- 自动保存：设置 "files.autoSave"，可以考虑选择 onFocusChange，也可以通过【File/Auto Save】选单项，[来源](https://juejin.im/post/5cb87c6e6fb9a068a03af93a)
- 确保文件以换行结尾：设置 "files.insertFinalNewline"，[来源](https://stackoverflow.com/questions/44704968/visual-studio-code-insert-new-line-at-the-end-of-files)
- 避免误按 Cmd+Q 时直接退出：可以改为按两次 Cmd+Q，在【Code/Perference/Keyboard Shortcuts】进入图形界面配置，或者直接[修改 keybindings.json](https://github.com/microsoft/vscode/issues/14710#issuecomment-488114446)。
  或者安装 [Quit Control 扩展](https://marketplace.visualstudio.com/items?itemName=artdiniz.quitcontrol-vscode)。
- 修改 Python 折行宽度：根据选择的格式化工具做相应的设置，比如 autopep8 就修改 ”python.formatting.autopep8Args“，参见[来源](https://stackoverflow.com/questions/47406741/disable-auto-wrap-long-line-in-visual-studio-code)。

## 同步配置

点击左下角的小齿轮，在弹出的选单中选择“Settings Sync”，登录 github 账号或者 Microsoft 账户，按提示操作即可。

## 快捷键

符号说明：

- ⇧ Shift
- ⌘ Command
- ⌥ Option
- ⌃ Control

主要针对 Mac 系统，Windows 下通常要用 ⌃ 来代替 ⌘。

界面：

|功能             |按键    |说明   |
|----------------|-------|-------|
|设置            |⌘,
|Command Palette|⇧⌘P
|Explorer       |⇧⌘E
|Source Control |⇧⌘G
|Run and Debug  |⇧⌘D
|扩展中心         |⇧⌘X
|Markdown 预览   |<kbd>Ctrl</kbd>+<kbd>K</kbd> <kbd>P</kbd>
|Markdown分屏预览 |<kbd>Cmd</kbd>+<kbd>K</kbd> <kbd>V</kbd> | 

编辑：

|功能             |按键    |说明   |
|----------------|-------|-------|
|切换是否行注释     |⌘/
|切换是否行注释     |⇧⌥A


## 常用扩展

- C++ [配置](https://code.visualstudio.com/docs/languages/cpp)及[扩展](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
- Go [配置](https://code.visualstudio.com/docs/languages/go) 及[扩展](https://marketplace.visualstudio.com/items?itemName=golang.go)
- cpplint
- pylint
- protobuf
- [Trailing Spaces](https://marketplace.visualstudio.com/items?itemName=shardulm94.trailing-spaces) 高亮显示行尾空格
- [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint) 自动提示 markdown 文件的错误，是编写 Markdown 的利器。
- Markdown preview Enhanced 增强预览功能
- [Sort](https://marketplace.visualstudio.com/items?itemName=henriiik.vscode-sort) 排序，选中后按 <kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>S</kbd> 排序，再按一次逆序。
- [Zip Explorer](https://marketplace.visualstudio.com/items?itemName=slevesque.vscode-zipexplorer)，查看 Zip 文件的内容。

## 其他

从 `vim` 转来的开发者往往会不由自主地在 `vscode` 的终端里继续用 `vim`，为了加快适应使用 `vscode`，默认禁止这种用法。
当使用 `vim` 时，先提示是否用 `vscode` 打开，如果不是才继续用 `vim`。

可以通过环境变量 `ALLOW_VIM_IN_VSCODE` 来解除限制：

```shell
ALLOW_VIM_IN_VSCODE=1
```

或者直接用 `\vim` 的方式来调用：
```console
\vim myfile
```

## 文档

- [官方文档](https://code.visualstudio.com/docs)
- [Microsoft Visual Studio Code 中文手册](https://jeasonstudio.gitbooks.io/vscode-cn-doc/content/)

