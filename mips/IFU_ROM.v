// Verified: 2024-08-27
`timescale 1ns / 1ps

`default_nettype none
module IFU_ROM(
    input wire [31:0] A,
    output wire [31:0] D
    );
    
    // IM容量为16KiB
    // 4096 × 32bit
    reg [31:0] ROM [4095:0];
    
    // 指令的地址从0x00003000开始，需要减去
    // 指令为32bit即4byte，地址后两位是无效的
    // 4096 = 2^12，故取转换后的地址的13:2位
    wire [31:0] ROM_real_address;
    wire [11:0] ROM_address;
    assign ROM_real_address = A - 32'h3000;
    assign ROM_address = ROM_real_address[13:2];
    
    assign D = ROM[ROM_address];
    
    // 测评要求，使用系统任务读入到ROM中
    initial begin
        $readmemh("code.txt", ROM, 0);
    end  
    
endmodule
