`timescale 1ns / 1ps

/**
 * This is a UART receiver circuit that takes in serial data
 * sent by a UART transmitter (Tx) and outputs that data in a parallel
 * format. If any control or parity bits in the transmission are missing, 
 * the circuit will display an error.
 */
 
module Rx
#(
    parameter 
        WIDTH = 4'd8,          // Number of data bits
        NUM_START_BITS = 4'd1, // Number of start bits
        NUM_STOP_BITS = 4'd2,  // Number of start bits
        PARAM_SIZE = 4         // Size of the parameters (used to reduced counter size)
)
(
    input clk,              // System clock
    input reset,            // Whether to reset the Rx module
    input Din,              // Serial input data from the Tx
    input useOddParity,     // Whether the parity should be even or odd (1 = odd, 0 = even)
    output[WIDTH-1:0] Dout, // Parallel output data from the Tx
    output busy,            // Whether the module is currently reading a transmission
    output error            // Whether there was a transmission error (i.e., parity mismatch)
);
// Derived parameter values
localparam 
    TOTAL_SIZE = NUM_START_BITS + NUM_STOP_BITS + WIDTH + 1; // Add 1 for parity bit

// Create intermediate inputs/outputs for the FSM
wire 
    nextBit,
    readAllData,
    resetTimer, 
    resetCounter, 
    readBit, 
    parityMatch,
    increment,
    outputBit;

// Raw output from the shift register
wire[TOTAL_SIZE-1:0] shiftData;

// Extract all of the data bits from the register
assign Dout = shiftData[WIDTH:NUM_START_BITS];

// Check that the parity from the transmission matches the expected value
wire expectedParity = shiftData[TOTAL_SIZE - NUM_STOP_BITS - 1];
wire observedParity = (^ Dout) ^ (useOddParity);
assign parityMatch = expectedParity == observedParity;

// Load data into the shift register
ShiftRegister  #(.WIDTH(TOTAL_SIZE)) shiftReg (
    .clk(clk),
    .reset(reset),
    .serialIn(Din),
    .shift(readBit),
    .allData(shiftData),
    .Din({TOTAL_SIZE{1'b0}}),   // Unused by Rx
    .outputBit(outputBit)       // Unused by Rx
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
    .didReachN(readAllData)
);

// Create the controller
RxController receiverFSM (
    .clk(clk),
    .reset(reset),
    .Din(Din),
    .nextBit(nextBit),
    .readAllData(readAllData),
    .parityMatch(parityMatch),
    .busy(busy),
    .resetCounter(resetCounter),
    .resetTimer(resetTimer),
    .readBit(readBit),
    .increment(increment),
    .error(error)
);

endmodule
