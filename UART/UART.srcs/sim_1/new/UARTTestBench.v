`timescale 1us / 1ps

// Integration test for UART Tx and Rx modules

module UARTTestBench();
// Module parameters
localparam WIDTH = 8;

// Configure the message
wire[WIDTH-1:0] message[5:0] = "Amogus";

initial begin
    for (integer i = 0; i < 6; i = i + 1) begin
        $display(message[1]);
    end
end

endmodule
