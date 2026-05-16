# 训练产物与推理使用说明

copilot

目的
- 针对你在 AutoDL 上使用 `GPT-SoVITS` 完成的数据切片与训练产物（`.wav`, `.pth`, `.ckpt`），提供可执行的检验、打包、下传、在本地验证与推理的操作步骤和命名/备份规范。此文档以不重新训练为前提，复用已有权重并实现 TTS → 风格转换（SoVITS 推理）。

前提假设（请确认）
- 你已确认有权使用并发布该声音（已回答：是）。
- 训练产物位于 AutoDL 容器内（路径示例见 `output.txt`）：`logs/袁阔成三国演义/`、`SoVITS_weights_v2Pro/`、`GPT_weights_v2Pro/`。
- 你想在本地使用文本直接生成（TTS → 风格转换），并复用 AutoDL 上的权重，不重新开始训练。

快速目标回顾
- 挑选 1–2 个候选 SoVITS `*.pth` 与相应的 GPT `*.ckpt`（或 `GPT_weights_v2Pro` 下的文件）。
- 从 AutoDL 下载这些权重与若干参考 `wav`（切片样本）到本地进行听感验证。
- 在本地搭建推理环境（`venv`），用 WebUI 或脚本完成 TTS→SoVITS 转换并输出最终 `wav`。
- 记录并备份最终选定的 `best` 权重与元数据（`meta.json`）。

一、在 AutoDL 容器上确认与挑选 checkpoint

1) 列出关键目录与文件

```bash
# 显示切片输出与原始 raw 文件
ls -l output/slicer_opt | head
ls -l raw/myvoice | head

# 查看训练日志与目录
ls -l logs/袁阔成三国演义/
cat logs/袁阔成三国演义/train.log | sed -n '1,200p'
```

2) 查找候选权重

常见位置（你提供的示例）：

- `SoVITS_weights_v2Pro/袁阔成三国演义_e4_s232.pth`
- `SoVITS_weights_v2Pro/袁阔成三国演义_e8_s464.pth`
- `logs/袁阔成三国演义/logs_s2_v2Pro/G_*.pth`（GAN 生成器权重）

判断优先级：优先选择保存轮次较多且日志中没有训练异常的 checkpoint（e8 相对于 e4 通常更好，但仍需主观听感验证）。

二、打包要下载的文件（推荐在容器内执行，再传输单个压缩包）

在 AutoDL 容器内执行：

```bash
# 在容器内创建打包目录并打包：
mkdir -p /root/autodl-tmp/artifacts_for_download
cp SoVITS_weights_v2Pro/袁阔成三国演义_e8_s464.pth /root/autodl-tmp/artifacts_for_download/
cp SoVITS_weights_v2Pro/袁阔成三国演义_e4_s232.pth /root/autodl-tmp/artifacts_for_download/
cp GPT_weights_v2Pro/*.ckpt /root/autodl-tmp/artifacts_for_download/ 2>/dev/null || true
# 拷贝若干参考 wav（示例：前 10 个切片）
mkdir -p /root/autodl-tmp/artifacts_for_download/reference_wavs
ls output/slicer_opt | head -n 10 | xargs -I {} cp output/slicer_opt/{} /root/autodl-tmp/artifacts_for_download/reference_wavs/

cd /root/autodl-tmp
tar -czf yuan_artifacts_$(date +%Y%m%d-%H%M).tar.gz artifacts_for_download
```

三、从 AutoDL 下载到本地（示例：使用 `scp`）

```bash
# 在本地运行：
scp -P <port> root@<autodl-host>:/root/autodl-tmp/yuan_artifacts_20260515-0700.tar.gz ./artifacts/
tar -xzf ./artifacts/yuan_artifacts_20260515-0700.tar.gz -C ./artifacts/
```

如果无法直接 `scp`，可考虑先上传到临时云盘（Google Drive / OSS / S3），然后从本地下载。

四、本地环境准备（快速一键）

```bash
# 在项目根目录（本仓库）
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt || true
# 安装常见推理依赖（如果 requirements 没有或缺失）
pip install torch torchaudio librosa numpy soundfile
```

五、推理方法（两种可选路径）

路径 A — 使用 repo 自带的 WebUI（最简单；已在 README 提到 `python webui.py`）

步骤：
- 把 `*.pth`/`*.ckpt` 放到 WebUI 能识别的目录（参照 WebUI 的 `SoVITS_weights` 与 `GPT_weights` 选择框）。
- 启动 `python webui.py`，进入 `TTS Inference`页面：选择 `SoVITS_weights` 与 `GPT_weights`，填入目标文本或参考音频，点击 `Start inference`。

