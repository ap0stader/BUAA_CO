// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none
module CTRL_Forward (
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

    output wire [2:0] FMUX_V1_D_Sel,
    output wire [2:0] FMUX_V2_D_Sel,
    output wire [1:0] FMUX_V1_E_Sel,
    output wire [1:0] FMUX_V2_E_Sel,
    output wire FMUX_V2_M_Sel
    );

    // rs

    wire rs_E_premise = SPL_rs != 5'd0 && 
                        GRFWE_E && 
                        SPL_rs == GRF_A3_E;

    wire rs_F51 = rs_E_premise &&
                  GRF_WD_W_Sel_E == 2'b00 &&
                  Tuse_rs == 2'd1;
    wire rs_F43 = rs_E_premise &&
                  GRF_WD_W_Sel_E == 2'b10 &&
                  Tuse_rs != 2'd3;
    wire rs_F44 = rs_E_premise &&
                  GRF_WD_W_Sel_E == 2'b11 &&
                  Tuse_rs != 2'd3;


    wire rs_M_premise = SPL_rs != 5'd0 && 
                        GRFWE_M && 
                        SPL_rs == GRF_A3_M &&
                        ~ rs_E_premise;

    wire rs_F32 = rs_M_premise &&
                  GRF_WD_W_Sel_M == 2'b01 &&
                  Tuse_rs == 2'd1;
    wire rs_F21 = rs_M_premise &&
                  GRF_WD_W_Sel_M == 2'b00 &&
                  Tuse_rs != 2'd3;
    wire rs_F23 = rs_M_premise &&
                  GRF_WD_W_Sel_M == 2'b10 &&
                  Tuse_rs != 2'd3;
    wire rs_F24 = rs_M_premise &&
                  GRF_WD_W_Sel_M == 2'b11 &&
                  Tuse_rs != 2'd3;


    assign FMUX_V1_D_Sel = (rs_F43) ? 3'b110 :
                           (rs_F44) ? 3'b111 :
                           (rs_F21) ? 3'b011 :
                           (rs_F23) ? 3'b100 :
                           (rs_F24) ? 3'b101 :
                           3'b000;
 
    assign FMUX_V1_E_Sel = (rs_F51) ? 2'b11 :
                           (rs_F32) ? 2'b10 :
                           2'b00;

    // rt

    wire rt_E_premise = SPL_rt != 5'd0 && 
                        GRFWE_E && 
                        SPL_rt == GRF_A3_E;

    wire rt_F62 = rt_E_premise &&
                  GRF_WD_W_Sel_E == 2'b01 &&
                  Tuse_rt == 2'd2;
    wire rt_F51 = rt_E_premise &&
                  GRF_WD_W_Sel_E == 2'b00 &&
                  (Tuse_rt == 2'd1 | Tuse_rt == 2'd2);
    wire rt_F43 = rt_E_premise &&
                  GRF_WD_W_Sel_E == 2'b10 &&
                  Tuse_rt != 2'd3;
    wire rt_F44 = rt_E_premise &&
                  GRF_WD_W_Sel_E == 2'b11 &&
                  Tuse_rt != 2'd3;


    wire rt_M_premise = SPL_rt != 5'd0 && 
                        GRFWE_M && 
                        SPL_rt == GRF_A3_M &&
                        ~ rt_E_premise;

    wire rt_F32 = rt_M_premise &&
                  GRF_WD_W_Sel_M == 2'b01 &&
                  (Tuse_rt == 2'd1 | Tuse_rt == 2'd2);
    wire rt_F21 = rt_M_premise &&
                  GRF_WD_W_Sel_M == 2'b00 &&
                  Tuse_rt != 2'd3;
    wire rt_F23 = rt_M_premise &&
                  GRF_WD_W_Sel_M == 2'b10 &&
                  Tuse_rt != 2'd3;
    wire rt_F24 = rt_M_premise &&
                  GRF_WD_W_Sel_M == 2'b11 &&
                  Tuse_rt != 2'd3;


    assign FMUX_V2_D_Sel = (rt_F43) ? 3'b110 :
                           (rt_F44) ? 3'b111 :
                           (rt_F21) ? 3'b011 :
                           (rt_F23) ? 3'b100 :
                           (rt_F24) ? 3'b101 :
                           3'b000;
 
    assign FMUX_V2_E_Sel = (rt_F51) ? 2'b11 :
                           (rt_F32) ? 2'b10 :
                           2'b00;

    assign FMUX_V2_M_Sel = rt_F62;

endmodule
