`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:06:00 10/11/2023
// Design Name:   gray
// Module Name:   /media/shared/ap0stader/Documents/SourceCode/CO_2023_Fall/2_P1/ISE/P1_Q4/gray_test.v
// Project Name:  P1_Q4
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: gray
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module gray_test;

	// Inputs
	reg Clk;
	reg Reset;
	reg En;

	// Outputs
	wire [2:0] Output;
	wire Overflow;

	// Instantiate the Unit Under Test (UUT)
	gray uut (
		.Clk(Clk), 
		.Reset(Reset), 
		.En(En), 
		.Output(Output), 
		.Overflow(Overflow)
	);

	initial begin
		// Initialize Inputs
		Clk = 0;
		Reset = 0;
		En = 0;

		// Wait 100 ns for global reset to finish
        Reset = 1;
		#100;
        Reset = 0;
		// 第一次提交的问题：忘记了使能信号了
        En = 1;

		#10;
		En = 0;
		#10;
		En = 1;

		// Add stimulus here
        #28;
        Reset = 1;
        #4;
        Reset = 0;
	end
    
    always #2 begin
        Clk = ~Clk;
    end
      
endmodule

