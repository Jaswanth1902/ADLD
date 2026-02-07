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
    input wire coin_5,           // ₹5 coin sensor
    input wire coin_10,          // ₹10 coin sensor
    input wire select_item,      // Item selection button
    
    // External outputs (GPIO pins / actuators)
    output wire dispense,        // Item dispense actuator
    output wire return_change,   // Change return actuator
    output wire [7:0] current_credit,  // Credit display (7-segment driver)
    output wire [2:0] state_debug      // Current FSM state (for debugging)
);

    // ========================================================================
    // Internal Signal Declarations
    // ========================================================================
    // These represent the interconnections between MCU internal modules
    
    // Synchronized pulses from I/O interface to FSM
    wire coin_5_sync, coin_10_sync, select_sync;
    
    // Control signals from FSM to credit register (control path)
    wire credit_enable, credit_load, credit_decrement;
    wire [7:0] credit_add_value;
    
    // ========================================================================
    // Module Instantiations (Microcontroller Components)
    // ========================================================================
    
    // ------------------------------------------------------------------------
    // I/O Interface (GPIO Peripheral)
    // ------------------------------------------------------------------------
    // Handles input conditioning and synchronization
    
    io_interface gpio_peripheral (
        .clk(clk),
        .reset(reset),
        
        // Raw external inputs
        .coin_5_raw(coin_5),
        .coin_10_raw(coin_10),
        .select_raw(select_item),
        
        // Synchronized single-cycle pulses
        .coin_5_pulse(coin_5_sync),
        .coin_10_pulse(coin_10_sync),
        .select_pulse(select_sync)
    );
    
    // ------------------------------------------------------------------------
    // Credit Register (Internal RAM/Register)
    // ------------------------------------------------------------------------
    // Stores accumulated credit value
    
    credit_register credit_storage (
        .clk(clk),
        .reset(reset),
        .enable(credit_enable),
        .load(credit_load),
        .decrement(credit_decrement),
        .credit_in(credit_add_value),
        .credit_out(current_credit)
    );
    
    // ------------------------------------------------------------------------
    // Control FSM (MCU Control Unit / Firmware)
    // ------------------------------------------------------------------------
    // Main control logic implementing vending machine state machine
    
    control_fsm control_unit (
        .clk(clk),
        .reset(reset),
        
        // Inputs from GPIO
        .coin_5_detected(coin_5_sync),
        .coin_10_detected(coin_10_sync),
        .select_detected(select_sync),
        
        // Feedback from datapath
        .current_credit(current_credit),
        
        // Control signals to datapath
        .credit_enable(credit_enable),
        .credit_load(credit_load),
        .credit_decrement(credit_decrement),
        .credit_value(credit_add_value),
        
        // External outputs
        .dispense(dispense),
        .return_change(return_change),
        
        // Debug output
        .state_out(state_debug)
    );

endmodule
