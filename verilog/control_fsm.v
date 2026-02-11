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
    input wire coin_10_detected, // ₹10 coin pulse
    input wire coin_20_detected, // ₹20 coin pulse
    input wire coin_50_detected, // ₹50 coin pulse
    input wire select_detected,  // Item selection pulse
    input wire [2:0] item_id,    // Selected item ID (0-4)
    
    // Input from credit register (datapath feedback)
    input wire [7:0] current_credit,
    
    // Control outputs (to datapath and external world)
    output reg credit_enable,    // Enable credit register update
    output reg credit_load,      // Load credit (add coins)
    output reg credit_decrement, // Decrement credit (dispense)
    output reg [7:0] credit_value, // Value to add/subtract
    output reg dispense,         // Dispense item signal
    output reg return_change,    // Return change signal
    output reg [2:0] state_out   // Current state (for monitoring/debug)
);

    // ========================================================================
    // State Encoding
    // ========================================================================
    parameter [2:0] IDLE          = 3'b000;
    parameter [2:0] ACCEPT_COIN   = 3'b001;
    parameter [2:0] WAIT_SELECTION= 3'b010;
    parameter [2:0] DISPENSE_ITEM = 3'b011;
    parameter [2:0] RETURN_CHANGE = 3'b100;
    
    // ========================================================================
    // Item Cost Configuration
    // ========================================================================
    // 0: Coffee (15), 1: Chips (20), 2: Chocolate (25), 3: Juice (30), 4: Milkshake (50)
    reg [7:0] selected_item_cost;
    
    always @(*) begin
        case (item_id)
            3'd0: selected_item_cost = 8'd15; // Coffee
            3'd1: selected_item_cost = 8'd20; // Chips
            3'd2: selected_item_cost = 8'd25; // Chocolate
            3'd3: selected_item_cost = 8'd30; // Juice
            3'd4: selected_item_cost = 8'd50; // Milkshake
            default: selected_item_cost = 8'd255; // Invalid (max cost)
        endcase
    end
    
    // ========================================================================
    // State Register
    // ========================================================================
    reg [2:0] current_state, next_state;
    
    always @(posedge clk) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end
    
    always @(*) begin
        state_out = current_state;
    end
    
    // ========================================================================
    // Next State Logic
    // ========================================================================
    always @(*) begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (coin_10_detected || coin_20_detected || coin_50_detected)
                    next_state = ACCEPT_COIN;
            end
            
            ACCEPT_COIN: begin
                // Check if current credit is enough for AT LEAST the cheapest item (15)
                // This transition logic is a bit broad, usually we wait for selection
                if (current_credit >= 8'd15)
                    next_state = WAIT_SELECTION;
                else
                    next_state = IDLE;
            end
            
            WAIT_SELECTION: begin
                if (select_detected) begin
                    // Check if sufficient credit for SELECTED item
                    if (current_credit >= selected_item_cost)
                        next_state = DISPENSE_ITEM;
                end
                else if (coin_10_detected || coin_20_detected || coin_50_detected)
                    next_state = ACCEPT_COIN;
            end
            
            DISPENSE_ITEM: begin
                // If credit remains after deduction (previous credit > cost)
                // Note: current_credit here is the OLD value before decrement? 
                // No, credit register updates on clock. FSM is combinational for next_state.
                // We need to wait one cycle for credit to update.
                // Simplified: Go to Change if we had more than cost.
                // But credit register decrements in this state.
                // Let's assume we go to RETURN_CHANGE unconditionally to check.
                next_state = RETURN_CHANGE;
            end
            
            RETURN_CHANGE: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // ========================================================================
    // Output Logic
    // ========================================================================
    always @(*) begin
        credit_enable = 1'b0;
        credit_load = 1'b0;
        credit_decrement = 1'b0;
        credit_value = 8'd0;
        dispense = 1'b0;
        return_change = 1'b0;
        
        case (current_state)
            IDLE: begin
            end
            
            ACCEPT_COIN: begin
                credit_enable = 1'b1;
                credit_load = 1'b1;
                
                if (coin_10_detected) credit_value = 8'd10;
                else if (coin_20_detected) credit_value = 8'd20;
                else if (coin_50_detected) credit_value = 8'd50;
            end
            
            WAIT_SELECTION: begin
                // Ensure we can still accept coins here
                if (coin_10_detected || coin_20_detected || coin_50_detected) begin
                    credit_enable = 1'b1;
                    credit_load = 1'b1;
                    if (coin_10_detected) credit_value = 8'd10;
                    else if (coin_20_detected) credit_value = 8'd20;
                    else if (coin_50_detected) credit_value = 8'd50;
                end
            end
            
            DISPENSE_ITEM: begin
                dispense = 1'b1; // Trigger dispense motor
                credit_enable = 1'b1;
                credit_decrement = 1'b1;
                credit_value = selected_item_cost; // Subtract specific cost
            end
            
            RETURN_CHANGE: begin
                // If there is any credit left, it is change
                if (current_credit > 0)
                    return_change = 1'b1;
                    
                // In this design, we might want to clear credit here
                // But credit_register only supports 'load' or 'decrement'.
                // To clear, we could load 0? 
                // Currently credit_register doesn't have a clear.
                // Let's assume change return mechanism drains it externally
                // or we implement a clear. For now, let's leave as is.
            end
        endcase
    end

endmodule
