"""
PDFの図をページ画像として切り出すテンプレートスクリプト。

使い方:
1. pdf, out_dir を書き換える
2. まず crops を空にして render_all_pages() だけ動かし、全ページを画像化して眺め、
   欲しい図がどのページのどのあたりにあるか目星をつける
3. crops に (ページ番号(0始まり), x0, y0, x1, y1) をポイント単位(pdfの座標系、レターサイズなら612x792)で書く
4. 実行して切り出し結果を Read で確認 → はみ出/欠けがあれば座標を微調整して再実行、を繰り返す

pip install pymupdf が必要(fitzという名前でimportする)。poppler(pdftoppm)が無い環境でも動く。
"""
import fitz
import os

pdf = r"PDFへの絶対パスをここに書く.pdf"
out_dir = r"C:\Users\fukuy\AppData\Local\Temp\claude\...\scratchpad\figs"  # scratchpad推奨

doc = fitz.open(pdf)


def render_all_pages(zoom=2.5):
    """全ページを1枚ずつ画像化する。まずこれで見取り図を作る。"""
    os.makedirs(f"{out_dir}\\pages", exist_ok=True)
    mat = fitz.Matrix(zoom, zoom)
    for i, page in enumerate(doc):
        pix = page.get_pixmap(matrix=mat)
        pix.save(f"{out_dir}\\pages\\page_{i+1:02d}.png")
    print(f"pages: {doc.page_count}, saved to {out_dir}\\pages")


# crops: {保存名: (0始まりページ番号, x0, y0, x1, y1)}  座標は元PDFのポイント単位
crops = {
    # "fig1": (1, 40, 55, 305, 500),
}


def crop_figs(zoom=4):
    os.makedirs(out_dir, exist_ok=True)
    mat = fitz.Matrix(zoom, zoom)
    for name, (pidx, x0, y0, x1, y1) in crops.items():
        page = doc[pidx]
        clip = fitz.Rect(x0, y0, x1, y1)
        pix = page.get_pixmap(matrix=mat, clip=clip)
        pix.save(f"{out_dir}\\{name}.png")
    print("done")


if __name__ == "__main__":
    if not crops:
        render_all_pages()
    else:
        crop_figs()
