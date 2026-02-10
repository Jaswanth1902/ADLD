// ============================================================================
// Verilog Logic Simulator - JavaScript Implementation
// ============================================================================
// This module implements the exact Verilog FSM logic in JavaScript for
// real-time browser-based simulation and demonstration.
// ============================================================================

class VendingMachineSimulator {
    constructor() {
        // FSM States (matching Verilog encoding)
        this.STATES = {
            IDLE: 0,
            ACCEPT_COIN: 1,
            WAIT_SELECTION: 2,
            DISPENSE_ITEM: 3,
            RETURN_CHANGE: 4
        };
        
        this.STATE_NAMES = ['IDLE', 'ACCEPT_COIN', 'WAIT_SELECTION', 'DISPENSE_ITEM', 'RETURN_CHANGE'];
        
        // System state variables
        this.currentState = this.STATES.IDLE;
        this.nextState = this.STATES.IDLE;
        this.credit = 0;
        this.clk = false;
        this.cycle = 0;
        
        // Input signals
        this.coin10Raw = false;
        this.coin20Raw = false;
        this.coin50Raw = false;
        this.selectRaw = false;
        this.resetSignal = false;
        
        // Synchronized inputs (after io_interface processing)
        this.coin10Sync = false;
        this.coin20Sync = false;
        this.coin50Sync = false;
        this.selectSync = false;
        
        // Previous input states (for edge detection)
        this.coin10Prev = false;
        this.coin20Prev = false;
        this.coin50Prev = false;
        this.selectPrev = false;
        
        // Output signals
        this.dispense = false;
        this.returnChange = false;
        
        // Control signals (internal)
        this.creditEnable = false;
        this.creditLoad = false;
        this.creditDecrement = false;
        this.creditClear = false; // New signal
        this.creditValue = 0;
        
        // Internal state for latching inputs
        this.latchedCoinValue = 0;
        this.latchedSelect = false;
        
        // Constants - now dynamic
        this.ITEM_COST = 15; // Default cost
        
        // Simulation control
        this.running = false;
        this.stepMode = false;
        this.clockInterval = null;
        
        // Signal history for waveform display
        this.signalHistory = [];
        this.maxHistoryLength = 50;
        
        // Event callbacks
        this.onStateChange = null;
        this.onCreditChange = null;
        this.onDispense = null;
        this.onReturnChange = null;
        this.onClockTick = null;
    }
    
    // ========================================================================
    // Configuration
    // ========================================================================
    setItemCost(cost) {
        this.ITEM_COST = cost;
    }

    // ========================================================================
    // Main Clock Tick (Positive Edge Triggered)
    // ========================================================================
    tick() {
        this.clk = !this.clk;
        
        if (this.clk) {
            // Positive edge - update all sequential logic
            this.cycle++;
            
            // 1. I/O Interface (input synchronization and edge detection)
            this.updateIOInterface();
            
            // 2. FSM State Update (sequential logic)
            this.updateFSMState();
            
            // 3. FSM Output Logic (combinational)
            this.updateFSMOutputs();
            
            // 4. Credit Register Update (sequential logic)
            this.updateCreditRegister();
            
            // 5. Record signals for waveform
            this.recordSignals();
            
            // 6. Notify UI
            if (this.onClockTick) {
                this.onClockTick();
            }
        }
    }
    
    // ========================================================================
    // I/O Interface Module (io_interface.v)
    // ========================================================================
    updateIOInterface() {
        // Two-stage synchronizer (simplified to one stage for demo speed)
        // In real hardware, this would be 2 flip-flops
        const coin10Synced = this.coin10Raw;
        const coin20Synced = this.coin20Raw;
        const coin50Synced = this.coin50Raw;
        const selectSynced = this.selectRaw;
        
        // Edge detection - generate single-cycle pulses
        this.coin10Sync = coin10Synced && !this.coin10Prev;
        this.coin20Sync = coin20Synced && !this.coin20Prev;
        this.coin50Sync = coin50Synced && !this.coin50Prev;
        this.selectSync = selectSynced && !this.selectPrev;
        
        // Store current values for next edge detection
        this.coin10Prev = coin10Synced;
        this.coin20Prev = coin20Synced;
        this.coin50Prev = coin50Synced;
        this.selectPrev = selectSynced;
        
        // Clear raw inputs after sync (simulate button release)
        this.coin10Raw = false;
        this.coin20Raw = false;
        this.coin50Raw = false;
        this.selectRaw = false;
    }
    
