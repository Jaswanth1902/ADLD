# Microcontroller-Based Vending Machine Controller

**Domain:** Advanced Digital Logic Design (ADLD) + Microcontroller Architecture  
**Implementation:** Verilog HDL + Interactive Web Demo  
**Purpose:** Academic Project - Software-only FSM Simulation

---

## 🚀 Quick Start

**Try the Interactive Demo:**
1. Open `website/index.html` in any modern web browser
2. Click "Try It Live" or scroll to the Interactive Demonstration section
3. Use the coin buttons to insert ₹5 or ₹10
4. Click "SELECT ITEM" when you have ₹15 or more
5. Watch the FSM transitions, waveforms, and animations in real-time!

**Keyboard Shortcuts for Demo:**
- `5` - Insert ₹5 coin
- `1` - Insert ₹10 coin
- `S` - Select item
- `R` - Reset system
- `D` - Run auto demo
- `Space` - Next cycle (in step mode)

---

## 📋 Project Overview

This project simulates the internal control logic of a microcontroller-based vending machine using Verilog HDL. The FSM represents firmware behavior, while registers and I/O signals abstract internal microcontroller resources.

### System Specifications
- **Item Cost:** ₹15 per item
- **Accepted Coins:** ₹5 and ₹10
- **FSM States:** 5 states (IDLE, ACCEPT_COIN, WAIT_SELECTION, DISPENSE_ITEM, RETURN_CHANGE)
- **Architecture:** Modular design with separate control and datapath units
- **Synchronous Design:** All operations clocked

---

## 📁 Project Structure

```
ADLD/
├── verilog/                          # Verilog HDL Source Files
│   ├── credit_register.v             # 8-bit credit storage register
│   ├── io_interface.v                # GPIO abstraction with synchronization
│   ├── control_fsm.v                 # 5-state FSM control unit
│   ├── vending_machine_top.v         # Top-level integration
│   └── vending_machine_tb.v          # Comprehensive testbench
│
├── website/                          # Interactive Demo Website
│   ├── index.html                    # Main HTML structure
│   ├── styles.css                    # Modern CSS styling
│   └── js/
│       ├── simulator.js              # Verilog logic in JavaScript
│       ├── waveform-viewer.js        # Live waveform renderer
│       └── ui-controller.js          # UI and interaction logic
│
├── README.md                         # This file
├── DEMO_SCRIPT.md                    # 5-minute presentation script
└── VIVA_GUIDE.md                     # Common viva questions & answers
```

---

## 🔬 Verilog Simulation

### Prerequisites
- **Icarus Verilog** (iverilog) - for simulation
- **GTKWave** - for waveform viewing

### Installation (Windows)
```powershell
# Using chocolatey
choco install verilog gtkwave

# Or download from:
# http://bleyer.org/icarus/  (Icarus Verilog)
# http://gtkwave.sourceforge.net/  (GTKWave)
```

###Running Simulation
```bash
cd verilog

# Compile all modules
iverilog -o sim vending_machine_tb.v vending_machine_top.v control_fsm.v credit_register.v io_interface.v

# Run simulation
vvp sim

# View waveforms
gtkwave waveform.vcd
```

### Expected Output
```
========================================
Vending Machine Controller Testbench
Item Cost: Rs.15
========================================

[TEST 1] System Reset
✓ PASS: Reset successful, credit=0, state=IDLE

[TEST 2] Insufficient Credit - Insert Rs.5 only
✓ PASS: Rs.5 accepted, no dispense (insufficient credit)

[TEST 3] Exact Payment - Rs.5 + Rs.10 = Rs.15
✓ PASS: Total Rs.15 accumulated
  → Selecting item...
✓ PASS: Item dispensed, credit cleared, no change

... [more tests]
```

---

## 🌐 Interactive Website

### Local Viewing
1. Simply open `website/index.html` in your browser
2. No server required - all static files

### Features
- **Real-time Simulation:** JavaScript implementation of exact Verilog logic
- **FSM Visualization:** Animated state diagram with live transitions
- **Waveform Viewer:** Digital oscilloscope-style signal display
- **Step-by-Step Mode:** Clock-by-clock execution for detailed demonstration
- **Animated UI:** Visual vending machine with dispense animations
- **Event Log:** Transaction history with timestamps

