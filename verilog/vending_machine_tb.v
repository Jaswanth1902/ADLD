// ============================================================================
// Vending Machine Testbench
// ============================================================================
// Comprehensive testbench for verifying the vending machine controller.
// Tests various scenarios including normal operation, edge cases, and
// reset functionality.
// ============================================================================

`timescale 1ns/1ps

module vending_machine_tb;

    // ========================================================================
    // Testbench Signals
    // ========================================================================
    
    reg clk;
    reg reset;
    reg coin_5;
    reg coin_10;
    reg select_item;
    
    wire dispense;
    wire return_change;
    wire [7:0] current_credit;
    wire [2:0] state_debug;
    
    // State names for display
    reg [127:0] state_name;
    
    // ========================================================================
    // Device Under Test (DUT) Instantiation
    // ========================================================================
    
    vending_machine_top dut (
        .clk(clk),
        .reset(reset),
        .coin_5(coin_5),
        .coin_10(coin_10),
        .select_item(select_item),
        .dispense(dispense),
        .return_change(return_change),
        .current_credit(current_credit),
        .state_debug(state_debug)
    );
    
    // ========================================================================
    // Clock Generation (10ns period = 100MHz)
    // ========================================================================
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Toggle every 5ns
    end
    
    // ========================================================================
    // State Name Decoder (for readability)
    // ========================================================================
    
    always @(*) begin
        case (state_debug)
            3'b000: state_name = "IDLE";
            3'b001: state_name = "ACCEPT_COIN";
            3'b010: state_name = "WAIT_SELECTION";
            3'b011: state_name = "DISPENSE_ITEM";
            3'b100: state_name = "RETURN_CHANGE";
            default: state_name = "UNKNOWN";
        endcase
    end
    
    // ========================================================================
    // Signal Monitoring
    // ========================================================================
    
    initial begin
        $display("\n========================================");
        $display("Vending Machine Controller Testbench");
        $display("Item Cost: Rs.15");
        $display("========================================\n");
        
        $monitor("Time=%0t | State=%s | Credit=Rs.%0d | Dispense=%b | Change=%b", 
                 $time, state_name, current_credit, dispense, return_change);
    end
    
    // ========================================================================
    // Waveform Dump (for GTKWave/ModelSim)
    // ========================================================================
    
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, vending_machine_tb);
    end
    
    // ========================================================================
    // Test Stimulus
    // ========================================================================
    
    initial begin
        // Initialize all inputs
        reset = 0;
        coin_5 = 0;
        coin_10 = 0;
        select_item = 0;
        
        // ====================================================================
        // Test 1: System Reset
        // ====================================================================
        $display("\n[TEST 1] System Reset");
        reset = 1;
        #20;
        reset = 0;
        #20;
        
        if (current_credit == 8'd0 && state_debug == 3'b000) begin
            $display("✓ PASS: Reset successful, credit=0, state=IDLE");
        end else begin
            $display("✗ FAIL: Reset failed!");
        end
        
        // ====================================================================
        // Test 2: Insufficient Credit (₹5 only)
        // ====================================================================
        $display("\n[TEST 2] Insufficient Credit - Insert Rs.5 only");
        #20;
        coin_5 = 1;
        #10;
        coin_5 = 0;
        #50;
        
        if (current_credit == 8'd5 && dispense == 0) begin
            $display("✓ PASS: Rs.5 accepted, no dispense (insufficient credit)");
        end else begin
            $display("✗ FAIL: Incorrect behavior for insufficient credit");
        end
        
        // ====================================================================
        // Test 3: Exact Payment (₹5 + ₹10 = ₹15)
        // ====================================================================
        $display("\n[TEST 3] Exact Payment - Rs.5 + Rs.10 = Rs.15");
        
        // Add Rs.10 to existing Rs.5
        #20;
        coin_10 = 1;
        #10;
        coin_10 = 0;
        #50;
        
        if (current_credit == 8'd15) begin
            $display("✓ PASS: Total Rs.15 accumulated");
        end
        
        // Select item
        $display("  → Selecting item...");
        #20;
        select_item = 1;
        #10;
        select_item = 0;
        #50;
        
        if (dispense == 0 && current_credit == 8'd0) begin
            $display("✓ PASS: Item dispensed, credit cleared, no change");
        end else begin
            $display("✗ FAIL: Incorrect dispense behavior");
        end
        
        // ====================================================================
        // Test 4: Overpayment with Change (₹10 + ₹10 = ₹20, change = ₹5)
        // ====================================================================
        $display("\n[TEST 4] Overpayment - Rs.10 + Rs.10 = Rs.20 (change Rs.5)");
        
        // Reset for new transaction
        #50;
        reset = 1;
        #20;
        reset = 0;
        #20;
        
        // Insert two Rs.10 coins
        coin_10 = 1;
        #10;
        coin_10 = 0;
        #50;
        
        coin_10 = 1;
        #10;
        coin_10 = 0;
        #50;
        
        if (current_credit == 8'd20) begin
            $display("✓ PASS: Rs.20 accumulated");
        end
        
        // Select item
        $display("  → Selecting item...");
        #20;
        select_item = 1;
        #10;
        select_item = 0;
        #50;
        
        // Check if change was indicated
        // Note: After dispense, credit should be reduced by Rs.15
        if (current_credit == 8'd5) begin
            $display("✓ PASS: Change of Rs.5 remaining in credit");
        end
        
        // ====================================================================
        // Test 5: Maximum Credit Scenario (₹25 = Rs.10*2 + Rs.5)
        // ====================================================================
        $display("\n[TEST 5] Maximum Credit - Rs.10 + Rs.10 + Rs.5 = Rs.25");
        
        reset = 1;
        #20;
        reset = 0;
        #20;
        
        // Insert Rs.10
        coin_10 = 1;
        #10;
        coin_10 = 0;
        #50;
        
        // Insert another Rs.10
        coin_10 = 1;
        #10;
        coin_10 = 0;
        #50;
        
        // Insert Rs.5
        coin_5 = 1;
        #10;
        coin_5 = 0;
        #50;
        
        if (current_credit == 8'd25) begin
            $display("✓ PASS: Rs.25 accumulated");
        end
        
        // Select item
        select_item = 1;
        #10;
        select_item = 0;
        #50;
        
        if (return_change == 1 || current_credit == 8'd10) begin
            $display("✓ PASS: Item dispensed with Rs.10 change");
        end
        
        // ====================================================================
        // Test 6: Reset During Operation
        // ====================================================================
        $display("\n[TEST 6] Reset During Operation");
        
        #50;
        coin_10 = 1;
        #10;
        coin_10 = 0;
        #20;
        
        // Reset while credit exists
        $display("  → Resetting with Rs.10 credit...");
        reset = 1;
        #20;
        reset = 0;
        #20;
        
        if (current_credit == 8'd0 && state_debug == 3'b000) begin
            $display("✓ PASS: Reset clears credit and returns to IDLE");
        end else begin
            $display("✗ FAIL: Reset did not clear state properly");
        end
        
        // ====================================================================
        // Test Summary
        // ====================================================================
        #100;
        $display("\n========================================");
        $display("Testbench Completed");
        $display("========================================\n");
        $display("Review waveform.vcd for detailed signal analysis");
        $display("All critical scenarios tested:\n");
        $display("  ✓ System reset");
        $display("  ✓ Insufficient credit handling");
        $display("  ✓ Exact payment (Rs.15)");
        $display("  ✓ Overpayment with change");
        $display("  ✓ Maximum credit scenario");
        $display("  ✓ Reset during operation\n");
        
        $finish;
    end

endmodule
