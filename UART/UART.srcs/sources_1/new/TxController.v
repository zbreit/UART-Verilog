`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2021 09:35:29 AM
// Design Name: 
// Module Name: TxController
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TxController(
    input clk,                  // System clock
    input reset,                // Whether to reset the controller
    input startSending,         // Whether to start transmitting data
    input nextBit,              // Whether to transmit the next bit
    input sentAllData,          // Whether the all N bits of data were sent
    output reg busy,            // Whether the transmitter is currently sending data
    output reg load,            // Whether to load input data into the shift register
    output reg shift,           // Whether to shift the output data by 1
    output reg resetCounter,    // Whether to reset the counter to 0
    output reg resetTimer,      // Whether to reset the timer to LOW
    output reg increment        // Whether to increment the counter
);

// Posedge detector for the nextBit clock signal
wire nextBitEdge;
EdgeDetector #(.DETECT_POSEDGE(1'b1)) posedgeDetector(
    .clk(clk),
    .signal(nextBit),
    .isEdge(nextBitEdge)
);
    
// State encodings
reg [2:0] state, nextState;
localparam 
    IDLE = 3'b000, 
    LOADING = 3'b001,
    COUNT = 3'b010,
    SHIFT = 3'b011,
    WAIT = 3'b100;
    
// Compute next state and output logic (purely combinational)
always @(*) begin
    // Default next state and outputs
    nextState = state;
    load = 0;
    shift = 0;
    busy = 0;
    increment = 0;
    resetCounter = 0;
    resetTimer = 0;

    // Next state logic
    case(state)
        IDLE: begin
            if (startSending) nextState = LOADING;
        end
        
        LOADING: begin
            nextState = COUNT;
            load = 1;
            busy = 1;
            resetCounter = 1;
            resetTimer = 1;
        end
        
        COUNT: begin
            if (nextBitEdge) nextState = SHIFT;
            busy = 1;
        end
        
        SHIFT: begin
            nextState = (sentAllData) ? WAIT : COUNT;
            busy = 1;
            shift = 1;
            increment = 1;
        end
        
        WAIT: begin
            if (~startSending) nextState = IDLE;
        end
    endcase
end

// Advance state on every clock cycle
always @(posedge clk or posedge reset) begin
    state <= (reset) ? IDLE : nextState;
end

endmodule