注意：WebUI 运行时会期望权重与模型版本（v2Pro/v3）匹配，若 WebUI 报错，请检查权重所在子目录名是否与下拉项一致。

路径 B — 命令行脚本推理（建议用于批量化）

说明：不同 fork 的 `GPT-SoVITS` 实现的推理脚本名与参数不同，下面是通用流程与伪命令（你可能需要根据仓库脚本做少量调整）：

1) 准备干声（dry.wav）——你可以用任意 TTS（本地或云）把文本转成中性干声；或使用 `reference_wavs` 做小样本测试。

2) 运行 SoVITS 推理：

```bash
# 伪命令：替换为仓库实际脚本或模型加载方式
python inference_cli.py \
  --sovits_weight artifacts_for_download/袁阔成三国演义_e8_s464.pth \
  --gpt_weight artifacts_for_download/gpt_best.ckpt \
  --input dry.wav \
  --output out_yuan.wav \
  --pitch_shift 0 \
  --speed 1.0
```

如果没有 `inference_cli.py`，可以在仓库中搜索 `inference`、`tts`、`sovits` 等关键字，或直接用 WebUI 执行一次并在 WebUI 上看命令行调用记录。

六、采样率 & 重采样注意

- 训练时模型常用采样率会影响推理输入。检查 `logs/袁阔成三国演义/5-wav32k/` 等目录来确认训练的采样率（32k/40k/44.1k）。
- 若本地 TTS 输出与模型训练采样率不一致，务必先用 `sox` 或 `ffmpeg` 统一重采样：

```bash
ffmpeg -y -i dry_original.wav -ar 40000 -ac 1 dry_40k_mono.wav
```

七、元数据与命名规范（强烈建议）

1) 命名示例：

- `yuan_v1_sovits_e8_s464.pth`
- `yuan_v1_gpt_e15.ckpt`
- `yuan_best_20260515_meta.json`

2) `meta.json` 模板示例：

```json
{
  "model_name": "yuan_v1",
  "sovits_weight": "yuan_v1_sovits_e8_s464.pth",
  "gpt_weight": "yuan_v1_gpt_e15.ckpt",
  "train_epoch": 8,
  "train_date": "2026-05-15",
  "sampling_rate": 40000,
  "notes": "Selected based on subjective A/B listening, best tradeoff between naturalness and stability.",
  "sha256": "<sha256sum here>"
}
```

八、备份策略

- 将最终的 `best` 权重和 `meta.json` 上传到至少两个位置：公司/个人云盘（Google Drive / OneDrive）与对象存储（S3/OSS）。
- 保留压缩包（tar.gz）和 SHA256 校验值，以便将来完整性校验。示例：

```bash
sha256sum yuan_artifacts.tar.gz > yuan_artifacts.tar.gz.sha256
```

九、听感评估建议

- 准备 10–20 条代表性文案（短句、中长段、表情变化），生成对照（A: baseline / B: yuan 模型），使用 CSV 模板记录每条的评分（自然度、相似度、清晰度、语速适配）。
- 收集 3–5 位听众的主观评分并计算均值，以确定最终 `best` 模型。

十、常见问题排查（简短）

- 推理出现噪音或断裂：检查 `pitch_shift`、输入是否为单声道、采样率是否匹配。尝试把 `pitch_shift` 缩小或启用 `rs`（retrieval smoothing）参数。 
- WebUI 找不到权重：确认权重文件名不包含空格或特殊字符，并把它们放到 WebUI 指定目录。重启 WebUI 后点击 `refreshing model paths`。

十一、下一步建议（我可以帮你做）

- 我可以把这份说明整理成仓库内的正式文档（已完成）。
- 如果你愿意，我可以生成一个容器端的 `pack_and_download.sh` 打包脚本或在本地生成 `inference_sample.py`（需要你选择 A/B/C —— 你刚选 C，我将不自动创建脚本，除非你允许）。

附录：常用命令快速索引

```bash
# 查看训练日志
cat logs/袁阔成三国演义/train.log | tail -n 200

# 打包要下载的文件
tar -czf yuan_artifacts.tar.gz artifacts_for_download/

# 下载到本地（示例）
scp -P <port> root@<autodl-host>:/root/autodl-tmp/yuan_artifacts.tar.gz ./

# 本地重采样
ffmpeg -y -i input.wav -ar 40000 -ac 1 output_40k_mono.wav

# 计算 sha256
sha256sum yuan_artifacts.tar.gz > yuan_artifacts.sha256
```

---

如果需要，我可以根据你选定的 `e4` / `e8` checkpoint 生成一个对比听感清单（把一组文本跑两次并生成对比音频），或者直接生成容器端打包脚本以便你一键下载。请告诉我你下一步想要我做什么。 
