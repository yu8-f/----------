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
- `PLL論文/` — notes and reference papers for the graduation thesis, split into
  `参考論文/` (external reference PDFs, including the DTC-based /
  harmonic-mixer-based fractional-N PLL papers previously at the repo root),
  `読書ノート/` (Japanese-language chapter summaries/Q&A, `*.md`/`*.pdf`, e.g.
  `2章まとめ.md`, `3章で出た疑問.md`), and `tools/` (helper scripts, e.g.
  `改行をスペースに.py`). See `PLL論文/README.md` for details.
- `matlab/` — MATLAB/Simulink models and scripts for PLL noise analysis and
  NSGA-II-based multi-objective circuit optimization (see below).

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
  `nsga_2(pop, gen)` from inside that folder — note
  `objective_description_function()` is interactive: it `input()`-prompts
  in the MATLAB console for the number of objectives/decision variables and
  their min/max ranges, then blocks until you press `c` (after confirming
  `evaluate_objective.m` matches), so this can't be scripted headlessly
  without editing that function. The two objectives are always
  `obj(1)` = integrated RMS jitter (s) and `obj(2)` = total power (mW); the
  decision variables are per-block bias currents/powers plus loop-bandwidth
  frequencies (e.g. DTC folder: `[Fc_main, P_vco, P_DTC, P_PD]`, 4
  variables; HM folder: `[Fc_ext, Fc_main, P_vco1, P_vco2, P_PD, P_HM]`, 6
  variables, reflecting the extra auxiliary-PLL stage). The objective
  function that differs per experiment (jitter/power trade-off for DTC-based
  vs. harmonic-mixer-based PLLs) lives in that folder's
  `evaluate_objective.m` — when modifying an optimization objective, edit
  the copy in the specific experiment folder, not a shared library (there
  isn't one; each folder forked the NSGA-II code independently). Results
  land in `OPTresults/`/`Result_onlyVCO/`-style subfolders as `.fig` files
  per generation plus a `solution.txt` (rows = Pareto-front individuals:
  decision variables followed by the two objective values).
- `make_graph.m` — reads the `solution*.txt` outputs of several
  architectures (Integer-N, Fractional-N, DTC-based, HM-based) side by side
  and plots jitter-vs-power Pareto fronts on one log-log figure — this is
  the script that reproduces the paper's headline jitter/power trade-off
  comparison across architectures.

## Domain background (read before touching PLL-related files)

The MATLAB analyses and `PLL論文/` notes revolve around one recurring
problem in fractional-N PLL design: a divider-based feedback path amplifies
DSM quantization noise by the division ratio N (e.g. ~27.6 dB for N=24), so
conventional fractional-N PLLs trade jitter for frequency resolution. The
scripts/papers here explore two escapes from that trade-off, evaluated by
the same two metrics (integrated RMS jitter vs. power):

- **DTC/IDAC-based**: a Digital-to-Time Converter predicts and cancels the
  DSM quantization error directly (needs calibration, e.g. LMS/LUT).
- **Harmonic-Mixer (HM)-based**: replaces the ÷N feedback divider with a
  mixer that subtracts a multiple of a local oscillator (`f_OUT − k·f_LO`,
  via a sample-and-hold harmonic mixer), making the feedback gain ≈1 so
  quantization noise isn't re-amplified. Built up through
  `PLL論文/3章まとめ.md`'s progression: single HM PLL → Triple-Loop PLL (3
  PLLs, unity-gain main loop) → Dual-Feedback PLL (2 PLLs, one loop with two
  feedback paths — HM-based and divider-based — combining the Triple-Loop's
  noise benefit with less area/power).

`Conv_FNPLL_noise_analysis.m` models the conventional single-loop case;
`Dual_FB_PLL_noise_analysis.m` models the Dual-Feedback architecture; the
`matlab/NSGA-II_*` and `TCAS_DATA_CODE/FIG*/{DTC,HM,...}` folders each
numerically optimize one architecture's jitter/power trade-off via NSGA-II
to produce the Pareto fronts that `make_graph.m` compares.

## FPGA_e / FPGA_e2 (Napier's constant on FPGA)

`DigitalTraining/FPGA/FPGA_e/` and `FPGA_e2/` (duplicated under `FPGA/`)
implement fixed-point computation of Euler's number *e* on an FPGA using the
binary-splitting series method, built from scratch: `init_400bit.v` (initial
value), `adder_400bit.v`/`divider_400bit.v` (400-bit fixed-point arithmetic),
`e_calc.v` (state machine that iteratively sums `1/k!` terms — see the
`IDLE`→`DIVIDE`→`ADD`→`FINISH` FSM in `e_calc.v`), `convert_to_10.v` /
`seg_hex.v` (display conversion), and `top_e_display.v` (top-level, targets
the Quartus project `Napier.qpf`). `e_verilog.py` / `e.py` are Python
reference implementations (binary-splitting algorithm) used to
cross-check the Verilog's fixed-point result — when debugging `e_calc.v`,
compare its output against `e_verilog.py`'s.

## Git workflow

This repo's owner has asked that changes be committed directly to `main` —
don't create a feature branch or open a pull request for routine work here
unless explicitly asked to. (This overrides the harness's default
branch/PR-per-change workflow, which still applies to other repositories.)

Write commit messages in Japanese (per the owner's global Claude Code
preference, which doesn't always travel into remote/cloud sessions — keep
it here so it applies regardless of environment).

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
