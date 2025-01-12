`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:39:44 08/26/2023 
// Design Name: 
// Module Name:    id_fsm 
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
`define S0 2'd0
`define S1 2'd1
`define S2 2'd2

module id_fsm(
    input [7:0] char,
    input clk,
    output out
    );

    parameter L_lowerletter = 8'd97;
    parameter R_lowerletter = 8'd122;
    parameter L_upperletter = 8'd65;
    parameter R_upperletter = 8'd90;
    parameter L_digit = 8'd48;
    parameter R_digit = 8'd57;

    reg [1:0] status;

    initial begin
        status <= `S0;
    end

    always @(posedge clk) begin
        case (status)
            `S0 : begin
                if ((char >= L_upperletter & char <= R_upperletter) | 
                    (char >= L_lowerletter & char <= R_lowerletter)) begin
                        status <= `S1;
                    end
                    else begin
                        status <= `S0;
                    end
            end
            `S1 : begin
                if ((char >= L_upperletter & char <= R_upperletter) | 
                    (char >= L_lowerletter & char <= R_lowerletter)) begin
                        status <= `S1;
                    end
                    else if(char >= L_digit & char <= R_digit) begin
                        status <= `S2;
                    end
                    else begin
                        status <= `S0;
                    end
            end
            `S2 : begin
                if ((char >= L_upperletter & char <= R_upperletter) | 
                    (char >= L_lowerletter & char <= R_lowerletter)) begin
                        status <= `S1;
                    end
                    else if(char >= L_digit & char <= R_digit) begin
                        status <= `S2;
                    end
                    else begin
                        status <= `S0;
                    end
            end
        endcase
    end

    assign out = (status == `S2) ? 1 : 0;
	
endmodule
