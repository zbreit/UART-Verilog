`timescale 1us / 1ps

module TxTestBench();
    // System clock
    reg clk;
    always begin
        #1 clk <= 1;
        #1 clk <= 0;
    end
    
    // Module parameters
    localparam WIDTH = 8;
    reg reset, send, useOddParity;
    reg[WIDTH - 1:0] Din;
    wire busy, Dout;
    
    // Instantiate Module
    Tx #(.WIDTH(WIDTH)) UUT (
        .clk(clk),
        .reset(reset),
        .Din(Din),
        .send(send),
        .useOddParity(useOddParity),
        .busy(busy),
        .Dout(Dout)
    );
    
    // Test inputs and outputs
    localparam 
        delayPerBit = 1_000_000 / 300,
        inputData = 8'b1010_0111;
    
    // Note: Data should stream out in LSB -> MSB order
    localparam
        expectedOutputOddParity = 12'b0_1110_0101_0_11,
        expectedOutputEvenParity = 12'b0_1110_0101_1_11;
        
    // Assemble an array of expected outputs
    wire[11:0] expectedOutput[1:0];
    assign expectedOutput[0] = expectedOutputEvenParity;
    assign expectedOutput[1] = expectedOutputOddParity;
    
    // Create a reg to store observed output
    reg[11:0] observedOutput;
    
    // Control signals
    initial begin    
        // Reset signal
        #1 reset = 1;
        #1 reset = 0;
        
        // Send the input message using both parity values
        for (integer parity = 0; parity < 2; parity = parity + 1) begin
            // Add separation between separate tests
            #(delayPerBit);
        
            $display("\nUsing %s parity for input %b", 
                parity ? "odd" : "even",
                inputData);
        
            // Transmit input data using current parity value
            useOddParity = parity;
            Din = inputData;
            send = 1;
            
            // Sample in the middle of each bit, ensuring the correct output
            for(integer i = 11; i >= 0; i = i - 1) begin
                #(delayPerBit / 2);
                observedOutput[i] = Dout;
            
                // Indicate on the trace when these samples are being taken
                // (displays as a negative pulse)
                #10 send = 0;
                #10 send = 1;
                #((delayPerBit / 2) - 20);
            end
            
            $display("Expected:\t %b", expectedOutput[parity]);
            $display("Observed:\t %b", observedOutput);
            
            if (expectedOutput[parity] == observedOutput)
                $display("PASSED :)");
            else
                $display("FAILED :(");
                
            // Stop sending data
            send = 0;
        end
    end
endmodule
