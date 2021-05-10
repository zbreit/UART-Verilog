`timescale 1ns / 1ps

/**
 * This is a parallel-in, serial-out Shift Register circuit
 * with a synchronous clock and an asynchronous reset. It also includes
 * a serial input.
 */
 
module ShiftRegister
#(
    parameter WIDTH = 12            // # of data bits
)
(
    input clk,                      // System clock
    input [WIDTH-1:0] Din,          // Input data
    input serialIn,                 // Serial input data
    input shift,                    // Whether to shift data (read in MSB, evict LSB)
    input load,                     // Whether to load input data into the register
    input reset,                    // Whether to reset all bits to 1s
    output outputBit,               // Output bit
    output reg[WIDTH-1:0] allData   // All the data currently in the shift register
);

// Sequential logic defined in the always
always @(posedge clk or posedge reset)
begin
    if (reset)
        // Asynchronous Reset
        allData <= {WIDTH{1'b1}};
    else if (load) 
        // Load parallel data
        allData <= Din;
    else if (shift)
        // Load MSB serially, evict the LSB
        allData <= {serialIn, allData[WIDTH-1:1]};
end

// Output bit = LSB
assign outputBit = allData[0]; 

endmodule
