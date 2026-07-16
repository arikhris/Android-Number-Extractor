import tkinter as tk
from tkinter import ttk, messagebox, filedialog, simpledialog
import subprocess
import re
import csv
import os
import platform
import urllib.request
import zipfile
import stat
import threading

# --- TRANSLATION DICTIONARY ---
LANG = {
    "EN": {
        "title": "Aussie Mobile Extractor Pro",
        "tab_extract": "Extract From Phone",
        "tab_merge": "Merge & Clean Files",
        "format_lbl": "Number Format:",
        "format_local": "Local (04XX XXX XXX)",
        "format_intl": "International (+614XXXXXXXX)",
        "btn_instructions": "❓ How to connect my phone?",
        "btn_scan": "⚡ Scan & Extract Device",
        "preview_ext": "AU Mobiles Found (Duplicates Removed):",
        "btn_save": "💾 Save to CSV",
        "status_init": "Status: Initializing...",
        "status_ready": "System Engine Ready.",
        "status_dev_not_found": "🔴 Device Disconnected",
        "status_dev_found": "🟢 Device Connected & Ready",
        "merge_info": "Combine multiple contact lists / CSVs seamlessly",
        "btn_select_files": "📂 Select Files to Merge",
        "merge_src": "Selected Files:",
        "merge_out": "Deduplicated Master (AU Mobiles):",
        "instructions_title": "How to Enable USB Debugging",
        "instructions_text": (
            "1. Unlock your Android phone.\n"
            "2. Go to Settings > About Phone.\n"
            "3. Tap 'Build Number' 7 times rapidly to unlock Developer Mode.\n"
            "4. Go back to Settings > System > Developer Options.\n"
            "5. Scroll down and turn ON 'USB Debugging'.\n"
            "6. Plug your phone into the PC.\n"
            "7. Look at your phone and check 'Always allow from this computer' then press OK."
        ),
        "err_no_device": "No authorized Android device detected. Please check USB and accept prompts on your phone.",
        "success_export": "File saved cleanly with {count} AU mobile listings."
    },
    "ZH": {
        "title": "澳洲手机号提取专业版",
        "tab_extract": "从手机提取",
        "tab_merge": "合并与清理文件",
        "format_lbl": "号码格式:",
        "format_local": "本地 (04XX XXX XXX)",
        "format_intl": "国际 (+614XXXXXXXX)",
        "btn_instructions": "❓ 如何连接我的手机？",
        "btn_scan": "⚡ 扫描并提取",
        "preview_ext": "找到的澳洲手机号 (已自动去重):",
        "btn_save": "💾 保存为 CSV",
        "status_init": "状态: 正在初始化...",
        "status_ready": "系统引擎已就绪。",
        "status_dev_not_found": "🔴 设备未连接",
        "status_dev_found": "🟢 设备已连接",
        "merge_info": "无缝合并多个联系人列表或CSV文件",
        "btn_select_files": "📂 选择要合并的文件",
        "merge_src": "已选文件:",
        "merge_out": "去重后的主列表 (澳洲手机号):",
        "instructions_title": "如何开启 USB 调试",
        "instructions_text": (
            "1. 解锁您的安卓手机。\n"
            "2. 进入 设置 > 关于手机。\n"
            "3. 连续快速点击“版本号” 7 次，以解锁开发者模式。\n"
            "4. 返回 设置 > 系统 > 开发者选项。\n"
            "5. 向下滚动并开启“USB 调试”。\n"
            "6. 将手机通过USB连接到电脑。\n"
            "7. 查看手机屏幕，勾选“始终允许这台计算机进行调试”，然后点击确定。"
        ),
        "err_no_device": "未检测到已授权的安卓设备。请检查USB连接并在手机上确认授权。",
        "success_export": "文件已成功保存，包含 {count} 个澳洲手机号。"
    }
}

