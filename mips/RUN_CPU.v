`timescale 1ns / 1ps

module RUN_CPU;

	// Inputs
	reg clk;
	reg reset;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk(clk), 
		.reset(reset)
	);

	initial begin
		// Initialize Inputs
		clk = 1;
		reset = 1;

		// Wait 100 ns for global reset to finish
		#18;
        
		// Add stimulus here
        reset = 0;
	end
    
    always #5 begin
        clk = ~clk;
    end
      
endmodule

