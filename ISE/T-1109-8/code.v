`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:22:03 08/26/2023 
// Design Name: 
// Module Name:    code 
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
module code(
    input Clk,
    input Reset,
    input Slt,
    input En,
    output reg [63:0] Output0,
    output reg [63:0] Output1
    );

    reg [1:0] Counter_Output1;
    
    initial begin
        Output0 <= 64'b0;
        Output1 <= 64'b0;
        Counter_Output1 <= 2'b0;
    end

    always @(posedge Clk) begin
        if (Reset) begin
            Output0 <= 64'b0;
            Output1 <= 64'b0;
            Counter_Output1 <= 2'b0;
        end
        else begin
            if(En) begin
                if(Slt) begin
                    if(Counter_Output1 == 2'd3) begin
                        Counter_Output1 <= 2'b0;
                        Output1 <= Output1 + 1;
                    end
                    else begin
                        Counter_Output1 <= Counter_Output1 + 1;
                    end
                end
                else begin
                    Output0 <= Output0 + 1;
                end
            end
        end

    end
    
endmodule
