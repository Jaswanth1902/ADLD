// ============================================================================
// Vending Machine Top Module
// ============================================================================
// This is the top-level integration module that represents a complete
// microcontroller system. It instantiates and connects all submodules,
// forming the complete control and datapath for the vending machine.
//
// Microcontroller System Analogy:
//   - Represents the complete MCU chip with all peripherals
//   - GPIO interface = Input/output pins
//   - Control FSM = CPU/Control unit running firmware
//   - Credit register = Internal RAM/register file
//   - Integration shows how control and datapath interact
// ============================================================================

module vending_machine_top (
    input wire clk,              // System clock (MCU clock)
    input wire reset,            // System reset (active high)
    
    // External inputs (GPIO pins)
    input wire coin_10,          // ₹10 coin sensor
    input wire coin_20,          // ₹20 coin sensor
    input wire coin_50,          // ₹50 coin sensor
    input wire select_item,      // Item output strobe
    input wire [2:0] item_id,    // Selected item ID (0-4)
    
    // External outputs (GPIO pins / actuators)
    output wire dispense,        // Item dispense actuator
    output wire return_change,   // Change return actuator
    output wire [7:0] current_credit,  // Credit display (7-segment driver)
    output wire [2:0] state_debug      // Current FSM state (for debugging)
);

    // ========================================================================
    // Internal Signal Declarations
    // ========================================================================
    
    // Synchronized pulses from I/O interface to FSM
    wire coin_10_sync, coin_20_sync, coin_50_sync;
    wire select_sync;
    wire [2:0] item_id_sync;
    
    // Control signals from FSM to credit register (control path)
    wire credit_enable, credit_load, credit_decrement;
    wire [7:0] credit_val_bus; // Connects FSM value output to Register input
    
    // ========================================================================
    // Module Instantiations (Microcontroller Components)
    // ========================================================================
    
    // ------------------------------------------------------------------------
    // I/O Interface (GPIO Peripheral)
    // ------------------------------------------------------------------------
    
    io_interface gpio_peripheral (
        .clk(clk),
        .reset(reset),
        
        // Raw external inputs
        .coin_10_raw(coin_10),
        .coin_20_raw(coin_20),
        .coin_50_raw(coin_50),
        .select_raw(select_item),
        .item_id_raw(item_id),
        
        // Synchronized single-cycle pulses
        .coin_10_pulse(coin_10_sync),
        .coin_20_pulse(coin_20_sync),
        .coin_50_pulse(coin_50_sync),
        .select_pulse(select_sync),
        .item_id_sync(item_id_sync)
    );
    
    // ------------------------------------------------------------------------
    // Credit Register (Internal RAM/Register)
    // ------------------------------------------------------------------------
    
    credit_register credit_storage (
        .clk(clk),
        .reset(reset),
        .enable(credit_enable),
        .load(credit_load),
        .decrement(credit_decrement),
        .credit_in(credit_val_bus),
        .credit_out(current_credit)
    );
    
    // ------------------------------------------------------------------------
    // Control FSM (MCU Control Unit / Firmware)
    // ------------------------------------------------------------------------
    
    control_fsm control_unit (
        .clk(clk),
        .reset(reset),
        
        // Inputs from GPIO
        .coin_10_detected(coin_10_sync),
        .coin_20_detected(coin_20_sync),
        .coin_50_detected(coin_50_sync),
        .select_detected(select_sync),
        .item_id(item_id_sync),
        
        // Feedback from datapath
        .current_credit(current_credit),
        
        // Control signals to datapath
        .credit_enable(credit_enable),
        .credit_load(credit_load),
        .credit_decrement(credit_decrement),
        .credit_value(credit_val_bus),
        
        // External outputs
        .dispense(dispense),
        .return_change(return_change),
        
        // Debug output
        .state_out(state_debug)
    );

endmodule
