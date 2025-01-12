`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:17:18 10/11/2023
// Design Name:   BlockChecker
// Module Name:   /media/shared/ap0stader/Documents/SourceCode/CO_2023_Fall/2_P1/ISE/P1_BlockChecker/BlockChecker_test.v
// Project Name:  P1_BlockChecker
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: BlockChecker
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module BlockChecker_test;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] in;

	// Outputs
	wire result;

	// Instantiate the Unit Under Test (UUT)
	BlockChecker uut (
		.clk(clk), 
		.reset(reset), 
		.in(in), 
		.result(result)
	);

	initial begin
		clk = 0;
		reset = 1;
		in = "a";
		#2;
        reset = 0;
        
        #10; in=" ";
		#10; in="B";
		#10; in="E";
		#10; in="g";
		#10; in="I";
		#10; in="n";
		#10; in=" ";
		#10; in="E";
		#10; in="n";
		#10; in="d";
		#10; in="c";
		#10; in=" ";
		#10; in="e";
		#10; in="n";
		#10; in="d";
		#10; in=" ";
        #10; in="e";
		#10; in="n";
		#10; in="d";
		#10; in=" ";
		#10; in="b";
		#10; in="E";
		#10; in="G";
		#10; in="i";
		#10; in="n";
		#10; in=" ";
        
        reset = 1;
		in = "a";
		#2;
        reset = 0;
        
        #10; in=" ";
		#10; in="B";
		#10; in="E";
		#10; in="g";
		#10; in="I";
		#10; in="n";
		#10; in=" ";
		#10; in="E";
		#10; in="n";
		#10; in="d";
		#10; in="c";
		#10; in=" ";
		#10; in="e";
		#10; in="n";
		#10; in="d";
		#10; in=" ";
        #10; in="e";
		#10; in="n";
		#10; in="d";
		#10; in=" ";
		#10; in="b";
		#10; in="E";
		#10; in="G";
		#10; in="i";
		#10; in="n";
		#10; in=" ";
	end
    
    always #5 begin
        clk = ~clk;
    end
      
endmodule

