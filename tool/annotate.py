import os
import json
import tkinter as tk
from tkinter import filedialog, messagebox, simpledialog
from PIL import Image, ImageTk

# ====================== 配置 ======================
IMAGE_EXTS = [".jpg", ".jpeg", ".png", ".bmp"]
SAVE_DIR = os.path.dirname(os.path.abspath(__file__))  # 同级目录保存

class ImageAnnotator:
    def __init__(self, root):
        self.root = root
        self.root.title("简易图像标注工具 - 矩形框标注")
        self.root.geometry("1200x700")

        # 数据
        self.image_paths = []
        self.current_idx = -1
        self.current_image = None
        self.current_tk_image = None
        self.rect_start = None
        self.rect_id = None
        self.annotations = {}

        # UI
        self.canvas = tk.Canvas(root, bg="gray")
        self.canvas.pack(fill=tk.BOTH, expand=True)

        # 按钮
        frame = tk.Frame(root)
        frame.pack(fill=tk.X)
        tk.Button(frame, text="选择图片文件夹", command=self.load_folder).pack(side=tk.LEFT, padx=5, pady=5)
        tk.Button(frame, text="上一张", command=self.prev_image).pack(side=tk.LEFT, padx=5)
        tk.Button(frame, text="下一张(保存)", command=self.next_image).pack(side=tk.LEFT, padx=5)
        tk.Button(frame, text="清除当前标注", command=self.clear_annotation).pack(side=tk.LEFT, padx=5)

        # 鼠标绑定
        self.canvas.bind("<ButtonPress-1>", self.on_press)
        self.canvas.bind("<B1-Motion>", self.on_drag)
        self.canvas.bind("<ButtonRelease-1>", self.on_release)

    def load_folder(self):
        folder = filedialog.askdirectory()
        if not folder:
            return

        paths = []
        for f in os.listdir(folder):
            ext = os.path.splitext(f)[1].lower()
            if ext in IMAGE_EXTS:
                paths.append(os.path.join(folder, f))

        if not paths:
            messagebox.showwarning("提示", "文件夹中没有找到图片")
            return

        self.image_paths = sorted(paths)
        self.current_idx = 0
        self.show_image()

    def show_image(self):
        if self.current_idx < 0 or self.current_idx >= len(self.image_paths):
            return

        path = self.image_paths[self.current_idx]
        self.annotations = {}  # 重置标注
        self.canvas.delete("all")

        # 打开图片并自适应显示
        img = Image.open(path)
        canvas_w = self.canvas.winfo_width()
        canvas_h = self.canvas.winfo_height()
        img.thumbnail((canvas_w, canvas_h))
        self.current_image = img
        self.current_tk_image = ImageTk.PhotoImage(img)
        self.canvas.create_image(0, 0, anchor=tk.NW, image=self.current_tk_image)
        self.root.title(f"标注工具 - {os.path.basename(path)}")

    def on_press(self, event):
        self.rect_start = (event.x, event.y)

    def on_drag(self, event):
        if self.rect_start:
            if self.rect_id:
                self.canvas.delete(self.rect_id)
            x1, y1 = self.rect_start
            x2, y2 = event.x, event.y
            self.rect_id = self.canvas.create_rectangle(x1, y1, x2, y2, outline="red", width=2)

    def on_release(self, event):
        if not self.rect_start:
            return

        x1, y1 = self.rect_start
        x2, y2 = event.x, event.y
        box = (min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2))

        # 输入标签
        label = simpledialog.askstring("标注", "输入物品名称：")
        if not label:
            self.canvas.delete(self.rect_id)
            self.rect_id = None
            self.rect_start = None
            return

        # 保存标注
        self.annotations[label] = box
        self.rect_start = None
        self.rect_id = None

    def clear_annotation(self):
        self.annotations = {}
        self.canvas.delete("all")
        self.show_image()
        messagebox.showinfo("提示", "已清除当前标注")

    def save_annotation(self):
        if self.current_idx < 0 or not self.image_paths:
            return

        img_path = self.image_paths[self.current_idx]
        img_name = os.path.basename(img_path)
        json_name = os.path.splitext(img_name)[0] + ".json"
        json_path = os.path.join(SAVE_DIR, json_name)

        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(self.annotations, f, ensure_ascii=False, indent=2)

    def next_image(self):
        if not self.image_paths:
            return
        self.save_annotation()
        if self.current_idx < len(self.image_paths) - 1:
            self.current_idx += 1
            self.show_image()
        else:
            messagebox.showinfo("完成", "已经是最后一张")

    def prev_image(self):
        if not self.image_paths:
            return
        if self.current_idx > 0:
            self.current_idx -= 1
            self.show_image()

if __name__ == "__main__":
    root = tk.Tk()
    app = ImageAnnotator(root)
    root.mainloop()