<div align="center">

![ADLD Banner](assets/adld_banner.svg)

# 🔌 ADLD: Advanced Digital Logic & State Machine Simulator
### *Synchronous Finite State Machines (FSM), Logic Gate Emulation & Truth Table Verification*

[![Field: Computer Architecture](https://img.shields.io/badge/Field-Computer_Architecture-A855F7?style=flat-square)](https://github.com/Jaswanth1902/ADLD)
[![Logic: Synchronous FSM](https://img.shields.io/badge/Logic-Synchronous_FSM-F59E0B?style=flat-square)](https://github.com/Jaswanth1902/ADLD)
[![Gates: Truth Table Verification](https://img.shields.io/badge/Gates-Truth_Table_Verification-10B981?style=flat-square)](https://github.com/Jaswanth1902/ADLD)
[![License: MIT](https://img.shields.io/badge/License-MIT-C5A059.svg?style=flat-square)](LICENSE)

*An interactive digital circuit and sequential state machine simulator verifying flip-flop state transitions, propagation delays, and Boolean logic reduction.*

</div>

---

## ⚡ The Architectural Vision

Visualizing synchronous sequential logic, propagation delays, and edge-triggered state transitions during hardware design is essential for computer architecture education.

**ADLD** provides an empirical simulation environment for digital systems:
- **Sequential State Machine Modeling**: Mealy and Moore Finite State Machine (FSM) state transition analysis.
- **Synchronous Flip-Flops**: D, T, and JK flip-flop excitation table validation.
- **Combinational Optimization**: Karnaugh Map (K-Map) minimization and Boolean reduction proofs.

---

## 🏗️ State Machine Architecture

```mermaid
stateDiagram-v2
    [*] --> ResetState: System Reset Active
    ResetState --> S0: Clock Edge (CLK)
    S0 --> S1: Input X = 1
    S0 --> S0: Input X = 0
    S1 --> S2: Input X = 1
    S1 --> S0: Input X = 0
    S2 --> S0: Sequence Detected (Z = 1)
```

---

## 🧩 Antigravity Skills & Tooling

- **`clean-code`**: Modular separation between combinational gate logic and sequential clock registers.
- **`diagram-design`**: State transition diagrams and gate-level circuit schematics.

---

## 📄 License

Distributed under the [MIT License](LICENSE). Maintained by [Jaswanth Reddy](https://github.com/Jaswanth1902) — *Passionate learner & creative problem solver learning from and giving back to the open-source community.*
