`timescale 1ns / 1ps

module ShiftRegTestBench();

localparam N = 8, DEFAULT_BIT = 1'b1, period = 20;


wire outputBit;

reg clk, load, shift, reset;
reg[N-1:0] Din;

// Oscillate the clock
always 
begin
    clk = 1'b1;
    #period;
    
    clk = 1'b0;
    #period;
end

// Instantiate Register
ShiftRegister #(.WIDTH(N), .DEFAULT_BIT(DEFAULT_BIT)) UUT
(
    .clk(clk),
    .Din(Din),
    .load(load),
    .shift(shift),
    .reset(reset),
    .outputBit(outputBit)
);


initial
begin
    #(period / 4);
    
    reset = 1;
    #(period * 2);
    reset = 0;
    
    // Test the default bit is correct
    if (outputBit != DEFAULT_BIT)
        $display("Output bit not set to correct default");
        
    // Load in data
    Din = 8'b10101110;
    
    load = 1;
    #(period * 2);
    load = 0;
    
    if (outputBit != 0)
        $display("Data not loaded properly");
        
    // Shift data
    shift = 1;
    #(period * 2);
    shift = 0;
      
    if (outputBit != 1)
        $display("Data not shifting properly");
        
    // Reset
    reset = 1;
    #period;
    reset = 0;
    
    if (outputBit != DEFAULT_BIT)
        $display("Reset yain't work");
        
    $stop;
end

endmodule
