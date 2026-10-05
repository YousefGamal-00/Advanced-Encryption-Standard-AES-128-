# Advanced-Encryption-Standard-AES-128-

# AES Encryption Core: RTL + UVM Verification

A Verilog/SystemVerilog implementation of the AES encryption datapath (AES-128 / 192 / 256) wrapped in a simple valid handshake, together with a UVM testbench that checks it against a Python reference model using constrained-random stimulus and functional coverage.

---

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [RTL Design](#rtl-design)
- [UVM Testbench](#uvm-testbench)
- [Running the Simulation](#running-the-simulation)
- [Known Limitations](#known-limitations)
- [Author](#author)

---

## Overview

| Item | Details |
|---|---|
| Algorithm | AES encryption (FIPS-197), 128-bit data block |
| Key sizes | 128 / 192 / 256 bits (selected by `KEY_WIDTH`) |
| Architecture | Fully combinational round pipeline + registered handshake wrapper |
| Verification | UVM, constrained-random, scoreboard against a Python golden model, functional coverage |
| Languages | Verilog (datapath), SystemVerilog (wrapper + testbench) |

---

## Repository Structure

```
.
├── RTL/
│   ├── AES_Encrypt_top.sv   # Top wrapper: handshake FSM + output register
│   ├── AES_Encrypt.v        # Combinational AES core (key expansion + rounds)
│   ├── encryptRound.v       # One full round: SubBytes → ShiftRows → MixColumns → AddRoundKey
│   ├── keyExpansion.v       # Key schedule for Nk = 4 / 6 / 8
│   ├── subBytes.v           # 16 parallel S-box lookups
│   ├── sbox.v               # S-box table
│   ├── shiftRows.v          # ShiftRows permutation
│   ├── mixColumns.v         # MixColumns over GF(2^8)
│   └── addRoundKey.v        # 128-bit XOR with round key
└── UVM/
    ├── AES_IF.sv            # Interface with driver / monitor clocking blocks
    ├── AES_pkg.sv           # Package: parameters, VIF typedef, class includes
    ├── AES_Seq_item.svh     # Transaction + constraints
    ├── AES_Sequence.svh     # Reset item followed by NUM_TESTS random items
    ├── AES_Sequencer.svh
    ├── AES_Driver.svh
    ├── AES_Monitor.svh
    ├── AES_Agent.svh
    ├── AES_Scoreboard.svh   # Checks DUT vs. Python reference model
    ├── AES_Subscriber.svh   # Functional coverage (AES_CVG)
    ├── AES_Env.svh
    ├── AES_Test.svh
    ├── AES_Config.svh
    ├── top.sv               # Testbench top: clock, DUT, interface, run_test
    └── src_file.list        # Compile list for the UVM files
```

---

## RTL Design

### Datapath: `AES_Encrypt`

A fully combinational AES core, parameterised by `N` (key width), `Nr` (rounds) and `Nk` (key words):

| Key size | `Nk` | `Nr` |
|---|---|---|
| 128-bit | 4 | 10 |
| 192-bit | 6 | 12 |
| 256-bit | 8 | 14 |

Structure: `keyExpansion` produces all `Nr+1` round keys up front, then an initial `addRoundKey`, `Nr-1` instances of `encryptRound` (generated in a `generate` loop), and a final round that omits MixColumns, as in the standard.

### Wrapper: `AES_Encrypt_top`

Adds a two-state handshake around the core.

| Signal | Dir | Description |
|---|---|---|
| `clk` | in | System clock |
| `reset` | in | **Active-low**, asynchronous |
| `valid_in` | in | Launches a new encryption |
| `plain_text[127:0]` | in | Plaintext block |
| `cipher_key[KEY_WIDTH-1:0]` | in | Key |
| `valid_out` | out | High while the FSM is in `S_DONE` |
| `cipher_text[127:0]` | out | Result |

Behaviour:

- FSM states are `S_IDLE` and `S_DONE`. `valid_in` moves `S_IDLE → S_DONE`; `valid_in` held in `S_DONE` stays there (back-to-back transactions, no idle bubble); otherwise it returns to `S_IDLE`.
- `valid_out` is `1` exactly when the FSM is in `S_DONE`.
- In `S_DONE`, `cipher_text` follows the combinational core output. Outside `S_DONE`, it holds the last result captured in `cipher_text_reg` (latched on each accepted `valid_in`).
- An unsupported `KEY_WIDTH` triggers `$fatal` at time 0.

---

## UVM Testbench

### Architecture

```
 AES_Test
   └── AES_Env
         ├── AES_Agent
         │     ├── AES_Sequencer ──► AES_Driver ──► AES_IF ──► DUT
         │     └── AES_Monitor  ◄── AES_IF
         │            │ (analysis port)
         ├────────────┼──► AES_Scoreboard  (Python reference model)
         └────────────┴──► AES_CVG         (functional coverage)
```

### Stimulus

- The sequence first drives one reset item, then `NUM_TESTS` randomized items. In `AES_pkg.sv`, `NUM_TESTS = 50000` and `KEY_WIDTH = 128`.
- Constraints in `AES_Seq_item.svh`: `reset` is deasserted ~95% of the time, and `valid_in` is asserted ~80% of the time. `plain_text` and `cipher_key` are fully random.

### Scoreboard

For every sampled transaction:

| Condition | Check |
|---|---|
| `reset == 0` | `cipher_text == 0` and `valid_out == 0` |
| `valid_out == 1` | `cipher_text` equals the Python model's output for the same plaintext and key |
| otherwise | No check (counted as a match) |

The scoreboard writes the plaintext and key to `../Py_Model/key.txt`, runs `REF_MODEL.py` via `$system`, and reads the expected ciphertext back from `../Py_Model/Ref_Data.txt`. A non-zero exit code from the Python script is a `uvm_fatal`. At the end of the run it reports total matches and mismatches, and it holds the run phase open until `NUM_TESTS` transactions have been checked.

### Functional Coverage

`AES_CVG` samples: `reset`, `valid_in`, `valid_out` (all values), `cipher_text` (6 value ranges), plus two crosses (`reset × valid_in`, `valid_out × cipher_text`) with the impossible combinations marked as ignored.

---

## Running the Simulation

> Prerequisites: a SystemVerilog simulator with UVM support (written with QuestaSim in mind) and Python 3.

1. **Add the Python reference model.** The scoreboard expects `Py_Model/REF_MODEL.py` as a sibling of `UVM/` (see [Known Limitations](#known-limitations)).
2. **Compile RTL first, then the UVM files**, from inside `UVM/`:

   ```tcl
   vlib work
   vlog ../RTL/*.v ../RTL/*.sv
   vlog -f src_file.list
   vsim -c top -do "run -all; quit"
   ```

3. Check the final scoreboard line:
   `Total Matches: <N> || Total Mismatches: 0`

Run from `UVM/`, because the scoreboard uses relative paths (`../Py_Model/...`).

---

## Known Limitations

- **The Python reference model is not included in this repository.** `AES_Scoreboard.svh` depends on `Py_Model/REF_MODEL.py`, which reads `key.txt` (plaintext on line 1, key on line 2) and writes the expected ciphertext to `Ref_Data.txt`. Add it before running.
- `UVM/src_file.list` covers the testbench files only; RTL files must be compiled separately, as shown above.
- The scoreboard launches a Python process for each checked transaction, which makes long runs slow.
- The testbench is configured for AES-128. Other key widths are supported by the RTL but require changing `KEY_WIDTH` in `AES_pkg.sv`.
- No simulation logs or coverage reports are included for this project.

---

## Author

**Yousef Gamal**
