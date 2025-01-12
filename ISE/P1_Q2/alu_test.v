`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   08:42:44 10/11/2023
// Design Name:   alu
// Module Name:   /media/shared/ap0stader/Documents/SourceCode/CO_2023_Fall/2_P1/ISE/P1_Q2/alu_test.v
// Project Name:  P1_Q2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: alu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module alu_test;

	// Inputs
	reg [31:0] A;
	reg [31:0] B;
	reg [2:0] ALUOp;

	// Outputs
	wire [31:0] C;

	// Instantiate the Unit Under Test (UUT)
	alu uut (
		.A(A), 
		.B(B), 
		.ALUOp(ALUOp), 
		.C(C)
	);

	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		ALUOp = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        A = 32'b10111101101111011011110110111101;
        B = 32'd2;
        ALUOp = 3'b101;
        
        #2
        ALUOp = 3'b100;
        
        #2;
        ALUOp = 3'b111;
	end
      
endmodule

