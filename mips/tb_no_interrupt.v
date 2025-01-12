`timescale 1ns/1ps

module mips_tb_no_interrupt;

	reg clk;
	reg reset;
	reg interrupt;

	wire [31:0] macroscopic_pc;

	wire [31:0] i_inst_addr;
	wire [31:0] i_inst_rdata;

	wire [31:0] m_data_addr;
	wire [31:0] m_data_rdata;
	wire [31:0] m_data_wdata;
	wire [3 :0] m_data_byteen;

	wire [31:0] m_int_addr;
	wire [3 :0] m_int_byteen;

	wire [31:0] m_inst_addr;

	wire		w_grf_we;
	wire [4 :0] w_grf_addr;
	wire [31:0] w_grf_wdata;

	wire [31:0] w_inst_addr;

	mips uut(
		.clk(clk),
		.reset(reset),
		.interrupt(interrupt),
		.macroscopic_pc(macroscopic_pc),

		.i_inst_addr(i_inst_addr),
		.i_inst_rdata(i_inst_rdata),

		.m_data_addr(m_data_addr),
		.m_data_rdata(m_data_rdata),
		.m_data_wdata(m_data_wdata),
		.m_data_byteen(m_data_byteen),

		.m_int_addr(m_int_addr),
		.m_int_byteen(m_int_byteen),

		.m_inst_addr(m_inst_addr),

		.w_grf_we(w_grf_we),
		.w_grf_addr(w_grf_addr),
		.w_grf_wdata(w_grf_wdata),

		.w_inst_addr(w_inst_addr)
	);

	initial begin
		clk <= 0;
		reset <= 1;
		interrupt <= 0;
		#20 reset <= 0;
	end

	integer i;
	reg [31:0] fixed_addr;
	reg [31:0] fixed_wdata;
	reg [31:0] data[0:4095];
	reg [31:0] inst[0:5119];

	// ----------- For Instructions -----------

	// 这里模5120可以使部分超出范围的地址仍然能够正常取出数据，部分超出范围的地址会取出异常值
	// 感觉模4096会更好
	// 这里移位是将按字节读取和按半字读取的操作权给到DM模块
	assign m_data_rdata = data[(m_data_addr >> 2) % 5120];
	// 通过模5120并且移位可以使PC没有字对齐或者超出范围时仍然能够正常取出指令
	// 并且取出的指令不一定是nop
	assign i_inst_rdata = inst[((i_inst_addr - 32'h3000) >> 2) % 5120];

	initial begin
		$readmemh("code.txt", inst);
		$readmemh("handle.txt", inst, 1120);
		for (i = 0; i < 5120; i = i + 1) data[i] <= 0;
	end

	// ----------- For Data Memory -----------

	always @(*) begin
		fixed_wdata = data[(m_data_addr >> 2) & 4095];
		fixed_addr = m_data_addr & 32'hfffffffc;
		if (m_data_byteen[3]) fixed_wdata[31:24] = m_data_wdata[31:24];
		if (m_data_byteen[2]) fixed_wdata[23:16] = m_data_wdata[23:16];
		if (m_data_byteen[1]) fixed_wdata[15: 8] = m_data_wdata[15: 8];
		if (m_data_byteen[0]) fixed_wdata[7 : 0] = m_data_wdata[7 : 0];
	end

	always @(posedge clk) begin
		if (reset) for (i = 0; i < 4096; i = i + 1) data[i] <= 0;
		else if (|m_data_byteen && fixed_addr >> 2 < 4096) begin
			data[fixed_addr >> 2] <= fixed_wdata;
			$display("%d@%h: *%h <= %h", $time, m_inst_addr, fixed_addr, fixed_wdata);
		end
	end

	// ----------- For Registers -----------

	always @(posedge clk) begin
		if (~reset) begin
			if (w_grf_we && (w_grf_addr != 0)) begin
				$display("%d@%h: $%d <= %h", $time, w_inst_addr, w_grf_addr, w_grf_wdata);
			end
		end
	end

	always #2 clk <= ~clk;

endmodule
