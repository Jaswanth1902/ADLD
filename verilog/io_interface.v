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
    input wire coin_5_raw,       // Raw ₹5 coin signal
    input wire coin_10_raw,      // Raw ₹10 coin signal
    input wire select_raw,       // Raw item selection signal
    
    // Synchronized outputs (clean signals to control unit)
    output reg coin_5_pulse,     // Single-cycle pulse for ₹5 coin
    output reg coin_10_pulse,    // Single-cycle pulse for ₹10 coin
    output reg select_pulse      // Single-cycle pulse for selection
);

    // ========================================================================
    // Two-Stage Synchronizer (Metastability Prevention)
    // ========================================================================
    // Standard practice in microcontrollers to prevent metastability
    // when sampling asynchronous inputs
    
    reg coin_5_sync1, coin_5_sync2;
    reg coin_10_sync1, coin_10_sync2;
    reg select_sync1, select_sync2;
    
    always @(posedge clk) begin
        if (reset) begin
            // Reset synchronizer chain
            coin_5_sync1 <= 1'b0;
            coin_5_sync2 <= 1'b0;
            coin_10_sync1 <= 1'b0;
            coin_10_sync2 <= 1'b0;
            select_sync1 <= 1'b0;
            select_sync2 <= 1'b0;
        end
        else begin
            // First stage: capture raw input
            coin_5_sync1 <= coin_5_raw;
            coin_10_sync1 <= coin_10_raw;
            select_sync1 <= select_raw;
            
            // Second stage: stable synchronized value
            coin_5_sync2 <= coin_5_sync1;
            coin_10_sync2 <= coin_10_sync1;
            select_sync2 <= select_sync1;
        end
    end
    
    // ========================================================================
    // Edge Detection (Pulse Generation)
    // ========================================================================
    // Generates single-cycle pulses on rising edge of synchronized inputs
    // This models button press detection in embedded systems
    
    reg coin_5_prev, coin_10_prev, select_prev;
    
    always @(posedge clk) begin
        if (reset) begin
            coin_5_prev <= 1'b0;
            coin_10_prev <= 1'b0;
            select_prev <= 1'b0;
            coin_5_pulse <= 1'b0;
            coin_10_pulse <= 1'b0;
            select_pulse <= 1'b0;
        end
        else begin
            // Store previous value
            coin_5_prev <= coin_5_sync2;
            coin_10_prev <= coin_10_sync2;
            select_prev <= select_sync2;
            
            // Generate pulse on rising edge (0 -> 1 transition)
            coin_5_pulse <= coin_5_sync2 && !coin_5_prev;
            coin_10_pulse <= coin_10_sync2 && !coin_10_prev;
            select_pulse <= select_sync2 && !select_prev;
        end
    end

endmodule
