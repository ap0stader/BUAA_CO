// Verified: 2024-08-28
`timescale 1ns / 1ps

`default_nettype none
module CTRL_Stall (
    input wire [1:0] Tuse_rs,
    input wire [1:0] Tuse_rt,
    input wire [4:0] SPL_rs,
    input wire [4:0] SPL_rt,
    input wire GRFWE_E,
    input wire GRFWE_M,
    input wire [1:0] GRF_WD_W_Sel_E,
    input wire [1:0] GRF_WD_W_Sel_M,
    input wire [4:0] GRF_A3_E,
    input wire [4:0] GRF_A3_M,
    input wire ISMULTDIV,
    input wire MULT_Start,
    input wire MULT_Busy,

    output wire IFU_EN_N,
    output wire FR_D_EN_N,
    output wire FR_E_RESET
    );

    // rs

    wire rs_E_premise = SPL_rs != 5'd0 && 
                        GRFWE_E && 
                        SPL_rs == GRF_A3_E;

    wire rs_S1 = GRF_WD_W_Sel_E == 2'b00 &&
                 Tuse_rs == 2'd0;

    wire rs_S2 = GRF_WD_W_Sel_E == 2'b01 &&
                 Tuse_rs == 2'd0;

    wire rs_S4 = GRF_WD_W_Sel_E == 2'b01 &&
                 Tuse_rs == 2'd1;


    wire rs_M_premise = SPL_rs != 5'd0 && 
                        GRFWE_M &&
                        SPL_rs == GRF_A3_M &&
                        ~ rs_E_premise;

    wire rs_S3 = GRF_WD_W_Sel_M == 2'b01 &&
                 Tuse_rs == 2'd0;

    wire rs_S = (rs_E_premise &
                    (rs_S1 | rs_S2 | rs_S4)) |
                (rs_M_premise &
                    (rs_S3));

    // rt
    
    wire rt_E_premise = SPL_rt != 5'd0 && 
                        GRFWE_E && 
                        SPL_rt == GRF_A3_E;

    wire rt_S1 = GRF_WD_W_Sel_E == 2'b00 &&
                 Tuse_rt == 2'd0;

    wire rt_S2 = GRF_WD_W_Sel_E == 2'b01 &&
                 Tuse_rt == 2'd0;

    wire rt_S4 = GRF_WD_W_Sel_E == 2'b01 &&
                 Tuse_rt == 2'd1;


    wire rt_M_premise = SPL_rt != 5'd0 && 
                        GRFWE_M &&
                        SPL_rt == GRF_A3_M &&
                        ~ rt_E_premise;

    wire rt_S3 = GRF_WD_W_Sel_M == 2'b01 &&
                 Tuse_rt == 2'd0;

    wire rt_S = (rt_E_premise &
                    (rt_S1 | rt_S2 | rt_S4)) |
                (rt_M_premise &
                    (rt_S3));

    // MULTDIV

    wire SMULTDIV = ISMULTDIV & (MULT_Start | MULT_Busy);

    // S
    
    wire S = rs_S | rt_S | SMULTDIV;

    assign IFU_EN_N   = S;

    assign FR_D_EN_N  = S;

    assign FR_E_RESET = S;

endmodule
