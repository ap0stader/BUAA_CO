// Verified: 2024-08-28
`timescale 1ns / 1ps

`default_nettype none
module IFU_NPC(
    input wire [31:0] PC,
    input wire [1:0] NPCSel,
    input wire BranchComp,
    input wire [15:0] offset,
    input wire [25:0] instr_index,
    input wire [31:0] instr_register,
    output wire [31:0] NPC
    );
    
    wire [31:0] normal;
    wire [31:0] branch;
    wire [31:0] j_and_jal;
    wire [31:0] jr_and_jalr;
    
    assign normal = PC + 32'h00000004;
    
    assign branch = BranchComp ? PC + {{14{offset[15]}}, offset, 2'b00} : 
                                 normal;
    
    assign j_and_jal = {PC[31:28], instr_index, 2'b00};
    
    assign jr_and_jalr = instr_register;
    
    assign NPC = (NPCSel == 2'b00) ? normal : 
                 (NPCSel == 2'b01) ? branch :
                 (NPCSel == 2'b10) ? j_and_jal :
                 (NPCSel == 2'b11) ? jr_and_jalr :
                 32'h00003000;

endmodule
