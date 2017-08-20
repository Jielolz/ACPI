`timescale 1ns / 10ps

module acpi_5_5(clk, rst, bayer_addr, bayer_req, bayer_ready, bayer_data, acpi_addr, acpi_valid, acpi_data, finish);

parameter DATA_WIDTH = 8;
parameter ADDRESS = 14;
parameter MIRROR = 15;

input 					clk;
input 					rst;
output [ADDRESS-1:0]   	bayer_addr;
output 				   	bayer_req;
input 				   	bayer_ready;
input [DATA_WIDTH-1:0] 	bayer_data;
output [ADDRESS-1:0]   	acpi_addr;
output 					acpi_valid;
output [DATA_WIDTH-1:0] acpi_data;
output 					finish;

// state 

parameter STATE_ZERO = 3'd0;
parameter STATE_ONE = 3'd1;
parameter STATE_TWO = 3'd2;
parameter STATE_THREE = 3'd3;
parameter STATE_FOUR = 3'd4;
parameter STATE_FIVE = 3'd5;

reg [ADDRESS-1:0] 	 bayer_addr;
reg 				 bayer_req;
reg [ADDRESS-1:0] 	 acpi_addr, next_acpi_addr;
reg 				 acpi_valid;
reg [DATA_WIDTH-1:0] acpi_data, next_acpi_data;
reg 				 finish;

// 25 temp registers

reg [7:0] bayer_central, bayer_pixal_1, bayer_pixal_2, bayer_pixal_3, bayer_pixal_4;
reg [7:0] bayer_pixal_5, bayer_pixal_6, bayer_pixal_7, bayer_pixal_8, bayer_pixal_9;
reg [7:0] bayer_pixal_10, bayer_pixal_11, bayer_pixal_12, bayer_pixal_13, bayer_pixal_14;
reg [7:0] bayer_pixal_15, bayer_pixal_16, bayer_pixal_17, bayer_pixal_18, bayer_pixal_19;
reg [7:0] bayer_pixal_20, bayer_pixal_21, bayer_pixal_22, bayer_pixal_23, bayer_pixal_24;

reg [2:0] state, next_state;
reg [4:0] entries_filled;

// FSM , counter

always @(posedge clk or posedge rst) begin
	if(rst)
		state <= STATE_ZERO;
	else
		state <= next_state;
end

always @(*) begin
	case(state)
		STATE_ZERO: begin // 3'd0
			if(entries_filled == 5'd24)
				next_state = STATE_ONE; //3'd1
			else
				next_state = STATE_ZERO; // 3'd0
		end
		STATE_ONE: begin // 3'd1
			next_state = STATE_TWO; // 3'd2
		end
		STATE_TWO: begin // 3'd2
			next_state = STATE_THREE; // 3'd3
		end
		STATE_THREE: begin // 3'd3
			next_state = STATE_FOUR; // 3'd4
		end
		STATE_FOUR: begin // 3'd4
			next_state = STATE_ZERO; // 3'd0
		end
		STATE_FIVE: begin // 3'd5
			next_state = STATE_FIVE; // 3'd5
		end
		default: next_state = STATE_FIVE; // 3'd5
	endcase
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_req <= 1'b0;
	end
	else begin
		if(bayer_ready) begin
			bayer_req <= 1'b1;
		end
		else begin
			bayer_req <= 1'b0;
		end
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		entries_filled <= 5'd0;
	end
	else if(bayer_ready) begin
		if(entries_filled == 5'd24) begin
			if(bayer_addr[6] & bayer_addr[5] & bayer_addr[4] & bayer_addr[3] & bayer_addr[2] & bayer_addr[1] & bayer_addr[0])
				entries_filled <= 5'd0;
			else
				entries_filled <= 5'd20;
		end
		else begin
			entries_filled <= entries_filled + 5'd1;
		end
	end
	else begin
		entries_filled <= entries_filled;
	end
end

//////////////////////////////////////////
//          change row (not ok)         //
//////////////////////////////////////////
//      How to change to next row  ???  //
//////////////////////////////////////////
always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_addr <= 14'd258;
	end
	else if(bayer_ready) begin
		if(entries_filled == 5'd0) begin
			if(bayer_addr[6] & bayer_addr[5] & bayer_addr[4] & bayer_addr[3] & bayer_addr[2] & bayer_addr[1] & bayer_addr[0]) begin
				bayer_addr <= bayer_addr - 14'd263;
			end
			else
				bayer_addr <= bayer_addr - 14'd130; //14'd128
		end
		else if(entries_filled == 5'd1) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd0
		end
		else if(entries_filled == 5'd2) begin
			bayer_addr <= bayer_addr + 14'd512; //14'd512
		end
		else if(entries_filled == 5'd3) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd384
		end
		else if(entries_filled == 5'd4) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd256
		end
		else if(entries_filled == 5'd5) begin
			bayer_addr <= bayer_addr - 14'd127; //14'd129 
		end
		else if(entries_filled == 5'd6) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd1
		end
		else if(entries_filled == 5'd7) begin
			bayer_addr <= bayer_addr + 14'd512; //14'd513
		end
		else if(entries_filled == 5'd8) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd385
		end
		else if(entries_filled == 5'd9) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd257
		end
		else if(entries_filled == 5'd10) begin
			bayer_addr <= bayer_addr - 14'd127; //14'd130
		end
		else if(entries_filled == 5'd11) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd2
		end
		else if(entries_filled == 5'd12) begin
			bayer_addr <= bayer_addr + 14'd512; //14'd514
		end
		else if(entries_filled == 5'd13) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd386
		end 
		else if(entries_filled == 5'd14) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd258
		end
		else if(entries_filled == 5'd15) begin
			bayer_addr <= bayer_addr - 14'd127; //14'd131
		end
		else if(entries_filled == 5'd16) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd3
		end
		else if(entries_filled == 5'd17) begin
			bayer_addr <= bayer_addr + 14'd512; //14'd515
		end
		else if(entries_filled == 5'd18) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd387
		end
		else if(entries_filled == 5'd19) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd259
		end
		else if(entries_filled == 5'd20) begin
			bayer_addr <= bayer_addr - 14'd127; //14'd132
		end
		else if(entries_filled == 5'd21) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd4
		end
		else if(entries_filled == 5'd22) begin
			bayer_addr <= bayer_addr + 14'd512; //14'd516
		end
		else if(entries_filled == 5'd23) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd388
		end
		else if(entries_filled == 5'd24) begin
			bayer_addr <= bayer_addr - 14'd128; //14'd260
		end
	end
	else begin
		bayer_addr <= bayer_addr;
	end
end
/*
always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_addr <= 15'd267;
	end
	else if(bayer_ready) begin
		if(entries_filled == 5'd0) begin
			if(bayer_addr[6] & bayer_addr[5] & bayer_addr[4] & bayer_addr[3] & bayer_addr[2] & bayer_addr[1] & bayer_addr[0]) begin
				bayer_addr <= bayer_addr - 15'd263;
			end
			else
				bayer_addr <= bayer_addr - 15'd267; //15'd0
		end
		else if(entries_filled == 5'd1) begin
			bayer_addr <= bayer_addr + 15'd528; //15'd528
		end
		else if(entries_filled == 5'd2) begin
			bayer_addr <= bayer_addr - 15'd396; //15'd132
		end
		else if(entries_filled == 5'd3) begin
			bayer_addr <= bayer_addr + 15'd264; //15'd396
		end
		else if(entries_filled == 5'd4) begin
			bayer_addr <= bayer_addr - 15'd132; //15'd264
		end
		else if(entries_filled == 5'd5) begin
			bayer_addr <= bayer_addr - 15'd263; //15'd1 
		end
		else if(entries_filled == 5'd6) begin
			bayer_addr <= bayer_addr + 15'd528; //15'd529
		end
		else if(entries_filled == 5'd7) begin
			bayer_addr <= bayer_addr - 15'd396; //15'd133
		end
		else if(entries_filled == 5'd8) begin
			bayer_addr <= bayer_addr + 15'd264; //15'd397
		end
		else if(entries_filled == 5'd9) begin
			bayer_addr <= bayer_addr - 15'd132; //15'd265
		end
		else if(entries_filled == 5'd10) begin
			bayer_addr <= bayer_addr - 15'd263; //15'd2
		end
		else if(entries_filled == 5'd11) begin
			bayer_addr <= bayer_addr + 15'd528; //15'd530
		end
		else if(entries_filled == 5'd12) begin
			bayer_addr <= bayer_addr - 15'd396; //15'd134
		end
		else if(entries_filled == 5'd13) begin
			bayer_addr <= bayer_addr + 15'd264; //15'd398
		end 
		else if(entries_filled == 5'd14) begin
			bayer_addr <= bayer_addr - 15'd132; // 15'd266
		end
		else if(entries_filled == 5'd15) begin
			bayer_addr <= bayer_addr - 15'd263; // 15'd3
		end
		else if(entries_filled == 5'd16) begin
			bayer_addr <= bayer_addr + 15'd528; // 15'd531
		end
		else if(entries_filled == 5'd17) begin
			bayer_addr <= bayer_addr - 15'd396; // 15'd135
		end
		else if(entries_filled == 5'd18) begin
			bayer_addr <= bayer_addr + 15'd264; // 15'd399
		end
		else if(entries_filled == 5'd19) begin
			bayer_addr <= bayer_addr - 15'd132; // 15'd267
		end
		else if(entries_filled == 5'd20) begin
			bayer_addr <= bayer_addr - 15'd263; // 15'd4
		end
		else if(entries_filled == 5'd21) begin
			bayer_addr <= bayer_addr + 15'd528; // 15'd532
		end
		else if(entries_filled == 5'd22) begin
			bayer_addr <= bayer_addr - 15'd396; // 15'd136
		end
		else if(entries_filled == 5'd23) begin
			bayer_addr <= bayer_addr + 15'd264; // 15'd400
		end
		else if(entries_filled == 5'd24) begin
			bayer_addr <= bayer_addr - 15'd132; // 15'd268
		end
	end
	else begin
		bayer_addr <= bayer_addr;
	end
end
*/
always @(posedge clk or posedge rst) begin
	if(rst) begin
		acpi_addr <= 14'd259;
	end
	else begin
		acpi_addr <= next_acpi_addr;
	end
end

always @(*) begin
	if(acpi_valid) begin
		if(acpi_addr[6] & acpi_addr[5] & acpi_addr[4] & acpi_addr[3] & acpi_addr[2] & acpi_addr[0]) begin
			next_acpi_addr = acpi_addr + 5;
		end
		else if(acpi_addr[6] & acpi_addr[5] & acpi_addr[4] & acpi_addr[3] & acpi_addr[2]) begin
			next_acpi_addr = acpi_addr + 6;
		end
		else begin
		 	next_acpi_addr = acpi_addr + 2;
		end
	end
	else begin
		next_acpi_addr = acpi_addr;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		acpi_valid <= 1'b0;
	end
	else if(state == STATE_FOUR) begin
		acpi_valid <= 1'b1;
	end
	else begin
		acpi_valid <= 1'b0;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		finish <= 1'b0;
	end
	else begin
		if(acpi_addr == 16382)
			finish <= 1'd1;
		else
			finish <= 1'd0;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		acpi_data <= 8'd0;
	end
	else begin
		acpi_data <= next_acpi_data;
	end
end

// change 5*5 pixal array

always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_central = 8'd0; 
		bayer_pixal_1 = 8'd0; 
		bayer_pixal_2 = 8'd0; 
		bayer_pixal_3 = 8'd0; 
		bayer_pixal_4 = 8'd0;
		bayer_pixal_5 = 8'd0; 
		bayer_pixal_6 = 8'd0; 
		bayer_pixal_7 = 8'd0; 
		bayer_pixal_8 = 8'd0; 
		bayer_pixal_9 = 8'd0;
		bayer_pixal_10 = 8'd0; 
		bayer_pixal_11 = 8'd0; 
		bayer_pixal_12 = 8'd0; 
		bayer_pixal_13 = 8'd0; 
		bayer_pixal_14 = 8'd0;
		bayer_pixal_15 = 8'd0; 
		bayer_pixal_16 = 8'd0; 
		bayer_pixal_17 = 8'd0; 
		bayer_pixal_18 = 8'd0; 
		bayer_pixal_19 = 8'd0;
		bayer_pixal_20 = 8'd0; 
		bayer_pixal_21 = 8'd0; 
		bayer_pixal_22 = 8'd0; 
		bayer_pixal_23 = 8'd0; 
		bayer_pixal_24 = 8'd0; 
		/*
		bayer_central = 10'd0; 
		bayer_pixal_1 = 10'd0; 
		bayer_pixal_2 = 10'd0; 
		bayer_pixal_3 = 10'd0; 
		bayer_pixal_4 = 10'd0;
		bayer_pixal_5 = 10'd0; 
		bayer_pixal_6 = 10'd0; 
		bayer_pixal_7 = 10'd0; 
		bayer_pixal_8 = 10'd0; 
		bayer_pixal_9 = 10'd0;
		bayer_pixal_10 = 10'd0; 
		bayer_pixal_11 = 10'd0; 
		bayer_pixal_12 = 10'd0; 
		bayer_pixal_13 = 10'd0; 
		bayer_pixal_14 = 10'd0;
		bayer_pixal_15 = 10'd0; 
		bayer_pixal_16 = 10'd0; 
		bayer_pixal_17 = 10'd0; 
		bayer_pixal_18 = 10'd0; 
		bayer_pixal_19 = 10'd0;
		bayer_pixal_20 = 10'd0; 
		bayer_pixal_21 = 10'd0; 
		bayer_pixal_22 = 10'd0; 
		bayer_pixal_23 = 10'd0; 
		bayer_pixal_24 = 10'd0;
		*/  
	end
	else begin
		bayer_central = bayer_pixal_9;
		bayer_pixal_1 = bayer_pixal_20;
		bayer_pixal_2 = bayer_pixal_21;
		bayer_pixal_3 = bayer_pixal_22;
		bayer_pixal_4 = bayer_pixal_23;
		bayer_pixal_5 = bayer_pixal_24;
		bayer_pixal_6 = bayer_pixal_1;
		bayer_pixal_7 = bayer_pixal_2;
		bayer_pixal_8 = bayer_pixal_3;
		bayer_pixal_9 = bayer_pixal_4;
		bayer_pixal_10 = bayer_pixal_5;
		bayer_pixal_11 = bayer_pixal_7;
		bayer_pixal_12 = bayer_pixal_8;
		bayer_pixal_13 = bayer_pixal_10;
		bayer_pixal_14 = bayer_data;
		bayer_pixal_15 = bayer_pixal_11;
		bayer_pixal_16 = bayer_pixal_12;
		bayer_pixal_17 = bayer_central;
		bayer_pixal_18 = bayer_pixal_13;
		bayer_pixal_19 = bayer_pixal_14;
		bayer_pixal_20 = bayer_pixal_15;
		bayer_pixal_21 = bayer_pixal_16;
		bayer_pixal_22 = bayer_pixal_17;
		bayer_pixal_23 = bayer_pixal_18;
		bayer_pixal_24 = bayer_pixal_19;
	end
end

// acpi calculation
/*
always@(*) begin
	if() begin
		next_apci_data = 
	end
	else if() begin
	
	end
	else begin

	end
end
*/
endmodule