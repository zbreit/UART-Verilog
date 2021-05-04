`timescale 1us / 1ps

module RxTestBench();
    // System clock
    reg clk;
    always begin
        #1 clk <= 1;
        #1 clk <= 0;
    end
    
    // Module parameters
    localparam WIDTH = 8;
    
    // Module inputs/outputs
    reg reset, useOddParity;
    reg Din;
    wire busy, error;
    wire[WIDTH-1:0] Dout;
    
    // Instantiate Module
    Rx #(.WIDTH(WIDTH)) UUT (
        .clk(clk),
        .reset(reset),
        .Din(Din),
        .useOddParity(useOddParity),
        .busy(busy),
        .Dout(Dout),
        .error(error)
    );
    
    // Test inputs and outputs
    localparam 
        delayPerBit = 1_000_000 / 300,
        expectedOutput = 8'b1010_0111,
        inputOddParity = 12'b0_1110_0101_0_11,
        inputEvenParity = 12'b0_1110_0101_1_11;
    wire[11:0] testInputs[1:0];
    assign testInputs[0] = inputEvenParity;
    assign testInputs[1] = inputOddParity;
    
    // Control signals
    initial begin        
        // Send the input message using both parity values
        for (integer parity = 0; parity < 2; parity = parity + 1) begin
            // Transmit input data using current parity value
            #1 reset = 1;
            #1 reset = 0;
            useOddParity = parity;
            
            $display("\nUsing %s parity for input %b", 
                parity ? "odd" : "even",
                testInputs[parity]);
            
            // Change the input signal every time the clock is supposed to go
            // high
            for(integer i = 11; i >= 0; i = i - 1) begin
                Din = testInputs[parity][i];
                #delayPerBit;
            end
            
            // Assert correct state (wait for a small amount of time
            // before measuring output signals)
            #(delayPerBit / 2);
            $display("Busy (should = 0):\t %b", busy);
            $display("Error (should = 0):\t %b", error);
            $display("Expected:\t %b", expectedOutput);
            $display("Observed:\t %b", Dout);
            
            if (expectedOutput == Dout & ~busy & ~error) 
                $display("PASSED :)");
            else 
                $display("FAILED :(");
            
            // Add separation between separate tests
            #(delayPerBit * 3);
        end
    
        // Transmit input data using even parity
        $display("\nTesting the error state");
        #1 reset = 1;
        #1 reset = 0;
        useOddParity = 1'b0;
        
        // Send in odd parity input data
        for(integer i = 11; i >= 0; i = i - 1) begin
            Din = inputOddParity[i];
            #delayPerBit;
        end
        
        // Ensure that we reach an error        
        if (error == 1'b1) $display("Entered an error state: PASSED :)");
        else $display("Didn't enter an error state: FAILED :(");
    end
endmodule
