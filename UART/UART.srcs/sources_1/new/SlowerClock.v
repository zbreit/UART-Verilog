`timescale 1ns / 1ps

/**
 * A clock that operates more slowly than the system clock
 */

module SlowerClock
#(
    parameter INPUT_FREQ = 500_000,        // System clock frequency
    parameter OUTPUT_FREQ = 300            // Desired output frequency
)
(
    input systemClk,
    input reset,
    output reg slowerClk
);

// Count an integer number of clock cycles to slow down the system clock
wire completedHalfCycle;
ModNCounter #(.N(INPUT_FREQ / OUTPUT_FREQ / 2), .WIDTH(16)) counter(
    .clk(systemClk),
    .reset(reset),
    .increment(1),
    .didReachN(completedHalfCycle)
);

always @(posedge completedHalfCycle or posedge reset) begin
    if (reset)
        // Reset clk to HIGH (to avoid unecessary posedges at the start)
        slowerClk <= 1;
    else
        // Invert the clock every time we count the number of system
        // clock cycles required for a half cycle of the slower clock
        slowerClk <= ~slowerClk;
end

endmodule
