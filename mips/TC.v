// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none

// 模式定义
`define IDLE 2'b00
`define LOAD 2'b01
`define CNT  2'b10
`define INT  2'b11

// 偏移值 名称    描述       读写性
// 0h    CTRL   控制寄存器   R/W
// 4h    PRESET 初值寄存器   R/W
// 8h    COUNT  计数值寄存器 R
`define ctrl   mem[0]
`define preset mem[1]
`define count  mem[2]

module TC(
	input wire RESET,
    input wire clk,
    input wire [3:0] byteen,
	input wire [31:0] addr,
    input wire [31:0] wdata,
    output wire [31:0] rdata,
    output wire IRQ
    );

	// 输入信息处理
	// CTRL的高28位没有实际意义，通过28'h0抹去wdata中的无效位
	wire [31:0] load = addr[3:2] == 0 ? {28'h0, wdata[3:0]} : wdata;
	// 将byteen信号转换为WE
	wire WE = & byteen;

	// 状态标识
	reg [1:0] state;
	// TC内部的寄存器
	reg [31:0] mem [2:0];
	
	reg _IRQ;
	// IM位，中断屏蔽位，决定是否产生中断
	assign IRQ = `ctrl[3] & _IRQ;
	
	// 输出信息
	assign rdata = mem[addr[3:2]];
	
	integer i;
	always @(posedge clk) begin
		if(RESET) begin
			// 复位
			state <= 0; 
			for(i = 0; i < 3; i = i+1) mem[i] <= 0;
			_IRQ <= 0;
		end
		else if(WE) begin
			// 写入
			// 使用STORE类指令修改TC寄存器值的优先级高于TC自修改
			mem[addr[3:2]] <= load;
		end
		else begin
			case(state)
				// Enable位，计数器使能位
				`IDLE : if(`ctrl[0]) begin
					state <= `LOAD;
					_IRQ <= 1'b0;
				end
				`LOAD : begin
					`count <= `preset;
					state <= `CNT;
				end
				`CNT  : 
					if(`ctrl[0]) begin
						if(`count > 1) `count <= `count-1;
						else begin
							`count <= 0;
							state <= `INT;
							_IRQ <= 1'b1;
						end
					end
					// 当计数器计数时，若计数器使能被store类指令修改为0则停止计数
					else state <= `IDLE;
				default : begin
					// 模式0：计数器停止计数，此时控制寄存器中的使能Enable自动变为0。
					if(`ctrl[2:1] == 2'b00) `ctrl[0] <= 1'b0;
					// 模式1：当计数器倒计数为0后，初值寄存器值被自动加载至计数器，计数器继续倒计时
					// 模式1下计数器每次计数循环中只产生一周期的中断信号，然后进入IDLE状态，还要过两个周期才能开始下一轮计时
					else _IRQ <= 1'b0;
					state <= `IDLE;
				end
			endcase
		end
	end

	// 第一周期，IDLE，停止中断
	// 第二周期，LOAD，加载初值
	// 第三周期，CNT，开始计数

endmodule
