`timescale 1ns / 1ps

/**
 * A clock that operates more slowly than the system clock
 */

module SlowerClock
#(
    parameter inputFreq = 100e6,    // System clock frequency
    parameter outputFreq = 300      // Desired output frequency
)
(
    input systemClk,
    input reset,
    output reg slowerClk
);

// Count an integer number of clock cycles to slow down the system clock
wire completedHalfCycle;
ModNCounter #(.N(inputFreq / outputFreq / 2)) counter(
    .clk(systemClk),
    .reset(reset),
    .increment(1),
    .didReachN(completedHalfCycle)
);

always @(posedge completedHalfCycle or posedge reset) begin
    if (reset)
        slowerClk <= 0;             // Reset clk to LOW
    else
        // Invert the clock every time we count the number of system
        // clock cycles required for a half cycle of the slower clock
        slowerClk <= ~slowerClk;
end

endmodule
