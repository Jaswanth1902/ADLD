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
    reg coin_10;
    reg coin_20;
    reg coin_50;
    reg select_item;
    reg [2:0] item_id;
    
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
        .coin_10(coin_10),
        .coin_20(coin_20),
        .coin_50(coin_50),
        .select_item(select_item),
        .item_id(item_id),
        .dispense(dispense),
        .return_change(return_change),
        .current_credit(current_credit),
        .state_debug(state_debug)
    );
    
    // ========================================================================
    // Clock Generation
    // ========================================================================
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz
    end
    
    // ========================================================================
    // State Decoder
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
        $display("Vending Machine Testbench (New Specs)");
        $display("Items: Coffee(15), Chips(20), Choco(25), Juice(30), Milkshake(50)");
        $display("========================================\n");
        
        $monitor("Time=%0t | State=%s | Credit=Rs.%0d | Dispense=%b | Change=%b", 
                 $time, state_name, current_credit, dispense, return_change);
    end
    
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, vending_machine_tb);
    end
    
    // ========================================================================
    // Test Scenario
    // ========================================================================
    
    initial begin
        // Initialize
        reset = 1;
        coin_10 = 0;
        coin_20 = 0;
        coin_50 = 0;
        select_item = 0;
        item_id = 0;
        
        #20 reset = 0;
        #20;
        
        // --------------------------------------------------------------------
        // TEST 1: Buy Coffee (₹15) with ₹20 coin -> Expect ₹5 Change
        // --------------------------------------------------------------------
        $display("\n[TEST 1] Buy Coffee (Rs.15) with Rs.20 Coin");
        
        coin_20 = 1; #10; coin_20 = 0; // Insert 20
        #50;
        
        // Select Coffee (ID 0)
        item_id = 3'd0;
        select_item = 1; #10; select_item = 0;
        #50;
        
        if (dispense) $display("✓ PASS: Coffee dispensed");
        else $display("✗ FAIL: No dispense");
        
        // Wait for Return Change state and back to IDLE
        #50;
        
        // --------------------------------------------------------------------
        // TEST 2: Buy Milkshake (₹50) with ₹50 coin -> Exact Change
        // --------------------------------------------------------------------
        $display("\n[TEST 2] Buy Milkshake (Rs.50) with Rs.50 Coin");
        
        // Note: Reset happens implicitly if state went back to IDLE, 
        // but let's force reset to be safe between tests if needed.
        // FSM auto-returns to IDLE, so we just wait.
        
        coin_50 = 1; #10; coin_50 = 0; // Insert 50
        #50;
        
        // Select Milkshake (ID 4)
        item_id = 3'd4;
        select_item = 1; #10; select_item = 0;
        #50;
        
        if (dispense) $display("✓ PASS: Milkshake dispensed");
        
        #50;

        // --------------------------------------------------------------------
        // TEST 3: Insufficient Funds - Buy Chips (₹20) with ₹10
        // --------------------------------------------------------------------
        $display("\n[TEST 3] Insufficient Funds - Buy Chips (Rs.20) with Rs.10");
        
        coin_10 = 1; #10; coin_10 = 0; // Insert 10
        #50;
        
        // Select Chips (ID 1)
        item_id = 3'd1;
        select_item = 1; #10; select_item = 0;
        #50;
        
        if (!dispense && current_credit == 10) $display("✓ PASS: No dispense, credit retained");
        else $display("✗ FAIL: Dispensed incorrectly");

        #50;
        $finish;
    end

endmodule
