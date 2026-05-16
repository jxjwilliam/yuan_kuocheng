# 容器端打包与一键下载说明

这个目录包含用于在 AutoDL 容器中打包训练产物与样例音频的脚本 `pack_and_download.sh`，以及本地一键下载的建议方法。

1) 在 AutoDL 容器中打包（在容器 shell 里执行）

```bash
# 切到仓库根目录
cd ~/autodl-tmp/GPT-SoVITS
chmod +x scripts/pack_and_download.sh
./scripts/pack_and_download.sh -o /root/autodl-tmp/yuan_artifacts.tar.gz

# 默认会把常见的 SoVITS/GPT 权重、logs、config、前10个切片 wav 以及 raw/myvoice 的 mp3 一并打包。
```

2) 单行从远程下载到本地（使用 scp）

在你的本地机器（例如 macOS），运行：

```bash
mkdir -p ~/downloads/yuan_artifacts
scp -P <port> root@<autodl-host>:/root/autodl-tmp/yuan_artifacts.tar.gz ~/downloads/yuan_artifacts/
scp -P <port> root@<autodl-host>:/root/autodl-tmp/yuan_artifacts.tar.gz.sha256 ~/downloads/yuan_artifacts/
cd ~/downloads/yuan_artifacts
tar -xzf yuan_artifacts.tar.gz
sha256sum -c yuan_artifacts.tar.gz.sha256  # 验证完整性（如果 sha 文件包含路径差异，可手动比对）
```

注意事项：
- 把 `<port>`、`<autodl-host>` 替换为你的 AutoDL 容器可访问的 SSH 端口与主机名/IP。
- 若你没有直接 SSH 权限，可在容器中把打包好的 tar 上传到你可访问的云盘（Google Drive / S3 / OSS），然后在本地下载。

3) 可选：本地辅助下载脚本

下面是本地一行下载的便捷脚本（示例），保存为 `scripts/download_from_autodl.sh` 并在本地运行：

```bash
#!/usr/bin/env bash
HOST="$1"  # e.g. autodl.example.com
PORT="$2"  # e.g. 46840
REMOTE_PATH="/root/autodl-tmp/yuan_artifacts.tar.gz"
DEST_DIR="${3:-./downloads}"
mkdir -p "$DEST_DIR"
scp -P "$PORT" root@"$HOST":"$REMOTE_PATH" "$DEST_DIR/"
```

运行示例：

```bash
chmod +x scripts/download_from_autodl.sh
./scripts/download_from_autodl.sh autodl-host.example.com 46840 ~/downloads/yuan_artifacts
```

如果你希望我也生成并提交 `download_from_autodl.sh` 到仓库，请回复确认，我会添加。 
