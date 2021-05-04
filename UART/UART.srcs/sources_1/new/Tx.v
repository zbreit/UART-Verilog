`timescale 1ns / 1ps

/**
 * This is a UART transmitter circuit that takes in parallel data
 * and outputs a serialized version of that data. Parity and other
 * control bits are also output.
 */
 
module Tx
#(
    parameter 
        WIDTH = 4'd8,           // Parameter for number of data bits (default = 8)
        NUM_STOP_BITS = 4'd2,   // Number of stop bits
        NUM_START_BITS = 4'd1,  // Number of start bits
        PARAM_SIZE = 4          // Size of the parameters (used to reduced counter size)
)
(
    input clk,                  
    input reset,
    input[WIDTH-1:0] Din,       // Parallel input data
    input send,                 // Whether or not the circuit should start sending data
    input useOddParity,         // Whether the parity should be even or odd (1 = odd, 0 = even)
    output busy,                // Whether the circuit is currently transmitting data
    output Dout                 // Serial output data
);
// Derived parameter values
localparam 
    TOTAL_SIZE = NUM_START_BITS + NUM_STOP_BITS + WIDTH + 1; // Add 1 for parity bit

// Create intermediate signals for the FSM inputs/outputs
wire load, 
    shift, 
    resetCounter, 
    resetTimer, 
    increment, 
    nextBit, 
    sentAllData;

// Calculate parity
wire parityBit = (^ Din) ^ (useOddParity);

// Pack the message in reverse order
wire[TOTAL_SIZE-1:0] transmission = { 
    {NUM_STOP_BITS{1'b1}}, 
    parityBit, 
    Din, 
    {NUM_START_BITS{1'b0}} 
 };
    
// Load data into the shift register
ShiftRegister  #(.WIDTH(WIDTH + 4)) shiftReg (
    .clk(clk),
    .reset(reset),
    .serialIn(1),
    .shift(shift),
    .load(load),
    .Din(transmission),
    .outputBit(Dout)
);

// Instantiate the 300 Hz timer for the Baud rate
SlowerClock slowClk (
    .systemClk(clk),
    .reset(resetTimer),
    .slowerClk(nextBit)
);

// Create a counter for the number of bits that have been transmitted
ModNCounter #(.N(TOTAL_SIZE), .WIDTH(PARAM_SIZE)) dataCounter (
    .clk(clk),
    .increment(increment),
    .reset(resetCounter),
    .didReachN(sentAllData)
);

// Create the controller
TxController transmitterFSM (
    .clk(clk),
    .reset(reset),
    .startSending(send),
    .nextBit(nextBit),
    .sentAllData(sentAllData),
    .busy(busy),
    .load(load),
    .shift(shift),
    .resetCounter(resetCounter),
    .resetTimer(resetTimer),
    .increment(increment)
);
endmodule
