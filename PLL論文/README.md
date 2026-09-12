# PLL論文

卒論の前段階として読んだPLL関連の論文と、その読書メモ置き場。

## 構成
- `参考論文/` — 外部の参考論文PDF
  - `A_Harmonic-Mixer-Based_Fractional-N_PLL_Employing_Voltage-Domain_Feed-Forward_Noise_Cancellation.pdf`
  - `A_Harmonic-Mixing_PLL_Architecture_for_Millimeter-Wave_Application.pdf`
  - `Optimization_of_DTC-Based_and_Harmonic-Mixer-Based_Fractional-N_PLLs_Comparative_Analysis_of_Jitter_and_Power_Trade-Offs.pdf`
  - `長田将_本文.pdf` — 長田さんの論文本文
  - `編集後.pdf` — `長田将_本文.pdf`を読みやすく編集した版
- `読書ノート/` — PLL関連論文を読んで作った日本語ノート集(HTML+CSS、数式は
  KaTeX)。Netlify(`osada-hakuron.netlify.app`、2026-09-07デプロイ)にまとめて上げてあり、
  複数論文のノートを1サイトに集約する方針。`index.html` が全体の目次ページで、論文ごとに
  セクション分けして相対リンクで各ノートへ飛べるようにしてある。ブラウザで `index.html` を
  開くのが入口。
  - `index.html` — 全体の目次ページ(論文ごとにセクション分け)
  - **① 長田将 博士論文（HMベース Fractional-N PLL）**
    - `basics.html` — 基礎知識まとめ(前提知識の入門。比喩多め・数式最小・確認問題つき)
    - `thesis-notes.html` — 長田博論 詳細まとめ(全7章。式・図47点・質疑応答・確認問題・
      卒論との対応表)
    - `ch2-3-notes.html` — 第2・3章のカジュアルなまとめ＋Q&A(最初に作った版。内容は
      `thesis-notes.html` に取り込み済みだが口調が砕けていて読みやすいので残置)
    - 図は `figures/` 直下に `fig_<章>_<番号>.png`(全120点、`参考論文/長田将_本文.pdf` から切り出し)
  - **② 関連論文**
    - `dtc-hm-optimization-notes.html` — Zhu, Osada, Zhang, Iizuka, "Optimization of
      DTC-Based and Harmonic-Mixer-Based Fractional-N PLLs" (IEEE TCAS-I, 2025) のまとめ。
      同じ飯塚研の直近論文で、長田博論のDual-Feedback構成が比較対象の一つとして登場する。
      図は `figures/optimization-paper/`。
    - `hm-ffnc-notes.html` — Zhang, Osada, Zhu, Iizuka, "A Harmonic-Mixer-Based
      Fractional-N PLL Employing Voltage-Domain Feed-Forward Noise Cancellation"
      (IEEE JSSC, 2025) のまとめ。Dual-Feedback構成の補助VCOノイズ・電力オーバーヘッドを
      フィードフォワード雑音キャンセルで軽減する実チップ論文。図は `figures/ffnc-paper/`。
  - ※旧 `.md`/`.pdf` の章ノートは内容を HTML に統合したため削除済み(git 履歴に残る)
  - 新しい論文のノートを追加するときは、`figures/<論文名>/` のように図をサブフォルダに
    分けたうえで、`index.html` に論文ごとのセクション(カード)を足す。既存ノートのファイル名・
    中身は変更しなくてよい。
- `tools/` — 論文処理用の補助スクリプト
  - `改行をスペースに.py`

## 運用メモ
- 新しく読んだ論文のPDFは`参考論文/`に、読書ノートは`読書ノート/`に置く。
- 読書ノートは HTML で書き、`index.html` からリンクする。CSS は各 HTML に
  `<style>` で直接埋め込む(外部参照は file:// で解決に失敗することがあるため)。
- 本文の図が必要なときは `参考論文/長田将_本文.pdf` から切り出して
  `読書ノート/figures/fig_<章>_<番号>.png` に置き、相対パスで参照する。
