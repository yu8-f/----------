
# 飯塚研で使ったファイルのまとめ

## 🌟 概要
飯塚研究室で使ったファイルをここに置いています。

## 📁 ディレクトリ構成
- `AnalogTraining/` `DigitalTraining/`：トレーニング用ファイル
- `FPGA/`：デジタルトレーニングで書いたFPGA用コード(`DigitalTraining/FPGA/`と同一内容の複製)
- `PLL論文/`：卒論の前段階として読んだPLL関連論文と読書メモ(`参考論文/` `読書ノート/` `tools/`、詳細は`PLL論文/README.md`)
- `matlab/`：PLLノイズ解析・NSGA-IIによる多目的最適化のMATLAB/Simulinkスクリプト

## 🛠 使用ツール
- シミュレータ：Icarus Verilog / ModelSim
- 波形ビューア：GTKWave
- エディタ：VSCode + 拡張機能

## 💡 メモ・備忘録
- ビルド手順：
  ```bash
  iverilog -o build/top.out src/top.v
  vvp build/top.out
  ```

- 波形ファイル（`.vcd`）をGTKWaveで開くとき：

  ```bash
  gtkwave dump.vcd
  ```

- .mdをPDFで保存するとき

  1. 対象の.mdファイルを開き、右上のプレビューマークをクリック
  2. 右側に表示されたプレビュー内で右クリック
  3. Export/Chrome (Puppeteer)/PDFをクリックで保存完了

- ライブラリの追加
  1. ```~/osada/tsmc65lp```に移動して```vim cds.lib```を打つと、長田さんが引用してるライブラリがどの場所にあるか見られる。
  2. ```Ctrl+F```は使えないので、コマンドラインに```/hogehoge```を打って```Enter```で検索できる。```N```キーで次候補。
  3. ライブラリの追加はLibrary Manager -> Edit -> Library Pathに追加。スクロールして最下段をクリックで追加できる。左側はライブラリ名(多分任意)、右側にpathを入れる。

- 長田さんの回路図の見方
  1. Library Managerから MO_DUAL_LOOP_PLL -> [\*TOP\*]で検索🔍 -> TO1909_TOP_OSADAのschematic

- 中身を見たいとき
  1. 中身見たいやつをダブルクリック
  2. 開いたDescendウィンドウで
    - View:schematic
    - Open for: auto
    - new tab
    でOK

## 📌 TODO

* [ ] モジュールの階層化
* [ ] テストベンチの整理

## 💬 備考

このリポジトリは個人学習用です。外部提供や公開の予定はありません。

---