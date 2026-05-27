# 排查 zsh 启动慢

## 第一步：测量启动时间

```zsh
time zsh -i -c exit
```

- `-i` 模拟交互式 shell，会加载 `.zshrc`
- 不加 `-l` 则不加载 `.zprofile` / `.zlogin`（通常不是瓶颈）

## 第二步：精确定位瓶颈

### 用 `zprof` 看 zsh 代码耗时

在 `~/.zshrc` **最开头**加两行：

```zsh
zmodload zsh/zprof
```

**最末尾**加一行：

```zsh
zprof
```

然后开新终端，会打印每个函数的调用次数和耗时，按 `self` 列降序看。

### `zprof` 的局限性

`zprof` 只统计 zsh 函数，**看不到外部进程的耗时**。典型的外部进程大户：

- `conda shell.zsh hook` —— 启动 Python 解释器
- `brew shellenv` —— 虽然快（~0.3s），但可能会被调多次
- `nvm.sh` —— 大型 bash 脚本

这些需要用 `time` 单独测量。

## 第三步：按耗时排序的常见元凶

### 1. `compinit` 重复调用（最常见）

```zsh
# 查看谁在调用 compinit
grep -rn 'compinit' ~/.zshrc ~/.zpreztorc ~/.zgen 2>/dev/null
```

- 如果看到**多个** `compinit` 调用 → 删除重复的，只留最后一个
- 每个 `compinit` 可能需要 3-6 秒

**确保只跑一次，且用缓存：**

```zsh
autoload -Uz compinit
compinit -d ~/.zcompdump   # -d 指定缓存文件，避免每次重新扫描
```

### 2. `conda shell.zsh hook`

`conda init` 生成的代码会运行 `conda shell.zsh hook`，启动 Python 解释器（可能 5-10 秒）。

**解决方案**：直接 source conda.sh，不走 Python：

```zsh
# 替代 conda init 生成的慢代码
if [ -f "/path/to/miniforge3/etc/profile.d/conda.sh" ]; then
    . "/path/to/miniforge3/etc/profile.d/conda.sh"
else
    export PATH="/path/to/miniforge3/bin:$PATH"
fi
```

### 3. `nvm` 加载

`nvm.sh` 是一个大型 bash 脚本，加载耗时 1-2 秒。

**解决方案**：延迟加载（lazy-load），在第一次使用 `node`/`npm`/`npx` 时才加载：

```zsh
export NVM_DIR="$HOME/.nvm"
nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm "$@"
}
node() { unset -f node npm npx nvm; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; node "$@"; }
npm()  { unset -f npm node npx nvm; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; npm "$@";  }
npx()  { unset -f npx node npm nvm; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; npx "$@";  }
```

### 4. `compinit` 在 `$fpath` 设置完之前就跑了

`zinit`、`oh-my-zsh`、Docker Desktop 等都会往 `$fpath` 加补全目录。如果 `compinit` 跑在这些之前，缓存的补全不完整 → 每次启动都会部分重建 → 慢。

**解决方案**：把所有 `fpath` 设置放在最前面，`compinit` 放在最后：

```zsh
# 1. 先设置所有 fpath
fpath=(/Users/xxx/.docker/completions $fpath)

# 2. 加载 zinit/oh-my-zsh 等（它们会继续往 fpath 加东西）
# ...

# 3. 最后才跑 compinit
autoload -Uz compinit
compinit -d ~/.zcompdump
```

### 5. `prompt` 里的 `git` 命令

每个提示符都跑 `git branch` 在大型仓库里会卡。

**用更快的命令**：

```zsh
# 慢：列出所有分支
git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'

# 快：只读 .git/HEAD
git symbolic-ref --short HEAD 2>/dev/null
```

`git symbolic-ref --short HEAD` 直接读 `.git/HEAD` 文件，不需要扫描分支列表。

## 第四步：用 `-x` 追踪执行流

如果以上方法都找不到瓶颈，用 `-x` 看每行执行：

```zsh
zsh -i -x -c exit 2>&1 | less
```

每行前面有 `+` 号。卡住不刷新的地方就是瓶颈。

## 快速检查清单

```zsh
# 1. 测总时间
time zsh -i -c exit

# 2. 看有没有重复 compinit
grep -c compinit ~/.zshrc

# 3. 看 conda 多久
time /path/to/conda shell.zsh hook >/dev/null

# 4. 看 nvm 多久
time bash ~/.nvm/nvm.sh

# 5. zprof 精确定位
# 在 .zshrc 头尾加 zprof 代码后重开终端
```