    // ========================================================================
    // Control FSM - State Update (control_fsm.v sequential logic)
    // ========================================================================
    updateFSMState() {
        const prevState = this.currentState;
        
        if (this.resetSignal) {
            this.currentState = this.STATES.IDLE;
            this.nextState = this.STATES.IDLE;
            this.credit = 0;
            this.dispense = false;
            this.returnChange = false;
            this.resetSignal = false;
            this.latchedCoinValue = 0;
            this.latchedSelect = false;
            
            if (this.onStateChange) {
                this.onStateChange(this.STATE_NAMES[this.currentState]);
            }
            return;
        }
        
        // Update current state from next state
        this.currentState = this.nextState;
        
        // Compute next state (combinational logic)
        this.computeNextState();
        
        // Notify if state changed
        if (prevState !== this.currentState && this.onStateChange) {
            this.onStateChange(this.STATE_NAMES[this.currentState]);
        }
    }
    
    // ========================================================================
    // Control FSM - Next State Logic (combinational)
    // ========================================================================
    computeNextState() {
        switch (this.currentState) {
            case this.STATES.IDLE:
                if (this.coin10Sync || this.coin20Sync || this.coin50Sync) {
                    this.nextState = this.STATES.ACCEPT_COIN;
                    // Latch the coin value here so it's available in the next state
                    if (this.coin10Sync) this.latchedCoinValue = 10;
                    else if (this.coin20Sync) this.latchedCoinValue = 20;
                    else if (this.coin50Sync) this.latchedCoinValue = 50;
                } else {
                    this.nextState = this.STATES.IDLE;
                }
                break;
                
            case this.STATES.ACCEPT_COIN:
                // Calculate what credit WILL BE after this cycle's update
                // We are in ACCEPT_COIN, so we know we are adding the latched coin value
                let futureCredit = this.credit + this.latchedCoinValue;
                
                if (futureCredit >= this.ITEM_COST) {
                    this.nextState = this.STATES.WAIT_SELECTION;
                } else {
                    this.nextState = this.STATES.IDLE;
                }
                break;
                
            case this.STATES.WAIT_SELECTION:
                // Latch select signal if it occurs
                if (this.selectSync) {
                    this.latchedSelect = true;
                }
                
                if (this.selectSync || this.latchedSelect) {
                    this.nextState = this.STATES.DISPENSE_ITEM;
                    this.latchedSelect = false; // Clear latch upon transition
                } else if (this.coin10Sync || this.coin20Sync || this.coin50Sync) {
                    this.nextState = this.STATES.ACCEPT_COIN;
                    // Latch the coin value here too
                    if (this.coin10Sync) this.latchedCoinValue = 10;
                    else if (this.coin20Sync) this.latchedCoinValue = 20;
                    else if (this.coin50Sync) this.latchedCoinValue = 50;
                } else {
                    this.nextState = this.STATES.WAIT_SELECTION;
                }
                break;
                
            case this.STATES.DISPENSE_ITEM:
                if (this.credit > this.ITEM_COST) {
                    this.nextState = this.STATES.RETURN_CHANGE;
                } else {
                    this.nextState = this.STATES.IDLE;
                }
                break;
                
            case this.STATES.RETURN_CHANGE:
                this.nextState = this.STATES.IDLE;
                break;
                
            default:
                this.nextState = this.STATES.IDLE;
        }
    }
    