### GitHub Pages Deployment

1. Create a new repository on GitHub:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: Microcontroller vending machine project"
   git branch -M main
   git remote add origin https://github.com/YOUR-USERNAME/microcontroller-vending-machine.git
   git push -u origin main
   ```

2. Enable GitHub Pages:
   - Go to repository Settings → Pages
   - Source: Deploy from branch `main`
   - Folder: `/website` (or root if website is at root)
   - Click Save

3. Access your live demo at:
   `https://YOUR-USERNAME.github.io/microcontroller-vending-machine/`

---

## 🎓 For Evaluators

### Microcontroller Relevance

This project clearly demonstrates microcontroller concepts:

| Verilog Module | MCU Component | Purpose |
|----------------|---------------|---------|
| `io_interface.v` | GPIO Peripheral | Input conditioning, debouncing, synchronization |
| `control_fsm.v` | CPU Control Unit | FSM-based firmware execution |
| `credit_register.v` | Internal RAM/Register | Data storage and arithmetic operations |
| `vending_machine_top.v` | Complete MCU System | Integration of control and datapath |

### Key Academic Concepts Demonstrated
1. ✓ Finite State Machine design for embedded systems
2. ✓ Synchronous digital design principles
3. ✓ Modular architecture (separation of control and datapath)
4. ✓ I/O synchronization and metastability prevention
5. ✓ Register-level modeling of MCU internals
6. ✓ Comprehensive testbench development

### Assessment Criteria Checklist
- [x] FSM-based control unit implementation
- [x] Microcontroller architecture modeling
- [x] Software-only simulation (no physical hardware)
- [x] Modular Verilog design
- [x] Comprehensive testing
- [x] Professional documentation
- [x] Interactive demonstration capability

---

## 🎤 Demonstration Guide

For a 5-minute live demo, see [`DEMO_SCRIPT.md`](DEMO_SCRIPT.md)

**Quick Demo Flow:**
1. **Show architecture** (30s) - Explain MCU mapping
2. **Live interaction** (2m) - Insert coins, dispense item, show change
3. **Step-by-step FSM** (1.5m) - Enable step mode, explain transitions
4. **Waveforms** (1m) - Show signal timing and state changes

---

## 📚 Viva Preparation

See [`VIVA_GUIDE.md`](VIVA_GUIDE.md) for detailed Q&A

**Common Topics:**
- Why FSM for microcontrollers?
- State transition logic explanation
- Difference between control and datapath
- How to implement on real MCU (Arduino/STM32)
- Synchronization and metastability

---

## 🔮 Future Extensions

1. **Hardware Implementation**
   - Deploy on FPGA (Xilinx/Altera)
   - Implement on Arduino/STM32 in C
   - Add physical coin sensors and motors

2. **Feature Enhancements**
   - Multiple items with different prices
   - Inventory management
   - LCD/7-segment display driver
   - Coin validation logic

3. **Advanced Features**
   - UART communication for logging
   - Error detection and recovery
   - Power management states
   - Security features (anti-fraud)

---

## 👨‍💻 Technical Details

### FSM State Encoding
- **Binary encoding:** 3 bits for 5 states
- **States:**
  - `000` - IDLE
  - `001` - ACCEPT_COIN
  - `010` - WAIT_SELECTION
  - `011` - DISPENSE_ITEM
  - `100` - RETURN_CHANGE

### Signal Specifications
- **Clock Frequency:** Configurable (100MHz for simulation)
- **Reset:** Synchronous, active-high
- **Credit Register:** 8-bit unsigned (0-255)
- **Inputs:** Positive-edge triggered pulses
- **Outputs:** Level-triggered signals

---

## 📄 License

This project is created for academic purposes as part of ADLD and Microcontroller coursework.

---

## 🙏 Acknowledgments

- Verilog HDL standards (IEEE 1364-2005)
- Microcontroller architecture principles
- FSM design best practices for embedded systems

---

## 📞 Support

For questions or issues:
- Review the Verilog code comments
- Check `VIVA_GUIDE.md` for conceptual explanations
- Use the interactive demo to understand behavior
- Examine waveforms for timing analysis

---

**Project Year:** 2026  
**Domain:** ADLD + Microcontrollers  
**Implementation:** Software-only FSM Simulation
