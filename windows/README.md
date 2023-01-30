# Windows

## DOSKEY

安装：

```console
reg add "HKCU\Software\Microsoft\Command Processor" /v Autorun /d "doskey /macrofile=\"C:\Users\chen3\doskey.macros\"" /f
```

查询：

```console
reg query "HKCU\Software\Microsoft\Command Processor" /v Autorun
```