    // ========================================================================
    // Control FSM - Output Logic (combinational)
    // ========================================================================
    updateFSMOutputs() {
        // Default values
        this.creditEnable = false;
        this.creditLoad = false;
        this.creditDecrement = false;
        this.creditClear = false; // New control signal
        this.creditValue = 0;
        this.dispense = false;
        this.returnChange = false;
        
        switch (this.currentState) {
            case this.STATES.IDLE:
                // No operations
                break;
                
            case this.STATES.ACCEPT_COIN:
                this.creditEnable = true;
                this.creditLoad = true;
                this.creditValue = this.latchedCoinValue; // Use latched value
                break;
                
            case this.STATES.WAIT_SELECTION:
                // Allow additional coin insertions
                if (this.coin10Sync || this.coin20Sync || this.coin50Sync) {
                    this.creditEnable = true;
                    this.creditLoad = true;
                    
                    if (this.coin10Sync) this.creditValue = 10;
                    else if (this.coin20Sync) this.creditValue = 20;
                    else if (this.coin50Sync) this.creditValue = 50;
                }
                break;
                
            case this.STATES.DISPENSE_ITEM:
                this.dispense = true;
                this.creditEnable = true;
                this.creditDecrement = true;
                
                if (this.onDispense) {
                    this.onDispense();
                }
                break;
                
            case this.STATES.RETURN_CHANGE:
                this.returnChange = true;
                // Clear credit after returning change
                this.creditEnable = true;
                this.creditClear = true;
                
                if (this.onReturnChange) {
                    this.onReturnChange(this.credit);
                }
                break;
        }
    }
    
    // ========================================================================
    // Credit Register Module (credit_register.v)
    // ========================================================================
    updateCreditRegister() {
        const prevCredit = this.credit;
        
        if (this.creditEnable) {
            if (this.creditClear) {
                // Clear credit (reset to 0)
                this.credit = 0;
            } else if (this.creditLoad) {
                // Add coin value (with saturation)
                this.credit = Math.min(255, this.credit + this.creditValue);
            } else if (this.creditDecrement) {
                // Subtract item cost
                if (this.credit >= this.ITEM_COST) {
                    this.credit -= this.ITEM_COST;
                }
            }
        }
        
        // Notify if credit changed
        if (prevCredit !== this.credit && this.onCreditChange) {
            this.onCreditChange(this.credit);
        }
    }
    
    // ========================================================================
    // Signal Recording for Waveform Display
    // ========================================================================
    recordSignals() {
        this.signalHistory.push({
            cycle: this.cycle,
            clk: this.clk,
            reset: this.resetSignal,
            coin10: this.coin10Sync,
            coin20: this.coin20Sync,
            coin50: this.coin50Sync,
            select: this.selectSync,
            state: this.currentState,
            credit: this.credit,
            dispense: this.dispense,
            returnChange: this.returnChange
        });
        
        // Limit history size
        if (this.signalHistory.length > this.maxHistoryLength) {
            this.signalHistory.shift();
        }
    }
    
    // ========================================================================
    // Public Control Methods
    // ========================================================================
    insertCoin10() {
        this.coin10Raw = true;
    }
    
    insertCoin20() {
        this.coin20Raw = true;
    }
    
    insertCoin50() {
        this.coin50Raw = true;
    }
    
    selectItem() {
        this.selectRaw = true;
    }
    
    reset() {
        this.resetSignal = true;
        this.tick(); // Process reset immediately
    }
    
    start() {
        if (!this.running && !this.stepMode) {
            this.running = true;
            this.clockInterval = setInterval(() => this.tick(), 500); // 2 Hz clock
        }
    }
    
    stop() {
        if (this.clockInterval) {
            clearInterval(this.clockInterval);
            this.clockInterval = null;
        }
        this.running = false;
    }
    
    step() {
        if (this.stepMode) {
            this.tick();
        }
    }
    
    setStepMode(enabled) {
        this.stepMode = enabled;
        if (enabled) {
            this.stop();
        } else {
            this.start();
        }
    }
    
    getStateName() {
        return this.STATE_NAMES[this.currentState];
    }
    
    getCredit() {
        return this.credit;
    }
    
    getSignalHistory() {
        return this.signalHistory;
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = VendingMachineSimulator;
}
