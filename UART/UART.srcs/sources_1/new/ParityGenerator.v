`timescale 1ns / 1ps

/**
 * Calculates the parity of input data. 
 * If useOddParity = 1, parityBit checks if there are an odd # of ones
 * If useOddParity = 0, parityBit checks if there are an even # of ones
 */

module ParityGenerator
#(
    parameter WIDTH = 8
)
(
    input [WIDTH - 1:0] Din,      // Input data
    input useOddParity,           // 1 = odd parity, 0 = odd parity
    output parityBit              // Parity of the input data
);
    
// Output parity = Odd parity of input data if 
assign parityBit = (^ Din) ^ (useOddParity);

endmodule
