`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:05:14 10/06/2023 
// Design Name: 
// Module Name:    FloatType 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`default_nettype none

`define T1 5'b00001
`define T2 5'b00010
`define T3 5'b00100
`define T4 5'b01000
`define T5 5'b10000

module FloatType(
    input wire [31:0] num,
    output reg [4:0] float_type
    );
		
	wire [7:0]exponent;
	wire [22:0] fraction;
	
	assign exponent[7:0] = num[30:23];
	assign fraction[22:0] = num[22:0];
	
	always @(*) begin 
		if (exponent == 8'b11111111) begin
			if (fraction == 22'b0) begin
				float_type = `T4;
			end
			else begin
				float_type = `T5;
			end
		end
		else if (exponent == 8'b00000000) begin
			if (fraction == 22'b0) begin
				float_type = `T1;
			end
			else begin
				float_type = `T3;
			end
		end
		else begin
			float_type = `T2;
		end
	end
endmodule
