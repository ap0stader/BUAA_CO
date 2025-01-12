`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:23:14 10/06/2023
// Design Name:   intcheck
// Module Name:   /media/shared/ap0stader/Documents/SourceCode/CO_2023_Fall/1_P0/question_1109_336/intcheck_test.v
// Project Name:  question_1109_336
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: intcheck
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module intcheck_test;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] in;

	// Outputs
	wire out;
    // debug
    // wire [4:0] status_output;

	// Instantiate the Unit Under Test (UUT)
	intcheck uut (
		.clk(clk), 
		.reset(reset), 
		.in(in), 
        // debug
        // .status_output(status_output), 
		.out(out)
	);
	
	always #1 begin
		clk = ~clk;
	end
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		in = 0;

		// Wait 100 ns for global reset to finish
		#100;
        reset = 0;
        
		// Add stimulus here
		in = "i";
		#2 in = "n";
		#2 in = "t";
		#2 in = " ";
		#2 in = " ";
		#2 in = "A";
		#2 in = ";";
		#2 in = "i";
		#2 in = "n";
		#2 in = "t";
		#2 in = " ";
		#2 in = "b";
		#2 in = "_";
		#2 in = "1";
		#2 in = ",";
		#2 in = "c";
		#2 in = ";";
		#2 in = " ";
		#2 in = "i";
		#2 in = "n";
		#2 in = "t";
		#2 in = " ";
		#2 in = "i";
		#2 in = ",";
		#2 in = "i";
		#2 in = "n";
		#2 in = ",";
		#2 in = "i";
		#2 in = "n";
		#2 in = "t";
		#2 in = "d";
		#2 in = ";";
		#2 in = "i";
		#2 in = "n";
		#2 in = "t";
		#2 in = " ";
		#2 in = "e";
		#2 in = "[";
		#2 in = "2";
		#2 in = "]";
		#2 in = ";";
		#2 in = ";";
		#2 in = "i";
		#2 in = "n";
		#2 in = "t";
		#2 in = " ";
		#2 in = "f";
		#2 in = ",";
		#2 in = "i";
		#2 in = "n";
		#2 in = "t";
		#2 in = ",";
		#2 in = "g";
		#2 in = ";";
		#2 in = "i";
		
	end
      
endmodule

