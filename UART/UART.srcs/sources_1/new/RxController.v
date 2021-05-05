`timescale 1ns / 1ps

/**
 * Finite State Machine for controlling the Rx module
 */
 
module RxController(
    input clk,                  // System clock
    input reset,                // Whether to reset the FSM
    input Din,                  // Serial input from Tx
    input nextBit,              // Slower clock signal indicating when to read bits
    input readAllData,          // Whether all transmission data was read in
    input parityMatch,          // Whether the parity bit matches the parity of the data
    output reg resetTimer,      // Whether to reset the timer
    output reg resetCounter,    // Whether to reset the bit counter
    output reg busy,            // Whether the receiver is currently processing a transmission
    output reg readBit,         // Whether to read another bit from Din
    output reg increment,       // Whether to increment the bit counter
    output reg publishData,     // Whether to output the data in the shift register
    output reg receivedNewMsg,  // Whether a new transmission was successfully received
    output reg error            // Whether the transmission data has an error
);

// Define valid states
reg[2:0] state, nextState;
localparam
    LISTENING = 3'b000,
    LOADING = 3'b001,
    COUNT = 3'b010,
    READING = 3'b011,
    PARITY_CHECK = 3'b100,
    SUCCEEDED = 3'b101,
    ERROR = 3'b110;
    
// Setup negative edge detector for the next bit clock/
// This allows us to sample in the middle of the transmission bit
wire nextBitNegEdge;
EdgeDetector #(.DETECT_POSEDGE(1'b0)) negEdgeDetector(
    .clk(clk),
    .signal(nextBit),
    .isEdge(nextBitNegEdge)
);
    
// Combinational Next State Logic
always @(*) begin
    // Default state and outputs
    nextState = state;
    resetTimer = 0;
    resetCounter = 0;
    busy = 0;
    readBit = 0;
    error = 0;
    increment = 0;
    receivedNewMsg = 0;
    publishData = 0;
    
    // Next state logic
    case(state)
        LISTENING: begin
            // ~Din corresponds to the start bit for a transmission
            if (~Din) nextState = LOADING;
        end
        
        LOADING: begin
            nextState = COUNT;
            resetTimer = 1;
            resetCounter = 1;
            busy = 1;
        end
        
        COUNT: begin
            // Sample at the middle of the sample
            if (nextBitNegEdge) nextState = READING;
            busy = 1;
        end
        
        READING: begin
            // Re-enter COUNT state if there's more data to read.
            // Otherwise, check parity
            nextState = (readAllData) ? PARITY_CHECK : COUNT;
            
            // Read in data serially
            busy = 1;
            readBit = 1;
            increment = 1;
        end
        
        PARITY_CHECK: begin
            // Go back to the beginning if the parity matches
            // or to an error state otherwise.
            if (parityMatch) nextState = SUCCEEDED;
            else nextState = ERROR;
            
            busy = 1;
            publishData = 1;
        end
        
        SUCCEEDED: begin
            nextState = LISTENING;
            receivedNewMsg = 1;
        end
        
        ERROR: begin
            // Stay in the eror state indefinitely (until a reset)
            error = 1;
        end    
    endcase
end

// Advance state on every clock cycle or when the circuit is reset
always @(posedge clk or posedge reset) begin
    state <= (reset) ? LISTENING : nextState;
end
endmodule
