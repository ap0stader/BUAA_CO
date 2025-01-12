`timescale 1ns / 1ps

module RUN_CPU;
	reg clk;
	reg reset;

	mips uut (
		.clk(clk), 
		.reset(reset)
	);

	initial begin
		clk = 1;
		reset = 1;

		// Wait 15 ns for global reset to finish
		#15;
        
        reset = 0;
	end
    
    always #5 begin
        clk = ~clk;
    end
      
endmodule

