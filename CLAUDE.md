# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is a personal study/research repository for 飯塚研究室 (Iiduka Lab), not a
conventional software project — there is no single build system, package
manager, or test suite. It holds independent groups of files documenting
coursework and PLL (Phase-Locked Loop) circuit research:

- `AnalogTraining/` — analog IC design training materials (PDFs).
- `DigitalTraining/` — digital design training: Verilog/SystemVerilog exercises,
  Quartus project files, and logic-synthesis result spreadsheets
  (`論理合成編/RESULT/*.xlsx`).
- `FPGA/` — the FPGA-related Verilog code from `DigitalTraining/FPGA/`,
  duplicated at the top level (same files, same subfolder names like
  `FPGA_02_adder`, `FPGA_03_counter`, `FPGA_04_pow2`, `FPGA_e`, `FPGA_e2`).
  When editing exercises under one of these names, check whether the
  duplicate under `DigitalTraining/FPGA/` also needs the same change.
- `PLL論文/` — notes and Q&A (`*.md`/`*.pdf`) written while reading PLL-related
  papers/theses for the graduation thesis; Japanese-language summaries per
  chapter (`2章まとめ.md`, `3章で出た疑問.md`, etc.).
- `matlab/` — MATLAB/Simulink models and scripts for PLL noise analysis and
  NSGA-II-based multi-objective circuit optimization (see below).
- Root-level PDFs — reference papers on DTC-based / harmonic-mixer-based
  fractional-N PLLs.

There is no CI, linter, or automated test suite configured. "Running" this
repo means simulating Verilog testbenches or executing MATLAB scripts by hand.

## Common commands

### Verilog/SystemVerilog simulation (Icarus Verilog + GTKWave)

Compile lower-level modules before the modules/testbenches that depend on
them (Icarus Verilog is order-sensitive for module dependencies):

```bash
iverilog -o build/top.out src/top.v
vvp build/top.out
gtkwave dump.vcd   # inspect the resulting waveform
```

For SystemVerilog sources (e.g. files under `DigitalTraining/FPGA/FPGA_e/`,
`*.sv`), add `-g2012`:

```bash
iverilog -g2012 -o tb.out module1.v module2.v testbench.v
vvp tb.out
```

Example (from `DigitalTraining/FPGA/FPGA_e2/build.ps1`, one folder's actual
compile order):

```bash
iverilog -o tb_top_e_display.out init_400bit.v adder_400bit.v divider_400bit.v e_calc.v convert_to_10.v seg_hex.v top_e_display.v tb_top_e_display.v
vvp tb_top_e_display.out
```

Each `FPGA_*` subfolder is self-contained (its own modules + `*_test.v`
testbench); there's no shared top-level build script, so compile within the
relevant subfolder using its own file set.

### MATLAB (PLL noise analysis / NSGA-II optimization)

Scripts in `matlab/` are run directly in MATLAB (`close all; clear all;`-style
scripts, not functions with test harnesses):

- `Conv_FNPLL_noise_analysis.m`, `Dual_FB_PLL_noise_analysis.m` — closed-form
  loop-transfer-function and phase-noise analysis for single-loop vs.
  dual-feedback fractional-N PLLs. Loop parameters (reference frequency,
  division ratio, VCO gain, charge-pump current, etc.) are set as local
  variables near the top of the script — edit them in place to sweep a
  design point.
- `DualFF_typeI_typeII_lag_lead_lag.m` — loop-filter/compensation comparison.
- `Basic_FNPLL.slx` — Simulink model of a basic fractional-N PLL.
- `NSGA-II_for_DTC_onlyVCO/`, `TCAS_DATA_CODE/FIG*/{DTC,Frac,HM,...}/`,
  `Files_for_Jitter_Power_Plot/` — each is an independent copy of a
  Kanpur-GA-Lab-derived NSGA-II implementation (`nsga_2.m`,
  `evaluate_objective.m`, `initialize_variables.m`, `genetic_operator.m`,
  `non_domination_sort_mod.m`, `replace_chromosome.m`,
  `tournament_selection.m`, `objective_description_function.m`). Run via
  `nsga_2(pop, gen)` from inside that folder. The objective function that
  differs per experiment (jitter/power trade-off for DTC-based vs.
  harmonic-mixer-based PLLs) lives in that folder's `evaluate_objective.m` —
  when modifying an optimization objective, edit the copy in the specific
  experiment folder, not a shared library (there isn't one; each folder
  forked the NSGA-II code independently). Results land in
  `OPTresults/`/`Result_onlyVCO/`-style subfolders as `.fig` files per
  generation plus a `solution.txt`.

## Notes for making changes

- Don't try to unify the duplicated `FPGA/` and `DigitalTraining/FPGA/`
  trees, or the many duplicated NSGA-II copies under `matlab/` — they are
  intentionally independent snapshots per training exercise / experiment,
  not a shared library that got copy-pasted by mistake.
- Japanese is the primary language throughout comments, filenames, and
  markdown notes; match the existing language when editing prose files
  (`PLL論文/*.md`, `README.md`).
- `.gitignore` excludes simulator/build artifacts (`*.out`, `*.vcd`, `*.vvp`,
  `*.fst`, Quartus `db/`, `output_files/`, etc.) and `PLL論文/English.txt` —
  don't commit files matching those patterns.
