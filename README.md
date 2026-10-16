# 访达右键解压

给 Mac 的右键菜单加一个 **“解压到当前文件夹”**，RAR 等压缩包不用再敲命令。

**适用：M 系列芯片 Mac，已通过 Homebrew 安装 `unar`。**

还没安装 Homebrew？先打开 **[Homebrew 官网](https://brew.sh/zh-cn/)**，按照官网指引安装。然后在终端执行一次 `brew install unar`，再继续下面的步骤。已经装好 `unar` 的可以直接下载。

## 1. 下载

👉 **[点击下载](https://github.com/SHANPAO-orzw/unar-finder-action/raw/refs/heads/main/dist/unar-finder-action.zip)**

下载的是 `unar-finder-action.zip`。在“下载”文件夹里双击它，解开安装包。

## 2. 安装（只需一次）

双击解压出来的 **“安装.command”**。

它会打开一个终端窗口。看到 **“安装完成！”** 就可以关闭窗口了，不用输入任何命令。

安装器已经包含完整的快速操作，不需要再安装其他文件。如果之前安装过这个工具，会自动更新同名版本。

## 3. 解压文件

在访达里右键点击你的压缩包，依次选择：

**快速操作 → 解压到当前文件夹**

- 有密码：在弹窗中输入压缩包密码，点击“解压”。
- 没有密码：直接解压，不需要额外操作。
- 解压成功：文件保存在压缩包旁边的新文件夹里。

可以同时选中多个压缩包。输错密码可以重试，点“取消”会跳过；失败不会留下多余文件夹。再次解压同一个压缩包时，会给新文件夹加编号，保留已有文件。

## 遇到问题

**右键里没有这个选项？** 先重新打开访达窗口，再试一次；也可以看看右键菜单里的“服务”。

**提示没找到 unar？** 只需先在终端执行一次 `brew install unar`，完成后重新双击安装器。日常解压不再需要终端。

**系统不允许打开安装器？** 请将具体提示发到 [Issues](https://github.com/SHANPAO-orzw/unar-finder-action/issues)，方便排查。

**想卸载？** 在访达顶部点击“前往 → 前往文件夹”，粘贴 `~/Library/Services/`，把“解压到当前文件夹.workflow”移到废纸篓即可。

<details>
<summary>给想了解源码的人</summary>

- `src/extract.sh`：解压与密码弹窗逻辑。
- `install.command`：正式安装器。
- `dist/unar-finder-action.zip`：直接给使用者下载的安装包，内含“安装.command”和“使用说明.txt”。

解压先在临时目录完成，成功后才保存结果。安装时会备份已有的同名版本；不会清理其他名称的快速操作。更新前的同名版本保存在 `~/Library/Application Support/unar-finder-action/Backups/`。

密码不保存、不上传。调用 unar 时通过 `-p` 参数传入，运行期间可能出现在本机进程参数中。需要原位置的写入权限和足够磁盘空间。

</details>
