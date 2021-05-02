`timescale 1ns / 1ps

/**
 * Detects edges in a clock signal. The DETECT_POSEDGE param determines
 * whether or not this detects positive or negative edges.
 */

module EdgeDetector
#(
    // 1 = positive edge detector, 0 = negative edge detector
    parameter DETECT_POSEDGE = 1'b1
)
(
    input clk,          // System clock
    input signal,       // Signal to edge detect
    output isEdge       // Whether an edge was sensed
);


// Sample the previous signal value
reg prevValue;
always @(posedge clk) begin
    prevValue <= signal;
end


// Edge detection based on the DETECT_POSEDGE parameter
// and the current/prev value of the signal
assign isEdge = 
    DETECT_POSEDGE & ~prevValue & signal |
    ~DETECT_POSEDGE & prevValue & ~signal;

endmodule
