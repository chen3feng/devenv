# 我的基于 docker 的开发环境

在 Windows 和 Mac 上进行 Linux 开发，过去一般通过 SSH 到开发机，或者本地启动虚拟机。现在用 Docker 更容易维护开发环境的统一，推荐使用。 
本文完全针对 docker 小白，由于本人 docker 也用的不太多，因此如果有错误欢迎指教。

## 安装 docker

Linux 一般自带，如果没有，可以通过包管理安装。
Mac 和 Windows 10 下可以安装 [Docker Desktop](https://www.docker.com/products/docker-desktop)。
Windows 10 之前的版本，比如 Windows 7，则只能安装 [Docker ToolBox](https://docs.docker.com/toolbox/toolbox_install_windows/)。

需要注意的是 Mac 和 Windows 下是通过虚拟化方式运行的，性能明显低于 Linux，特别是访问卷方式加载文件系统时。

安装后还需要登录等，在此不表。

## 构建

在本目录下执行 `./build.sh`

## 使用

### 启动

在任意目录下执行 start.sh
我的共享卷目录放在 /Volumes/code 下，因此 hardcode 了其路径。
如果不同，需要修改路径。

启动后，代码下载到 /code 下，即可在容器内可见。
需要注意在 docker 容器内的任何修改，在退出后都会丢失。因此永久性修改都要放在挂接的 /code/ 下。

### 登录另一个终端

很多时候一个终端可能不够用，我们希望再登录更多的终端，比如 top 查看编译进程运行情况等。

首先列出当前有哪些活动的容器：

```bash
$ docker ps
CONTAINER ID  IMAGE          COMMAND      CREATED       STATUS       PORTS   NAMES
09b93464c2f7  ubuntu-devbox  "/bin/bash"  12 hours ago  Up 12 hours          laughing_northcutt
```
然后输入以下命令，就能再起一个 shell:

```bash
$ docker exec -it 09b93464c2f7 /bin/bash
```

### 退出

```bash
# exit
```

## 增加软件

由于容器退出后内容会丢失，因此需要安装的软件，需要修改 dockerfile，重新 build。安装新的包等时，建议不要动原来的 CMD，而是增加新的 CMD。
这看起来和 docker 的最佳实践违背，不过由于我们不是生成环境，这样做有利于利用以前缓存的镜像层，大大加快构建速度。

## Mac 下需要注意

Mac 文件系统默认是不区分大小写的，如果主要在 Linux 下开发，建议[创建大小写敏感的文件系统卷](https://www.google.com/search?q=mac+%E5%A4%A7%E5%B0%8F%E5%86%99%E6%95%8F%E6%84%9F+%E5%8D%B7)（不需要分区），
挂接到 mac 下，我是挂接到 /Volumns/code/ 目录下。
