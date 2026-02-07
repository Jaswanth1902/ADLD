// ============================================================================
// Control FSM Module (Microcontroller Control Unit)
// ============================================================================
// This module implements the Finite State Machine that represents the
// control unit of a microcontroller running vending machine firmware.
// The FSM controls the sequencing of operations and generates control
// signals for the datapath (credit register, outputs).
//
// Microcontroller Analogy:
//   - Represents firmware state machine running on an MCU
//   - States correspond to firmware execution phases
//   - Control signals are equivalent to register write enables and GPIO outputs
//   - Models the control path in a Harvard/Von Neumann architecture
// ============================================================================

module control_fsm (
    input wire clk,              // System clock
    input wire reset,            // Synchronous reset
    
    // Inputs from I/O interface
    input wire coin_5_detected,  // ₹5 coin insertion pulse
    input wire coin_10_detected, // ₹10 coin insertion pulse
    input wire select_detected,  // Item selection pulse
    
    // Input from credit register (datapath feedback)
    input wire [7:0] current_credit,
    
    // Control outputs (to datapath and external world)
    output reg credit_enable,    // Enable credit register update
    output reg credit_load,      // Load credit (add coins)
    output reg credit_decrement, // Decrement credit (dispense)
    output reg [7:0] credit_value, // Value to add to credit
    output reg dispense,         // Dispense item signal
    output reg return_change,    // Return change signal
    output reg [2:0] state_out   // Current state (for monitoring/debug)
);

    // ========================================================================
    // State Encoding (Parameter-based for clarity)
    // ========================================================================
    // Binary encoding used (can be changed to one-hot for synthesis)
    
    parameter [2:0] IDLE          = 3'b000;  // Waiting for coin input
    parameter [2:0] ACCEPT_COIN   = 3'b001;  // Processing coin insertion
    parameter [2:0] WAIT_SELECTION= 3'b010;  // Waiting for item selection
    parameter [2:0] DISPENSE_ITEM = 3'b011;  // Dispensing item
    parameter [2:0] RETURN_CHANGE = 3'b100;  // Returning change
    
    // Item cost constant
    parameter [7:0] ITEM_COST = 8'd15;  // ₹15 per item
    
    // ========================================================================
    // State Register
    // ========================================================================
    
    reg [2:0] current_state, next_state;
    
    // Sequential logic: Update state on clock edge
    always @(posedge clk) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end
    
    // Expose current state for external monitoring
    always @(*) begin
        state_out = current_state;
    end
    
    // ========================================================================
    // Next State Logic (Combinational)
    // ========================================================================
    // Determines the next state based on current state and inputs
    
    always @(*) begin
        // Default: stay in current state
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                // Wait for coin insertion
                if (coin_5_detected || coin_10_detected)
                    next_state = ACCEPT_COIN;
            end
            
            ACCEPT_COIN: begin
                // Move to wait selection after accepting coin
                // Check if we have sufficient credit
                if (current_credit >= ITEM_COST)
                    next_state = WAIT_SELECTION;
                else
                    next_state = IDLE;  // Not enough credit, wait for more coins
            end
            
            WAIT_SELECTION: begin
                // Accept more coins or wait for selection
                if (select_detected)
                    next_state = DISPENSE_ITEM;
                else if (coin_5_detected || coin_10_detected)
                    next_state = ACCEPT_COIN;  // Allow additional coins
            end
            
            DISPENSE_ITEM: begin
                // After dispensing, check if change is needed
                if (current_credit > ITEM_COST)
                    next_state = RETURN_CHANGE;
                else
                    next_state = IDLE;
            end
            
            RETURN_CHANGE: begin
                // Return to idle after returning change
                next_state = IDLE;
            end
            
            default: begin
                next_state = IDLE;  // Safe default
            end
        endcase
    end
    
    // ========================================================================
    // Output Logic (Combinational)
    // ========================================================================
    // Generates control signals based on current state
    // This is the control path that drives the datapath
    
    always @(*) begin
        // Default values (no operation)
        credit_enable = 1'b0;
        credit_load = 1'b0;
        credit_decrement = 1'b0;
        credit_value = 8'd0;
        dispense = 1'b0;
        return_change = 1'b0;
        
        case (current_state)
            IDLE: begin
                // No active operations, just wait
            end
            
            ACCEPT_COIN: begin
                // Enable credit register and load coin value
                credit_enable = 1'b1;
                credit_load = 1'b1;
                
                // Determine which coin was inserted
                if (coin_5_detected)
                    credit_value = 8'd5;
                else if (coin_10_detected)
                    credit_value = 8'd10;
            end
            
            WAIT_SELECTION: begin
                // Allow additional coin insertions
                if (coin_5_detected || coin_10_detected) begin
                    credit_enable = 1'b1;
                    credit_load = 1'b1;
                    if (coin_5_detected)
                        credit_value = 8'd5;
                    else
                        credit_value = 8'd10;
                end
            end
            
            DISPENSE_ITEM: begin
                // Assert dispense signal and decrement credit
                dispense = 1'b1;
                credit_enable = 1'b1;
                credit_decrement = 1'b1;
            end
            
            RETURN_CHANGE: begin
                // Assert change return signal
                return_change = 1'b1;
                // In a real system, this would control change dispensing mechanism
            end
            
            default: begin
                // Safe default: all outputs inactive
            end
        endcase
    end

endmodule
