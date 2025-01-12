// Verified: 2024-08-27
`timescale 1ns / 1ps

`default_nettype none
module mips(
    input wire clk,
    input wire reset
    );
    
    // CTRL Ouput
    // NPC
    wire [1:0] CTRL_NPCSel;
    // GRF
    wire CTRL_GRFWE;
    wire [1:0] CTRL_GRFA3MUX;
    wire [1:0] CTRL_GRFWDMUX;
    // ALU
    wire [1:0] CTRL_OPSel;
    wire [2:0] CTRL_FuncSel;
    wire [2:0] CTRL_CompSel;
    wire CTRL_ALUrtMUX;
    // EXT
    wire [1:0] CTRL_EXTSel;
    // DM
    wire CTRL_DMWE;
    wire [2:0] CTRL_DMSel;

    // IFU Output
    wire [31:0] IFU_Instr;
    wire [31:0] IFU_PC;
    
    // SPL Output
    wire [5:0] SPL_opcode;
    wire [4:0] SPL_rs;
    wire [4:0] SPL_rt;
    wire [4:0] SPL_rd;
    wire [4:0] SPL_shamt;
    wire [5:0] SPL_funct;
    wire [15:0] SPL_imm16;
    wire [25:0] SPL_instr_index;

    // GRF Output
    wire [31:0] GRF_RD1;
    wire [31:0] GRF_RD2;

    // ALU Output
    wire [31:0] ALU_OP;
    wire ALU_Comp;

    // EXT Output
    wire [31:0] EXT_EXT;

    // DM Output
    wire [31:0] DM_D_read;
    

    CTRL CTRL_instance (.opcode(SPL_opcode),
                        .funct(SPL_funct),
                        .rt(SPL_rt),
                        .OPSel(CTRL_OPSel),
                        .EXTSel(CTRL_EXTSel),
                        .DMSel(CTRL_DMSel),
                        .NPCSel(CTRL_NPCSel),
                        .FuncSel(CTRL_FuncSel),
                        .CompSel(CTRL_CompSel),
                        .GRFWE(CTRL_GRFWE),
                        .DMWE(CTRL_DMWE),
                        .GRFA3MUX(CTRL_GRFA3MUX),
                        .GRFWDMUX(CTRL_GRFWDMUX),
                        .ALUrtMUX(CTRL_ALUrtMUX)
    );


    IFU IFU_instance (.RESET(reset),
                      .clk(clk),
                      .NPCSel(CTRL_NPCSel),
                      .BranchComp(ALU_Comp),
                      .offset(SPL_imm16),
                      .instr_index(SPL_instr_index),
                      .instr_register(GRF_RD1),
                      .Instr(IFU_Instr),
                      .PC(IFU_PC)
    );
    
    
    SPL SPL_instance (.Instr(IFU_Instr),
                      .opcode(SPL_opcode),
                      .rs(SPL_rs),
                      .rt(SPL_rt),
                      .rd(SPL_rd),
                      .shamt(SPL_shamt),
                      .funct(SPL_funct),
                      .imm16(SPL_imm16),
                      .instr_index(SPL_instr_index)
    );
    
    
    wire [4:0] GRFA3MUX;
    assign GRFA3MUX = (CTRL_GRFA3MUX == 2'b00) ? 5'd0 :
                      (CTRL_GRFA3MUX == 2'b01) ? SPL_rd :
                      (CTRL_GRFA3MUX == 2'b10) ? SPL_rt :
                      5'd31; // CTRL_GRFA3MUX == 2'b11

    wire [31:0] GRFWDMUX;
    assign GRFWDMUX = (CTRL_GRFWDMUX == 2'b00) ? ALU_OP :
                      (CTRL_GRFWDMUX == 2'b01) ? EXT_EXT :
                      (CTRL_GRFWDMUX == 2'b10) ? DM_D_read :
                      IFU_PC + 32'h00000004; // CTRL_GRFWDMUX == 2'b11
    
    GRF GRF_instance (.RESET(reset),
                      .clk(clk),
                      .WE(CTRL_GRFWE),
                      .A1(SPL_rs),
                      .A2(SPL_rt),
                      .A3(GRFA3MUX),
                      .WD(GRFWDMUX),
                      .RD1(GRF_RD1),
                      .RD2(GRF_RD2),
                      .PC(IFU_PC)
    );
    
    
    wire [31:0] ALUrtMUX;
    assign ALUrtMUX = (CTRL_ALUrtMUX == 1'b0) ? GRF_RD2 :
                      EXT_EXT; // CTRL_ALUrtMUX == 1'b1

    ALU ALU_instance (.OPSel(CTRL_OPSel),
                      .FuncSel(CTRL_FuncSel),
                      .CompSel(CTRL_CompSel),
                      .rs(GRF_RD1),
                      .rt(ALUrtMUX),
                      .shamt(SPL_shamt),
                      .OP(ALU_OP),
                      .Comp(ALU_Comp)
    );
    
    
    EXT EXT_instance (.EXTSel(CTRL_EXTSel),
                      .imm16(SPL_imm16),
                      .EXT(EXT_EXT)
    );


    DM DM_instance (.RESET(reset),
                    .clk(clk),
                    .WE(CTRL_DMWE),
                    .DMSel(CTRL_DMSel),
                    .A(ALU_OP),
                    .D_write(GRF_RD2),
                    .D_read(DM_D_read),
                    .PC(IFU_PC)
    );

endmodule
