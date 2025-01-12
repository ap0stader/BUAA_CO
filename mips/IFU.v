// Verified: 2024-08-27
`timescale 1ns / 1ps

`default_nettype none
module IFU(
    input wire RESET,
    input wire clk,
    input wire [1:0] NPCSel,
    input wire BranchComp,
    input wire [15:0] offset,
    input wire [25:0] instr_index,
    input wire [31:0] instr_register,
    output wire [31:0] Instr,
    output wire [31:0] PC
    );
    
    wire [31:0] NPC_NPC;
  
    IFU_PC PC_instance(.RESET(RESET),
                       .clk(clk),
                       .D(NPC_NPC),
                       .Q(PC));
    
    IFU_NPC NPC_instance(.PC(PC),
                         .NPCSel(NPCSel),
                         .BranchComp(BranchComp),
                         .offset(offset),
                         .instr_index(instr_index),
                         .instr_register(instr_register),
                         .NPC(NPC_NPC));
                
    IFU_ROM ROM_instance(.A(PC),
                         .D(Instr));

endmodule