class StartupSelector(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Language / 语言")
        self.geometry("300x150")
        self.eval('tk::PlaceWindow . center')
        self.selected_lang = "EN"

        tk.Label(self, text="Select Language / 请选择语言:", font=("Segoe UI", 11)).pack(pady=20)
        
        btn_frame = tk.Frame(self)
        btn_frame.pack()
        
        tk.Button(btn_frame, text="English", width=10, height=2, command=lambda: self.select("EN")).pack(side=tk.LEFT, padx=10)
        tk.Button(btn_frame, text="中文", width=10, height=2, command=lambda: self.select("ZH")).pack(side=tk.LEFT, padx=10)

    def select(self, lang):
        self.selected_lang = lang
        self.destroy()

class ModernSMSApp:
    def __init__(self, root, lang_code):
        self.root = root
        self.lang = LANG[lang_code]
        
        self.root.title(self.lang["title"])
        self.root.geometry("700x600")
        self.root.configure(bg="#f5f6f8")
        self.root.eval('tk::PlaceWindow . center')

        self.adb_path = ""
        self.adb_ready = False
        self.extracted_numbers = set()
        self.merged_numbers = set()

        self.style = ttk.Style()
        self.style.theme_use("clam")
        self.style.configure(".", background="#f5f6f8", font=("Segoe UI", 10))
        self.style.configure("TNotebook.Tab", padding=[15, 5], font=("Segoe UI", 10, "bold"))
        self.style.map("TNotebook.Tab", background=[("selected", "#2b579a")], foreground=[("selected", "white")])
        self.style.configure("Action.TButton", background="#2b579a", foreground="white", font=("Segoe UI", 10, "bold"))
        self.style.configure("Secondary.TButton", background="#4caf50", foreground="white", font=("Segoe UI", 10, "bold"))
        self.style.configure("Dev.TButton", background="#ff9800", foreground="white", font=("Segoe UI", 10, "bold"))

        # Regex targeted specifically at finding chunks that look like AU numbers (+61, 04, etc)
        self.phone_regex = re.compile(r'(?:\+61|0)[\d\s\-\(\)]{8,16}')

        # Shared Format Variable
        self.format_var = tk.StringVar(value=self.lang["format_local"])

        self.notebook = ttk.Notebook(self.root)
        self.notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        self.setup_extract_tab()
        self.setup_merge_tab()

        # Bottom global status bar
        self.global_status_frame = ttk.Frame(self.root)
        self.global_status_frame.pack(fill=tk.X, side=tk.BOTTOM, padx=10, pady=5)
        
        self.lbl_device_status = ttk.Label(self.global_status_frame, text=self.lang["status_dev_not_found"], font=("Segoe UI", 10, "bold"), foreground="red")
        self.lbl_device_status.pack(side=tk.LEFT)
        
        self.lbl_status = ttk.Label(self.global_status_frame, text=self.lang["status_init"], foreground="gray")
        self.lbl_status.pack(side=tk.RIGHT)

        threading.Thread(target=self.setup_adb, daemon=True).start()

    # --- UI SETUP ---
    def setup_extract_tab(self):
        tab1 = ttk.Frame(self.notebook, padding=15)
        self.notebook.add(tab1, text=self.lang["tab_extract"])

        top_frame = ttk.Frame(tab1)
        top_frame.pack(fill=tk.X, pady=(0, 10))

        ttk.Button(top_frame, text=self.lang["btn_instructions"], command=self.show_instructions, style="Dev.TButton").pack(side=tk.LEFT)
        
        format_frame = ttk.Frame(top_frame)
        format_frame.pack(side=tk.RIGHT)
        ttk.Label(format_frame, text=self.lang["format_lbl"]).pack(side=tk.LEFT, padx=5)
        ttk.Combobox(format_frame, textvariable=self.format_var, values=[self.lang["format_local"], self.lang["format_intl"]], state="readonly", width=25).pack(side=tk.LEFT)

        mid_frame = ttk.Frame(tab1)
        mid_frame.pack(fill=tk.X, pady=10)
        self.btn_extract = ttk.Button(mid_frame, text=self.lang["btn_scan"], command=self.start_extraction, style="Action.TButton", state=tk.DISABLED)
        self.btn_extract.pack(fill=tk.X)

        preview_frame = ttk.Frame(tab1)
        preview_frame.pack(fill=tk.BOTH, expand=True)
        ttk.Label(preview_frame, text=self.lang["preview_ext"], font=("Segoe UI", 10, "bold")).pack(anchor=tk.W, pady=2)
        
        scroll_y = ttk.Scrollbar(preview_frame, orient=tk.VERTICAL)
        self.lst_extract_preview = tk.Listbox(preview_frame, yscrollcommand=scroll_y.set, font=("Consolas", 11), bd=1, relief="solid")
        scroll_y.config(command=self.lst_extract_preview.yview)
        scroll_y.pack(side=tk.RIGHT, fill=tk.Y)
        self.lst_extract_preview.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.btn_save_extract = ttk.Button(tab1, text=self.lang["btn_save"], command=lambda: self.save_to_csv(self.extracted_numbers), style="Secondary.TButton", state=tk.DISABLED)
        self.btn_save_extract.pack(fill=tk.X, pady=(10,0))

    def setup_merge_tab(self):
        tab2 = ttk.Frame(self.notebook, padding=15)
        self.notebook.add(tab2, text=self.lang["tab_merge"])

        top_frame = ttk.Frame(tab2)
        top_frame.pack(fill=tk.X, pady=(0, 10))
        ttk.Label(top_frame, text=self.lang["merge_info"], font=("Segoe UI", 10, "italic")).pack(side=tk.LEFT, pady=5)
        ttk.Button(top_frame, text=self.lang["btn_select_files"], command=self.merge_files_process, style="Action.TButton").pack(side=tk.RIGHT)

        split_frame = ttk.Frame(tab2)
        split_frame.pack(fill=tk.BOTH, expand=True)

        left_col = ttk.Frame(split_frame)
        left_col.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 5))
        ttk.Label(left_col, text=self.lang["merge_src"], font=("Segoe UI", 10, "bold")).pack(anchor=tk.W)
        self.lst_files = tk.Listbox(left_col, font=("Segoe UI", 9), height=6, bd=1, relief="solid", bg="#eaeaea")
        self.lst_files.pack(fill=tk.BOTH, expand=True)

        right_col = ttk.Frame(split_frame)
        right_col.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=(5, 0))
        ttk.Label(right_col, text=self.lang["merge_out"], font=("Segoe UI", 10, "bold")).pack(anchor=tk.W)
        
        scroll_y_merge = ttk.Scrollbar(right_col, orient=tk.VERTICAL)
        self.lst_merge_preview = tk.Listbox(right_col, yscrollcommand=scroll_y_merge.set, font=("Consolas", 11), bd=1, relief="solid")
        scroll_y_merge.config(command=self.lst_merge_preview.yview)
        scroll_y_merge.pack(side=tk.RIGHT, fill=tk.Y)
        self.lst_merge_preview.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.btn_save_merge = ttk.Button(tab2, text=self.lang["btn_save"], command=lambda: self.save_to_csv(self.merged_numbers), style="Secondary.TButton", state=tk.DISABLED)
        self.btn_save_merge.pack(fill=tk.X, pady=(10,0))

    def show_instructions(self):
        messagebox.showinfo(self.lang["instructions_title"], self.lang["instructions_text"])

    # --- CORE BACKGROUND FUNCTIONS ---
    def setup_adb(self):
        system = platform.system()
        base_dir = os.path.dirname(os.path.abspath(__file__))
        tools_dir = os.path.join(base_dir, "platform-tools")
        
        if system == "Windows":
            exe_name = "adb.exe"
            url = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
        elif system == "Darwin":
            exe_name = "adb"
            url = "https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"
        elif system == "Linux":
            exe_name = "adb"
            url = "https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
        else:
            self.update_status("Unsupported OS.", "red")
            return

        self.adb_path = os.path.join(tools_dir, exe_name)

        if not os.path.exists(self.adb_path):
            self.update_status("Downloading ADB...", "#2b579a")
            zip_path = os.path.join(base_dir, "platform-tools.zip")
            try:
                urllib.request.urlretrieve(url, zip_path)
                with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                    zip_ref.extractall(base_dir)
                os.remove(zip_path)
                if system in ["Darwin", "Linux"]:
                    os.chmod(self.adb_path, os.stat(self.adb_path).st_mode | stat.S_IEXEC)
            except Exception as e:
                self.update_status(f"Setup Error: {str(e)}", "red")
                return

        self.adb_ready = True
        self.update_status(self.lang["status_ready"], "#4caf50")
        self.root.after(0, lambda: self.btn_extract.config(state=tk.NORMAL))
        self.poll_device_status() # Start polling once ADB is ready

    def poll_device_status(self):
        """Continuously check if phone is plugged in and authorized."""
        if self.adb_ready:
            try:
                result = subprocess.run([self.adb_path, "devices"], capture_output=True, text=True)
                if "device\n" in result.stdout:
                    self.lbl_device_status.config(text=self.lang["status_dev_found"], foreground="green")
                else:
                    self.lbl_device_status.config(text=self.lang["status_dev_not_found"], foreground="red")
            except:
                pass
        
        self.root.after(2000, self.poll_device_status) # Check every 2 seconds

    def update_status(self, text, color):
        self.root.after(0, lambda: self.lbl_status.config(text=text, foreground=color))

    # --- EXTRACTION PROCESS ---
    def start_extraction(self):
        self.btn_extract.config(state=tk.DISABLED)
        self.lst_extract_preview.delete(0, tk.END)
        self.extracted_numbers.clear()
        threading.Thread(target=self.extract_process, daemon=True).start()

    def extract_process(self):
        try:
            result = subprocess.run([self.adb_path, "devices"], capture_output=True, text=True)
            if "device\n" not in result.stdout:
                self.root.after(0, lambda: messagebox.showerror("Error", self.lang["err_no_device"]))
                self.root.after(0, lambda: self.btn_extract.config(state=tk.NORMAL))
                return

            cmd = [self.adb_path, "shell", "content", "query", "--uri", "content://sms", "--projection", "address,body"]
            result = subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8', errors='ignore')
            
            raw_data = result.stdout
            if not raw_data or "Permission Denial" in raw_data:
                self.update_status("System restricted access.", "red")
                self.root.after(0, lambda: self.btn_extract.config(state=tk.NORMAL))
                return

            address_matches = re.findall(r'address=(.*?)(?:, body=)', raw_data)
            for addr in address_matches:
                au_format = self.format_au_mobile(addr)
                if au_format: self.extracted_numbers.add(au_format)

            body_matches = self.phone_regex.findall(raw_data)
            for num in body_matches:
                au_format = self.format_au_mobile(num)
                if au_format: self.extracted_numbers.add(au_format)

            self.root.after(0, self.populate_extract_preview)

        except Exception as e:
            self.update_status(f"Error: {str(e)}", "red")
            self.root.after(0, lambda: self.btn_extract.config(state=tk.NORMAL))

    def populate_extract_preview(self):
        for number in sorted(self.extracted_numbers):
            self.lst_extract_preview.insert(tk.END, f" 📱 {number}")
        
        self.btn_extract.config(state=tk.NORMAL)
        if self.extracted_numbers:
            self.btn_save_extract.config(state=tk.NORMAL)

    # --- FILE MERGING ---
    def merge_files_process(self):
        file_paths = filedialog.askopenfilenames(filetypes=[("Data Files", "*.csv *.txt"), ("All Files", "*.*")])
        if not file_paths:
            return

        self.lst_files.delete(0, tk.END)
        self.lst_merge_preview.delete(0, tk.END)
        self.merged_numbers.clear()
        
        for path in file_paths:
            self.lst_files.insert(tk.END, os.path.basename(path))

        threading.Thread(target=self.run_file_merge, args=(file_paths,), daemon=True).start()

    def run_file_merge(self, file_paths):
        try:
            for path in file_paths:
                with open(path, mode='r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    matches = self.phone_regex.findall(content)
                    for match in matches:
                        au_format = self.format_au_mobile(match)
                        if au_format:
                            self.merged_numbers.add(au_format)
            
            self.root.after(0, self.populate_merge_preview)
        except Exception as e:
            pass

    def populate_merge_preview(self):
        for number in sorted(self.merged_numbers):
            self.lst_merge_preview.insert(tk.END, f" 📱 {number}")
        if self.merged_numbers:
            self.btn_save_merge.config(state=tk.NORMAL)

    # --- AUSTRALIAN MOBILE ONLY FORMATTER ---
    def format_au_mobile(self, raw_num):
        """Strictly cleans, validates, and formats ONLY AU Mobile numbers."""
        clean = re.sub(r'[^\d+]', '', str(raw_num))
        
        # Normalize International +61 or 61 to Local 0
        if clean.startswith('+61'):
            clean = '0' + clean[3:]
        elif clean.startswith('61') and len(clean) == 11:
            clean = '0' + clean[2:]
            
        # Check if it is exactly 10 digits and starts with 04 (AU Mobile)
        if len(clean) == 10 and clean.startswith('04'):
            selected_format = self.format_var.get()
            
            if selected_format == self.lang["format_local"]:
                # Returns 04XX XXX XXX
                return f"{clean[:4]} {clean[4:7]} {clean[7:]}"
            else:
                # Returns +614XXXXXXXX
                return f"+61{clean[1:]}"
                
        # Reject landlines, 1300 numbers, and junk
        return None

    def save_to_csv(self, target_set):
        file_path = filedialog.asksaveasfilename(defaultextension=".csv", filetypes=[("CSV files", "*.csv")])
        if file_path:
            with open(file_path, mode='w', newline='', encoding='utf-8') as file:
                writer = csv.writer(file)
                writer.writerow(["Phone Number"])
                for number in sorted(target_set):
                    writer.writerow([number])
            
            msg = self.lang["success_export"].replace("{count}", str(len(target_set)))
            messagebox.showinfo("Success", msg)

if __name__ == "__main__":
    # 1. Run the language selector first
    selector = StartupSelector()
    selector.mainloop()

    # 2. If a language was selected (user didn't just close the window), start the main app
    if hasattr(selector, 'selected_lang'):
        root = tk.Tk()
        app = ModernSMSApp(root, selector.selected_lang)
        root.mainloop()
