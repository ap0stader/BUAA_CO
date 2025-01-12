// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none

`define nop 32'h0000_0000

module SPL(
    input wire [31:0] Instr,
    
    input wire force_nop,

    output wire [5:0] O_opcode,
    output wire [5:0] O_funct,
    output wire [4:0] O_rs,
    output wire [4:0] O_rt,
    
    output wire [4:0] rs,
    output wire [4:0] rt,
    output wire [4:0] rd,
    output wire [4:0] shamt, 
    output wire [15:0] imm16,
    output wire [25:0] instr_index
    );

    wire [31:0] After_Instr = force_nop ? `nop : Instr;


    assign O_opcode = Instr[31:26];
    
    assign O_funct = Instr[5:0];

    assign O_rs = Instr[25:21];
    
    assign O_rt = Instr[20:16];


    assign rs = After_Instr[25:21];
    
    assign rt = After_Instr[20:16];
    
    assign rd = After_Instr[15:11];
    
    assign shamt = After_Instr[10:6];
    
    assign imm16 = After_Instr[15:0];
    
    assign instr_index = After_Instr[25:0];

endmodule
