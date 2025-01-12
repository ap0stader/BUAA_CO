// Verified: 2024-08-27
`timescale 1ns / 1ps

`default_nettype none
module SPL(
    input wire [31:0] Instr,
    output wire [5:0] opcode,
    output wire [4:0] rs,
    output wire [4:0] rt,
    output wire [4:0] rd,
    output wire [4:0] shamt,
    output wire [5:0] funct,
    output wire [15:0] imm16,
    output wire [25:0] instr_index
    );
    
    assign opcode = Instr[31:26];
    
    assign rs = Instr[25:21];
    
    assign rt = Instr[20:16];
    
    assign rd = Instr[15:11];
    
    assign shamt = Instr[10:6];
    
    assign funct = Instr[5:0];
    
    assign imm16 = Instr[15:0];
    
    assign instr_index = Instr[25:0];

endmodule
