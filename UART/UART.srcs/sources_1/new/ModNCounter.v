`timescale 1ns / 1ps

/**
 * Synchronous Mod N counter with an asynchronous reset.
 */

module ModNCounter
#(
  parameter N = 4'd12,                      // Counter will go from 0 to N - 1
  parameter WIDTH = 4                       // How many bits are needed to store the count (WIDTH >= 2**N)
)
(
    input clk,                               // Clock
    input increment,                         // Whether to add 1 to the current count
    input reset,                             // Whether to reset the count to 0
    output didReachN                         // Whether the count is about to roll over to 0
);

// Current count (it is 31 bits wide, since this counter supports 32-bit numbers)
reg[WIDTH-1:0] currentCount;
wire atLargestVal = currentCount == N-1;

always @(posedge clk or posedge reset) 
begin
    if (reset) 
        currentCount <= 0; // Reset count to 0
    else if (increment)
        // Increment by 1, looping back to 0 if we reach N
        currentCount <= (atLargestVal)
            ? 0
            : currentCount + 1;
end

// The counter looped around if the current count is N - 1 and we're about to increment
assign didReachN = atLargestVal & increment;

endmodule
