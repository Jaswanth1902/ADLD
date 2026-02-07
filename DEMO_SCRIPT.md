# 5-Minute Demonstration Script

## Microcontroller-Based Vending Machine Controller

**Presenter Notes:** Practice this script for smooth delivery. Total time: 5 minutes

---

## Opening Statement (30 seconds)

> "Good [morning/afternoon]. I'm presenting a **Microcontroller-Based Vending Machine Controller** implemented using **Verilog HDL**.
>
> This project simulates the internal firmware logic of a microcontroller controlling a vending machine. The design uses a **5-state FSM** for control, modular architecture, and demonstrates key concepts from both Advanced Digital Logic Design and Microcontroller Architecture domains.
>
> Let me show you the interactive demonstration."

**Action:** Navigate to the website, show the hero section briefly.

---

## Section 1: Architecture Overview (1 minute)

**Action:** Scroll to Architecture section.

> "The system follows classic microcontroller architecture with three main components:"

**Point to each block diagram component:**

1. **I/O Interface Module**
   > "This simulates GPIO peripheral functionality - handles input synchronization using a 2-stage flip-flop to prevent metastability, and generates single-cycle pulses for coin insertions."

2. **Control FSM**
   > "The core of our design - a 5-state finite state machine representing the microcontroller's firmware. It generates all control signals for the datapath."

3. **Credit Register**
   > "An 8-bit register simulating internal MCU memory. It accumulates credit from coins and decrements when items are dispensed."

> "All modules are synchronous - updates occur on positive clock edges, just like real microcontroller instruction cycles."

---

## Section 2: Live Interactive Demo (2 minutes)

**Action:** Scroll to Interactive Demonstration section.

> "Now let's see the system in action. Watch the FSM state diagram, credit display, and waveforms update in real-time."

### Demo Scenario 1: Insufficient Credit (20 seconds)

**Action:** Click ₹5 coin button.

> "I'm inserting a ₹5 coin... Notice:
> - FSM transitions from IDLE to ACCEPT_COIN
> - Credit updates to ₹5
> - FSM returns to IDLE because credit is less than item cost of ₹15
> - The waveform shows the coin_5 pulse and credit value change"

### Demo Scenario 2: Exact Payment (40 seconds)

**Action:** Click ₹10 coin button.

> "Adding ₹10... Credit is now ₹15, exactly the item cost.
> - FSM transitions to WAIT_SELECTION - see the state diagram highlight
> - Select button is now enabled"

**Action:** Click SELECT ITEM button.

> "Selecting the item...
> - FSM goes to DISPENSE_ITEM state
> - Dispense signal goes HIGH - watch the waveform
> - Item animates downward
> - Credit is decremented by ₹15, back to zero
> - FSM returns to IDLE"

### Demo Scenario 3: Change Return (40 seconds)

**Action:** Click ₹10 twice, then ₹5.

> "Let me show overpayment. Inserting ₹10... ₹10 again... and ₹5.
> - Total credit: ₹25"

**Action:** Click SELECT ITEM.

> "Now selecting...
> - Item dispensed
> - Credit reduced by ₹15 to ₹10
> - FSM transitions to RETURN_CHANGE state
> - Change return indicator shows ₹10
> - This simulates the change dispensing mechanism"

### Reset Demonstration (20 seconds)

**Action:** Click RESET button.

> "The reset button clears all state synchronously, returning to IDLE with zero credit - just like a microcontroller reset."

---

## Section 3: Step-by-Step FSM Walkthrough (1.5 minutes)

**Action:** Enable Step-by-Step Mode checkbox.

> "For detailed demonstration, I'll enable step-by-step mode. This allows clock-by-clock execution."

**Action:** Click ₹5 button, then click Next Cycle button several times.

> "Each click advances one clock cycle. Watch carefully:
>
> **Cycle 1:** Clock rises, io_interface synchronizes the coin_5 input
>
> **Cycle 2:** FSM detects coin pulse, transitions to ACCEPT_COIN state - see the state diagram update
>
> **Cycle 3:** Control signals activate - credit_enable and credit_load go HIGH
>
> **Cycle 4:** Credit register adds ₹5, credit updates to 5
>
> **Cycle 5:** FSM checks: credit (5) less than item cost (15), returns to IDLE
>
> This demonstrates the synchronous nature of the design - all transitions happen on clock edges, exactly like firmware running on a microcontroller."

**Action:** Disable step mode, add ₹10 to continue.

---

## Section 4: Code & Waveforms (1 minute)

**Action:** Scroll to show waveforms.

> "The waveform viewer shows all signals in real-time:
> - Clock signal (green square wave)
> - Input pulses: coin_5, coin_10, select
> - FSM state (as bus signal with state names)
> - Credit value (8-bit bus)
> - Output signals: dispense and return_change
>
> This matches what you'd see in GTKWave or ModelSim after Verilog simulation."

**Action:** Briefly scroll to Verilog Implementation section.

> "The actual Verilog code implements:
> - Synchronous state machine with separate next-state and output logic
> - Clear microcontroller analogies in comments
> - Modular design for easy synthesis
> - All modules are synthesizable and can be implemented on FPGA or ASIC"

---

## Closing Statement (30 seconds)

**Action:** Scroll to Conclusion section.

> "To summarize:
> - This project successfully models microcontroller firmware using Verilog FSM design
> - Demonstrates key ADLD concepts: synchronous design, FSM methodology, modular architecture
> - Shows microcontroller principles: register operations, I/O handling, control/datapath separation
> - The interactive demo makes it easy to understand complex hardware behavior
>
> The design can be extended to real hardware - FPGA implementation or embedded C on Arduino/STM32 would be straightforward.
>
> I'm ready for questions. Thank you."

---

## Quick Demo Tips

### Before Presentation
1. Open `website/index.html` in Chrome/Firefox
2. Test all buttons to ensure simulator is working
3. Reset the system (click RESET)
4. Have keyboard shortcuts ready: `5`, `1`, `S`, `R`

### During Presentation
- **Speak confidently** - you know the system inside out
- **Point to visual changes** - make connections between FSM, waveforms, and UI
- **Pace yourself** - don't rush through state transitions
- **Use the event log** - it shows clear transaction history

### If Time Runs Short
- Skip "Insufficient Credit" demo
- Combine scenarios into one longer demo
- Focus on FSM and waveforms (most impressive part)

### If Extra Time Available
- Demo auto-demo mode (press `D` key)
- Show GitHub Pages deployment
- Explain future extensions

### Common Follow-up Questions

**Q: "Can you show the actual Verilog code?"**
- Scroll to Implementation section, explain control_fsm.v state machine logic

**Q: "How does this relate to real microcontrollers?"**
- Refer to Architecture section mapping table
- Explain how FSM would become C code state machine

**Q: "What if multiple coins are inserted simultaneously?"**
- Explain I/O interface pulse detection handles one at a time
- Show in step mode how synchronizer processes serially

---

**Good luck with your demonstration! 🎤**
