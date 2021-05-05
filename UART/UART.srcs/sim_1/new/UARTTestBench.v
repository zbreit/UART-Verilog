`timescale 1us / 1ps

/**
 * Integration test for UART Tx and Rx modules
 *
 * This test ensures that a multi-byte message sent 
 * with Tx is read correctly by Rx.
 */
 
module UARTTestBench();
// System clock
reg clk;
always begin
    #1 clk <= 1;
    #1 clk <= 0;
end

// Module parameters
localparam 
    WIDTH = 8,
    TOTAL_MSG_SIZE = 12,
    delayPerBit = 1_000_000 / 300;

// Common signals
wire serialLine; // Wire between Tx and Rx (output of Tx, input of Tx)
reg reset, useOddParity;

// Instantiate Rx
reg reset, useOddParity;
wire busyRx, error, receivedNewMsg;
wire[WIDTH-1:0] Dout;
Rx #(.WIDTH(WIDTH)) receiver (
    .clk(clk),
    .reset(reset),
    .Din(serialLine),
    .useOddParity(useOddParity),
    .busy(busyRx),
    .Dout(Dout),
    .error(error),
    .receivedNewMsg(receivedNewMsg)
);

// Instaniate Tx
reg send;
reg[WIDTH - 1:0] Din;
wire busyTx, Dout;
Tx #(.WIDTH(WIDTH)) transmitter (
    .clk(clk),
    .reset(reset),
    .Din(Din),
    .send(send),
    .useOddParity(useOddParity),
    .busy(busyTx),
    .Dout(serialLine)
);

// We want to send the message 0xdead beef 1337
// It will send them in 8-bit chunks: de ad be ef 13 37
wire[7:0] message[5:0];
assign message[5] = 8'hde;
assign message[4] = 8'had;
assign message[3] = 8'hbe;
assign message[2] = 8'hef;
assign message[1] = 8'h13;
assign message[0] = 8'h37;

initial begin
    // Setup initial signals
    #1 reset = 1;
    #1 reset = 0;
    useOddParity = 1;
    
    // Send over message all 6 bytes of the message
    for(integer byte = 5; byte >= 0; byte = byte - 1) begin
        Din = message[byte];
        #10 send = 1;
        #10 send = 0;
        
        // Wait for full message to transmit (13 bits)
        #(delayPerBit * (TOTAL_MSG_SIZE + 1));
        
        // Make sure output is correct
        if (Dout != Din) begin
            $display("Received %h instead of %h", Dout, Din);
            $stop;
        end
        else begin
            $display("Correctly received %h", Dout);
        end
    end
    
    $display("Successfully received the message!");
end

endmodule
