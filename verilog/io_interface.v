// ============================================================================
// I/O Interface Module
// ============================================================================
// This module abstracts the GPIO (General Purpose Input/Output) behavior
// of a microcontroller. It handles input conditioning, synchronization,
// and edge detection for external signals.
//
// Microcontroller Analogy:
//   - Simulates GPIO peripheral functionality
//   - Provides debouncing and metastability prevention (2-stage synchronizer)
//   - Generates single-cycle pulses for coin insertion events
//   - Models input conditioning typical in embedded systems
// ============================================================================

module io_interface (
    input wire clk,              // System clock
    input wire reset,            // Synchronous reset
    
    // Raw external inputs (asynchronous from user)
    input wire coin_10_raw,      // Raw ₹10 coin signal
    input wire coin_20_raw,      // Raw ₹20 coin signal
    input wire coin_50_raw,      // Raw ₹50 coin signal
    input wire select_raw,       // Raw selection strobe
    input wire [2:0] item_id_raw,// Raw item selection ID (0-4)
    
    // Synchronized outputs (clean signals to control unit)
    output reg coin_10_pulse,    // Single-cycle pulse for ₹10
    output reg coin_20_pulse,    // Single-cycle pulse for ₹20
    output reg coin_50_pulse,    // Single-cycle pulse for ₹50
    output reg select_pulse,     // Single-cycle pulse for selection
    output reg [2:0] item_id_sync // Synchronized item ID
);

    // ========================================================================
    // Two-Stage Synchronizer (Metastability Prevention)
    // ========================================================================
    
    reg coin_10_sync1, coin_10_sync2;
    reg coin_20_sync1, coin_20_sync2;
    reg coin_50_sync1, coin_50_sync2;
    reg select_sync1, select_sync2;
    reg [2:0] item_id_sync1; // Item ID also needs sync if from async source
    
    always @(posedge clk) begin
        if (reset) begin
            coin_10_sync1 <= 1'b0; coin_10_sync2 <= 1'b0;
            coin_20_sync1 <= 1'b0; coin_20_sync2 <= 1'b0;
            coin_50_sync1 <= 1'b0; coin_50_sync2 <= 1'b0;
            select_sync1 <= 1'b0;  select_sync2 <= 1'b0;
            item_id_sync1 <= 3'b000; item_id_sync <= 3'b000;
        end
        else begin
            // Stage 1
            coin_10_sync1 <= coin_10_raw;
            coin_20_sync1 <= coin_20_raw;
            coin_50_sync1 <= coin_50_raw;
            select_sync1 <= select_raw;
            item_id_sync1 <= item_id_raw;
            
            // Stage 2
            coin_10_sync2 <= coin_10_sync1;
            coin_20_sync2 <= coin_20_sync1;
            coin_50_sync2 <= coin_50_sync1;
            select_sync2 <= select_sync1;
            item_id_sync <= item_id_sync1; // Output is stage 2
        end
    end
    
    // ========================================================================
    // Edge Detection (Pulse Generation)
    // ========================================================================
    
    reg coin_10_prev, coin_20_prev, coin_50_prev, select_prev;
    
    always @(posedge clk) begin
        if (reset) begin
            coin_10_prev <= 1'b0;
            coin_20_prev <= 1'b0;
            coin_50_prev <= 1'b0;
            select_prev <= 1'b0;
            
            coin_10_pulse <= 1'b0;
            coin_20_pulse <= 1'b0;
            coin_50_pulse <= 1'b0;
            select_pulse <= 1'b0;
        end
        else begin
            // Store previous
            coin_10_prev <= coin_10_sync2;
            coin_20_prev <= coin_20_sync2;
            coin_50_prev <= coin_50_sync2;
            select_prev <= select_sync2;
            
            // Pulse on rising edge
            coin_10_pulse <= coin_10_sync2 && !coin_10_prev;
            coin_20_pulse <= coin_20_sync2 && !coin_20_prev;
            coin_50_pulse <= coin_50_sync2 && !coin_50_prev;
            select_pulse <= select_sync2 && !select_prev;
        end
    end

endmodule
