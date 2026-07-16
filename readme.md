
## 🇨🇳 中文使用指南

本指南涵盖了从安装必要软件到导出最终去重联系人列表的所有步骤。

### 第一部分：下载与安装（仅需执行一次）

要运行此程序，您的电脑需要安装 Python。如果您已经安装了 Python，可以直接跳过第 1 步。

1. **安装 Python:** 前往官方网站 [python.org/downloads](https://www.python.org/downloads/)，下载适用于 Windows 或 Mac 的最新安装包。
* *⚠️ Windows 用户注意:* 打开下载的安装程序，**在点击“Install Now”之前**，请务必勾选窗口最底部的 **"Add Python to PATH"**。如果漏掉此步，程序将无法启动。


2. **下载程序代码:** 前往本项目代码库 [github.com/arikhris/Android-Number-Extractor](https://github.com/arikhris/Android-Number-Extractor)。
3. 点击绿色的 **Code** 按钮，然后选择 **Download ZIP**。
4. 将下载的 ZIP 文件解压到您的电脑上（例如解压到桌面）。
5. **启动程序:** 打开电脑的 **命令提示符 (CMD)** (Windows) 或 **终端 (Terminal)** (Mac)。使用 `cd` 命令进入解压后的文件夹，然后运行代码：
```bash
cd Desktop/Android-Number-Extractor-main
python sms_extractor_pro.py

```



### 第二部分：准备您的手机

您的安卓手机必须开启“开发者模式”和“USB 调试”，以便电脑可以安全地读取短信数据库。

1. 解锁您的手机，进入 **设置 > 关于手机**。
2. 连续快速点击 **版本号** 7 次，以解锁开发者模式。
3. 返回 **设置 > 系统 > 开发者选项**。
4. 找到并开启 **USB 调试**。

### 第三部分：使用应用程序

**从手机提取号码：**

1. 打开应用程序并选择您的语言（中文）。
2. 使用 USB 数据线将手机连接到电脑。
3. **注意看您的手机屏幕：** 手机上会出现一个安全提示，询问是否允许 USB 调试。勾选“始终允许这台计算机进行调试”，然后点击 **确定**。
4. 在电脑软件中，底部的状态栏会变绿并显示 **"🟢 设备已连接"**。
5. 选择您需要的号码格式（本地 04XX 或 国际 +614），然后点击 **"⚡ 扫描并提取"**。
6. 在屏幕上预览提取到的号码列表，确认无误后点击 **"💾 保存为 CSV"** 导出文件。

**合并现有文件（选项卡 2）：**
如果您有旧的联系人导出记录、文本文件或 CSV 文件，可以在这里将它们合并。

1. 点击顶部的 **合并与清理文件** 选项卡。
2. 点击 **"📂 选择要合并的文件"**，选中您想要合并的所有文本或 CSV 文件。
3. 软件会自动扫描所有选中的文件，提取其中的澳洲手机号码，并自动删除所有重复项。
4. 点击 **"💾 导出清理后的主列表"**，保存您最终的干净数据库。

## English User Guide

This guide covers everything from installing the required software to exporting your final deduplicated contact lists.

### Part 1: Installation & Setup (Do this once)

To run the application, your computer needs Python installed. If you already have Python, you can skip step 1.

1. **Install Python:** Go to the official website at [python.org/downloads](https://www.python.org/downloads/) and download the latest installer for Windows or Mac.
* *⚠️ Windows Users:* Before clicking "Install Now", make sure you check the box at the bottom that says **"Add Python to PATH"**. If you skip this, the app will not launch.


2. **Download the App:** Go to this project's repository at [github.com/arikhris/Android-Number-Extractor](https://github.com/arikhris/Android-Number-Extractor).
3. Click the green **Code** button and select **Download ZIP**.
4. Extract the ZIP file to a folder on your computer (e.g., your Desktop).
5. **Launch the App:** Open **Command Prompt** (Windows) or **Terminal** (Mac). Use the `cd` command to navigate to the extracted folder, then run the script:
```bash
cd Desktop/Android-Number-Extractor-main
python sms_extractor_pro.py

```



### Part 2: Preparing Your Phone

Your Android phone must have Developer Mode and USB Debugging enabled so the PC can securely read the SMS database.

1. Unlock your phone and go to **Settings > About Phone**.
2. Tap **Build Number** 7 times rapidly to unlock Developer Mode.
3. Go back to **Settings > System > Developer Options**.
4. Turn on **USB Debugging**.

### Part 3: Using the App

**Extracting Numbers from Phone:**

1. Open the app and select your language.
2. Plug your phone into your computer via USB.
3. **Look at your phone screen:** A security prompt will appear asking to authorize the computer. Check "Always allow from this computer" and tap **OK**.
4. In the app, the status bar at the bottom will turn green and say **"🟢 Device Connected & Ready"**.
5. Choose your preferred number format (Local 04XX or International +614) and click **"⚡ Scan & Extract Device"**.
6. Review the list of found numbers, then click **"💾 Save to CSV"** to export them.

**Merging Existing Files (Tab 2):**
If you have old contact exports, text files, or CSVs, you can combine them here.

1. Click the **Merge & Clean Files** tab.
2. Click **"📂 Select Files to Merge"** and highlight all the text or CSV files you want to combine.
3. The app will automatically scan all documents, extract Australian mobile numbers, and remove all duplicates.
4. Click **"💾 Export Master Cleaned CSV"** to save your finalized, clean database.

---
