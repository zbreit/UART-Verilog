`timescale 1ns / 1ps

/**
 * Outputs a slower clock signal at the frequency specified by the parameter
 */

module Timer
#(
    parameter INPUT_FREQ = 100e6, // 100 MHz
    parameter OUTPUT_FREQ = 300   // 300 Hz
)
(
    input systemClk,            // Input clock signal
    input reset,                // Reset signal
    output newClk               // Output clock signal
);

// Counter to slow down the system clock
localparam HALF_CYCLE_COUNT = (INPUT_FREQ / OUTPUT_FREQ) / 2;
ModNCounter #(HALF_CYCLE_COUNT) counter (
    .clk(systemClk),
    .increment(1),
    .reset(reset),
    .didReachN(newClk)
);

endmodule
