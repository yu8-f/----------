# ファイル名を指定
input_file = "PLL論文\English.txt"
output_file = input_file

# ファイルを読み込んで改行をスペースに置換
with open(input_file, "r", encoding="utf-8") as f:
    text = f.read().replace("\n", " ")

# 結果を書き出す
with open(output_file, "w", encoding="utf-8") as f:
    f.write(text)

print("改行をスペースに置換して保存しました！")
