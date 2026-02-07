// ============================================================================
// Credit Register Module
// ============================================================================
// This module simulates an internal 8-bit register in a microcontroller's
// data memory. It models the behavior of a memory-mapped register that
// stores credit accumulated from coin insertions.
//
// Microcontroller Analogy:
//   - Represents a register in the MCU's RAM (e.g., address 0x20)
//   - Updated synchronously on clock edge (mimics MCU instruction cycle)
//   - Controlled by enable signals from the control unit (FSM)
// ============================================================================

module credit_register (
    input wire clk,              // System clock
    input wire reset,            // Synchronous reset
    input wire enable,           // Enable credit update
    input wire load,             // Load new credit value
    input wire decrement,        // Decrement credit (dispense operation)
    input wire [7:0] credit_in,  // Credit value to add
    output reg [7:0] credit_out  // Current credit value
);

    // ========================================================================
    // Synchronous Register Update Logic
    // ========================================================================
    // Models a synchronous register update similar to MCU instruction execution
    // All updates occur on the positive clock edge
    
    always @(posedge clk) begin
        if (reset) begin
            // Reset state: Clear credit register
            credit_out <= 8'd0;
        end
        else if (enable) begin
            if (load) begin
                // Load operation: Add incoming credit to current value
                // Saturate at 255 to prevent overflow
                if (credit_out + credit_in > 8'd255)
                    credit_out <= 8'd255;
                else
                    credit_out <= credit_out + credit_in;
            end
            else if (decrement) begin
                // Decrement operation: Subtract item cost (₹15)
                // Only decrement if sufficient credit exists
                if (credit_out >= 8'd15)
                    credit_out <= credit_out - 8'd15;
            end
            // If neither load nor decrement, hold current value
        end
    end

endmodule
