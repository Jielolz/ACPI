`timescale 1ns / 10ps

module ACPI(clk, rst, bayer_addr, bayer_addr_1, bayer_mirror, bayer_mirror_one, bayer_req, bayer_ready, bayer_data, bayer_data_1, acpi_addr, acpi_valid, acpi_valid_1, acpi_data, finish);
/*
parameter DATA_WIDTH = 8;
parameter ADDRESS = 14;
parameter MIRROR = 15;
*/
input 		  clk;
input 		  rst;
output [13:0] bayer_addr;
output [13:0] bayer_addr_1;
output        bayer_mirror;
output        bayer_mirror_one;
output  	  bayer_req;
input 		  bayer_ready;
input [7:0]   bayer_data;
input [7:0]   bayer_data_1;
output [13:0] acpi_addr;
output        acpi_valid;
output        acpi_valid_1;
output [7:0]  acpi_data;
output 		  finish;

// state 

`define STATE_INPUT	 2'd0
`define STATE_CAL 	 2'd1
`define STATE_OUTPUT 2'd2
`define STATE_IDLE	 2'd3

`define STATE_1	3'd0
`define STATE_2 3'd1
`define STATE_3 3'd2
`define STATE_4	3'd3
`define STATE_5 3'd4
`define STATE_6 3'd5
`define STATE_7 3'd6

reg [13:0] bayer_addr;
reg [13:0] bayer_addr_1;
reg        bayer_mirror;
reg        bayer_mirror_one;
reg 	   bayer_req;
reg [2:0]  bayer_mode;
reg [13:0] acpi_addr, next_acpi_addr;
reg        acpi_valid;
reg        acpi_valid_1;
reg [7:0]  acpi_data, next_acpi_data;
reg 	   finish;

reg [7:0] bayer_store [0:127];

// 25 temp registers

reg signed [7:0] bayer_central, bayer_pixal_1, bayer_pixal_2, bayer_pixal_3, bayer_pixal_4;
reg signed [7:0] bayer_pixal_5, bayer_pixal_6, bayer_pixal_7, bayer_pixal_8, bayer_pixal_9;
reg signed [7:0] bayer_pixal_10, bayer_pixal_11, bayer_pixal_12, bayer_pixal_13, bayer_pixal_14;
reg signed [7:0] bayer_pixal_15, bayer_pixal_16, bayer_pixal_17, bayer_pixal_18, bayer_pixal_19;
reg signed [7:0] bayer_pixal_20, bayer_pixal_21, bayer_pixal_22, bayer_pixal_23, bayer_pixal_24;

reg signed [7:0] bayer_pixal_new_1, bayer_pixal_new_2, bayer_pixal_new_3;
reg signed [7:0] bayer_pixal_new_4, bayer_new_central, bayer_pixal_new_5;
reg signed [7:0] bayer_pixal_new_6, bayer_pixal_new_7, bayer_pixal_new_8;

reg signed [7:0] bayer_mirror_1, bayer_mirror_2, bayer_mirror_3;
reg signed [7:0] bayer_mirror_4, bayer_mirror_5, bayer_mirror_6;

reg [9:0] delta_h_1, delta_h_2, delta_v_1, delta_v_2;
reg [9:0] delta_h, delta_v;

reg [1:0] state_mirror, next_state_mirror, state, next_state;
reg [2:0] state_1, next_state_1;
reg [3:0] entries_filled, entries_filled_1;

integer i;
// FSM , counter

always @(posedge clk or posedge rst) begin
	if(rst)
		state <= `STATE_INPUT;
	else
		state <= next_state;
end

always @(posedge clk or posedge rst) begin
	if(rst)
		state_mirror <= `STATE_CAL;
	else
		state_mirror <= next_state_mirror;
end

//////////////////////////////////////////////////////
//////////////////////////////////////////
/*設定變換鏡射模式*/

always @(*) begin
	if(rst) begin
		bayer_mode = 3'd0;
	end
	else if(bayer_addr == 14'd0) begin
		bayer_mode = 3'd1;
	end
	else if(bayer_addr == 14'd3) begin
		bayer_mode = 3'd2;
	end
	//128
	else if(bayer_addr > 14'd127) begin
		if(~bayer_addr[0] & ~bayer_addr[1] & ~bayer_addr[2] & ~bayer_addr[3] & ~bayer_addr[4] & ~bayer_addr[5] & ~bayer_addr[6] && entries_filled_1 == 4'd7) begin
			bayer_mode = 3'd3;
		end
		else if(~bayer_addr[0] & ~bayer_addr[1] & ~bayer_addr[2] & ~bayer_addr[3] & ~bayer_addr[4] & ~bayer_addr[5] & ~bayer_addr[6] && entries_filled_1 == 4'd1) begin
			bayer_mode = 3'd3;
		end
		//129
		else if(bayer_addr[0] & ~bayer_addr[1] & ~bayer_addr[2] & ~bayer_addr[3] & ~bayer_addr[4] & ~bayer_addr[5] & ~bayer_addr[6] && entries_filled_1 == 4'd4) begin
			bayer_mode = 3'd4;
		end
		else if(bayer_addr[0] & ~bayer_addr[1] & ~bayer_addr[2] & ~bayer_addr[3] & ~bayer_addr[4] & ~bayer_addr[5] & ~bayer_addr[6] && entries_filled_1 == 4'd4) begin
			bayer_mode = 3'd4;
		end
		//130
		else if(~bayer_addr[0] & bayer_addr[1] & ~bayer_addr[2] & ~bayer_addr[3] & ~bayer_addr[4] & ~bayer_addr[5] & ~bayer_addr[6] && entries_filled_1 == 4'd7) begin
			bayer_mode = 3'd5;
		end
		else if(~bayer_addr[0] & bayer_addr[1] & ~bayer_addr[2] & ~bayer_addr[3] & ~bayer_addr[4] & ~bayer_addr[5] & ~bayer_addr[6] && entries_filled_1 == 4'd7) begin
			bayer_mode = 3'd5;
		end
		//131
		else if(bayer_addr[0] & bayer_addr[1] & ~bayer_addr[2] & ~bayer_addr[3] & ~bayer_addr[4] & ~bayer_addr[5] & ~bayer_addr[6] && entries_filled_1 == 4'd7) begin
			bayer_mode = 3'd6;
		end
		else if(bayer_addr[0] & bayer_addr[1] & ~bayer_addr[2] & ~bayer_addr[3] & ~bayer_addr[4] & ~bayer_addr[5] & ~bayer_addr[6] && entries_filled_1 == 4'd4) begin
			bayer_mode = 3'd6;
		end
	end
end
//////////////////////////////////////////

always @(posedge clk or posedge rst) begin
	if(rst)
		state_1 <= `STATE_1;
	else
		state_1 <= next_state_1;
end

always @(*) begin
	case(state_1)
		`STATE_1: begin
			if(entries_filled_1 == 4'd8)
				next_state_1 = `STATE_2;
			else
				next_state_1 = `STATE_1;
		end
		`STATE_2: begin
			next_state_1 = `STATE_3;
		end
		`STATE_3: begin
			if(next_acpi_addr[7] & ~next_acpi_addr[6] & ~next_acpi_addr[5] & ~next_acpi_addr[4] & ~next_acpi_addr[3] & ~next_acpi_addr[2] & ~next_acpi_addr[1] & ~next_acpi_addr[0] && state_1[1]) begin
				next_state_1 = `STATE_1;
				entries_filled_1 = 4'd7;
			end
			else begin
				next_state_1 = `STATE_4;
			end
		end
		`STATE_4: begin
			next_state_1 = `STATE_5;
		end
		`STATE_5: begin
			next_state_1 = `STATE_6;
		end
		`STATE_6: begin
			next_state_1 = `STATE_1;
		end
		`STATE_7: begin
			next_state_1 = `STATE_7;
		end
		default: next_state_1 = `STATE_7;
	endcase
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		entries_filled_1 <= 4'd0;
	end
	else if(bayer_ready) begin
		if(entries_filled_1 == 4'd8) begin
			if(bayer_addr[6] & bayer_addr[5] & bayer_addr[4] & bayer_addr[3] & bayer_addr[2] & bayer_addr[1] & bayer_addr[0])
				entries_filled_1 <= 4'd0;
			else
				entries_filled_1 <= 4'd3;
		end
		else begin
			entries_filled_1 <= entries_filled_1 + 4'd1;
		end	
	end 
	else begin
		entries_filled_1 <= entries_filled_1;		
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		acpi_valid_1 <= 1'b0;
	end
	else if(state_1 == `STATE_6) begin
		acpi_valid_1 <= 1'b1;
	end
	else if(next_acpi_addr[7] & ~next_acpi_addr[6] & ~next_acpi_addr[5] & ~next_acpi_addr[4] & ~next_acpi_addr[3] & ~next_acpi_addr[2] & ~next_acpi_addr[1] & ~next_acpi_addr[0] && state_1[1]) begin
		acpi_valid_1 <= 1'b1;
	end
	else begin
		acpi_valid_1 <= 1'b0;
	end
end
////////////////////////////////////////////////////////////////////////////////
always @(*) begin
	case(state) 
		`STATE_INPUT: begin // 00
			if(entries_filled == 4'd8)
				next_state = `STATE_CAL; // 01
			else
				next_state = `STATE_INPUT; // 00
		end
		`STATE_CAL: begin // 01
			next_state = `STATE_OUTPUT; // 10
		end
		`STATE_OUTPUT: begin // 10
			next_state = `STATE_INPUT; // 00
		end
		`STATE_IDLE: begin // 11
			next_state = `STATE_IDLE; // 11
		end
		default: next_state = `STATE_IDLE; // 11
	endcase
end

always @(*) begin
	case(state_mirror) 
		`STATE_INPUT: begin // 00
			next_state_mirror = `STATE_CAL;
		end
		`STATE_CAL: begin // 01
			next_state_mirror = `STATE_OUTPUT; // 10
		end
		`STATE_OUTPUT: begin // 10
			next_state_mirror = `STATE_INPUT; // 00
		end
		`STATE_IDLE: begin // 11
			next_state_mirror = `STATE_IDLE; // 11
		end
		default: next_state_mirror = `STATE_IDLE; // 11
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



/////////////////////////////////////////////
always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_mirror <= 1'b0;
	end
	else begin
		if(next_acpi_addr[0] & next_acpi_addr[1] & next_acpi_addr[2] & next_acpi_addr[3] & next_acpi_addr[4] & next_acpi_addr[5] & next_acpi_addr[6] && bayer_mode == 3'd5) begin
			bayer_mirror = 1'b1;
		end
		/*
		else if(bayer_mirror) begin
			bayer_mirror <= 1'b1;
		end
		*/
		else if(bayer_mirror_one) begin
			bayer_mirror <= 1'b0;
		end
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_mirror_one <= 1'b0;
	end
	else if(bayer_addr_1 && ~state_mirror[0] & ~state_mirror[1]) begin
		bayer_mirror_one <= 1'b1;
	end
	else begin
		bayer_mirror_one <= 1'b0;
	end
end

/////////////////////////////////////////////



always @(posedge clk or posedge rst) begin
	if(rst) begin
		entries_filled <= 4'd0;
	end
	else if(bayer_ready) begin
		if(entries_filled == 4'd8) begin
			if(bayer_addr[6] & bayer_addr[5] & bayer_addr[4] & bayer_addr[3] & bayer_addr[2] & bayer_addr[1] & bayer_addr[0])
				entries_filled <= 4'd0;
			else
				entries_filled <= 4'd6;
		end
		else begin
			entries_filled <= entries_filled + 4'd1;
		end	
	end 
	else begin
		entries_filled <= entries_filled;		
	end
end



//////////////////////////////////////////////
/*
always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_addr_1 <= 14'd0;
	end
	else if(bayer_mirror) begin
		if(bayer_mirror_one) begin
			bayer_addr_1 <= bayer_addr_1 + 14'd1;
		end
		else begin
			bayer_addr_1 <= bayer_addr_1 + 14'd1;
		end
	end
end
*/

//////////////////////////////
//      to be continue      //
//////////////////////////////
always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_addr_1 <= 14'd0;
	end
	else if(bayer_mirror && ~bayer_mirror_one) begin
		bayer_addr_1 <= bayer_addr_1 + 14'd1;
	end
	else if(bayer_mirror_one) begin
		if(state_mirror == 2'd0) begin
			bayer_addr_1 <= bayer_addr_1 - 14'd127;
		end
		else if(state_mirror == 2'd1) begin
			bayer_addr_1 <= bayer_addr_1 -;
		end
		else if(state_mirror == 2'd2) begin
			bayer_addr_1 <= bayer_addr_1 -;
		end
		else begin
			bayer_addr_1 <= bayer_addr_1 + 14'd1;
		end
	end
end
/////////////////////////////////////////////

always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_addr <= 14'd129;
	end
	else if(bayer_ready) begin
		if(entries_filled == 4'd0) begin
			if(bayer_addr[6] & bayer_addr[5] & bayer_addr[4] & bayer_addr[3] & bayer_addr[2] & bayer_addr[1] & bayer_addr[0]) begin
				bayer_addr <= bayer_addr - 14'd127;
			end
			else
				bayer_addr <= bayer_addr - 14'd129; //0
		end
		else if(entries_filled == 4'd1) begin
			bayer_addr <= bayer_addr + 14'd256; // 256
		end
		else if(entries_filled == 4'd2) begin
			bayer_addr <= bayer_addr - 14'd128; //128
		end
		else if(entries_filled == 4'd3) begin
			bayer_addr <= bayer_addr - 14'd127; // 1 
		end
		else if(entries_filled == 4'd4) begin       
			bayer_addr <= bayer_addr + 14'd256;//257        
		end                                           
		else if(entries_filled == 4'd5) begin
			bayer_addr <= bayer_addr - 14'd128;//129
		end
		else if(entries_filled == 4'd6) begin
			bayer_addr <= bayer_addr - 14'd127;//2
		end
		else if(entries_filled == 4'd7) begin
			bayer_addr <= bayer_addr + 14'd256;//258
		end
		else if(entries_filled == 4'd8) begin
			bayer_addr <= bayer_addr - 14'd128;//130
		end
	end
	else begin
		bayer_addr <= bayer_addr;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		acpi_addr <= 14'd1;
	end
	else begin
		acpi_addr <= next_acpi_addr;
	end
end

always @(*) begin
	if(acpi_valid_1) begin
		if(acpi_addr[6] & acpi_addr[5] & acpi_addr[4] & acpi_addr[3] & acpi_addr[2] & acpi_addr[1] & acpi_addr[0]) begin
			next_acpi_addr = acpi_addr + 1;
		end
		else if(acpi_addr[6] & acpi_addr[5] & acpi_addr[4] & acpi_addr[3] & acpi_addr[2] & acpi_addr[1]) begin
			next_acpi_addr = acpi_addr + 3;
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
	else if(state == `STATE_OUTPUT) begin
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
		bayer_central <= 8'd0; 
		bayer_pixal_1 <= 8'd0; 
		bayer_pixal_2 <= 8'd0; 
		bayer_pixal_3 <= 8'd0; 
		bayer_pixal_4 <= 8'd0;
		bayer_pixal_5 <= 8'd0; 
		bayer_pixal_6 <= 8'd0; 
		bayer_pixal_7 <= 8'd0; 
		bayer_pixal_8 <= 8'd0; 
		bayer_pixal_9 <= 8'd0;
		bayer_pixal_10 <= 8'd0; 
		bayer_pixal_11 <= 8'd0; 
		bayer_pixal_12 <= 8'd0; 
		bayer_pixal_13 <= 8'd0; 
		bayer_pixal_14 <= 8'd0;
		bayer_pixal_15 <= 8'd0; 
		bayer_pixal_16 <= 8'd0; 
		bayer_pixal_17 <= 8'd0; 
		bayer_pixal_18 <= 8'd0; 
		bayer_pixal_19 <= 8'd0;
		bayer_pixal_20 <= 8'd0; 
		bayer_pixal_21 <= 8'd0; 
		bayer_pixal_22 <= 8'd0; 
		bayer_pixal_23 <= 8'd0; 
		bayer_pixal_24 <= 8'd0; 
		bayer_new_central <= 8'd0;
		bayer_pixal_new_1 <= 8'd0;
		bayer_pixal_new_2 <= 8'd0;
		bayer_pixal_new_3 <= 8'd0;
		bayer_pixal_new_4 <= 8'd0;
		bayer_pixal_new_5 <= 8'd0;
		bayer_pixal_new_6 <= 8'd0;
		bayer_pixal_new_7 <= 8'd0;
		bayer_pixal_new_8 <= 8'd0;
	end
	/* 一開始讀進3*3 鏡射成5*5*/
	else if(bayer_mode == 3'd1) begin
		bayer_central <= bayer_pixal_22;
		bayer_pixal_1 <= bayer_pixal_14;
		bayer_pixal_2 <= bayer_pixal_13;
		bayer_pixal_3 <= bayer_pixal_13;
		bayer_pixal_4 <= bayer_pixal_14;
		bayer_pixal_5 <= bayer_data;
		bayer_pixal_6 <= bayer_pixal_23;
		bayer_pixal_7 <= bayer_pixal_22;
		bayer_pixal_8 <= bayer_pixal_22;
		bayer_pixal_9 <= bayer_pixal_23;
		bayer_pixal_10 <= bayer_pixal_24;
		bayer_pixal_11 <= bayer_pixal_23;
		bayer_pixal_12 <= bayer_pixal_22;
		bayer_pixal_13 <= bayer_pixal_23;
		bayer_pixal_14 <= bayer_pixal_24;
		bayer_pixal_15 <= bayer_pixal_14;
		bayer_pixal_16 <= bayer_pixal_13;
		bayer_pixal_17 <= bayer_pixal_13;
		bayer_pixal_18 <= bayer_pixal_14;
		bayer_pixal_19 <= bayer_data;
		bayer_pixal_20 <= bayer_pixal_18;
		bayer_pixal_21 <= bayer_pixal_17;
		bayer_pixal_22 <= bayer_pixal_17;
		bayer_pixal_23 <= bayer_pixal_18;
		bayer_pixal_24 <= bayer_pixal_19;

		bayer_new_central <= bayer_pixal_new_3;
		bayer_pixal_new_1 <= bayer_pixal_new_6;
		bayer_pixal_new_2 <= bayer_pixal_new_7;
		bayer_pixal_new_3 <= bayer_pixal_new_8;
		bayer_pixal_new_4 <= bayer_pixal_new_2;
		bayer_pixal_new_5 <= bayer_data;
		bayer_pixal_new_6 <= bayer_pixal_new_4;
		bayer_pixal_new_7 <= bayer_new_central;
		bayer_pixal_new_8 <= bayer_pixal_new_5;
	end
	/* 第一個鏡射5*5完成後 再讀進新的一排(5個data , 新的3個data去鏡射上面兩個data) */
	/* 其他的都往左移一位 依此類推 */
	else if(bayer_mode == 3'd2) begin
		bayer_central <= bayer_pixal_22;
		bayer_pixal_1 <= bayer_pixal_12;
		bayer_pixal_2 <= bayer_central;
		bayer_pixal_3 <= bayer_pixal_13;
		bayer_pixal_4 <= bayer_pixal_14;
		bayer_pixal_5 <= bayer_data;
		bayer_pixal_6 <= bayer_pixal_20;
		bayer_pixal_7 <= bayer_pixal_21;
		bayer_pixal_8 <= bayer_pixal_22;
		bayer_pixal_9 <= bayer_pixal_23;
		bayer_pixal_10 <= bayer_pixal_24;
		bayer_pixal_11 <= bayer_pixal_20;
		bayer_pixal_12 <= bayer_pixal_21;
		bayer_pixal_13 <= bayer_pixal_23;
		bayer_pixal_14 <= bayer_pixal_24;
		bayer_pixal_15 <= bayer_pixal_12;
		bayer_pixal_16 <= bayer_central;
		bayer_pixal_17 <= bayer_pixal_13;
		bayer_pixal_18 <= bayer_pixal_14;
		bayer_pixal_19 <= bayer_data;
		bayer_pixal_20 <= bayer_pixal_15;
		bayer_pixal_21 <= bayer_pixal_16;
		bayer_pixal_22 <= bayer_pixal_17;
		bayer_pixal_23 <= bayer_pixal_18;
		bayer_pixal_24 <= bayer_pixal_19;

		bayer_new_central <= bayer_pixal_new_3;
		bayer_pixal_new_1 <= bayer_pixal_new_6;
		bayer_pixal_new_2 <= bayer_pixal_new_7;
		bayer_pixal_new_3 <= bayer_pixal_new_8;
		bayer_pixal_new_4 <= bayer_pixal_new_2;
		bayer_pixal_new_5 <= bayer_data;
		bayer_pixal_new_6 <= bayer_pixal_new_4;
		bayer_pixal_new_7 <= bayer_new_central;
		bayer_pixal_new_8 <= bayer_pixal_new_5;
	end
	/* 倒數第二排的鏡射 ， */
	else if(bayer_mode == 3'd3) begin
		if(bayer_mirror_one) begin
			bayer_pixal_1 <= bayer_pixal_7;
			bayer_pixal_2 <= bayer_pixal_8;
			bayer_pixal_3 <= bayer_pixal_9;
			bayer_pixal_4 <= bayer_pixal_10;
			bayer_pixal_5 <= bayer_pixal_10;
			bayer_pixal_6 <= bayer_pixal_7;
			bayer_pixal_7 <= bayer_pixal_8;
			bayer_pixal_8 <= bayer_pixal_9;
			bayer_pixal_9 <= bayer_pixal_10;
			bayer_pixal_10 <= bayer_pixal_10;
		end
		bayer_central <= bayer_pixal_22;
		/*		
		bayer_pixal_1 <= bayer_pixal_12;
		bayer_pixal_2 <= bayer_central;
		bayer_pixal_3 <= bayer_pixal_13;
		bayer_pixal_4 <= bayer_pixal_14;
		bayer_pixal_5 <= bayer_pixal_14;
		bayer_pixal_6 <= bayer_pixal_20;
		bayer_pixal_7 <= bayer_pixal_21;
		bayer_pixal_8 <= bayer_pixal_22;
		bayer_pixal_9 <= bayer_pixal_23;
		bayer_pixal_10 <= bayer_pixal_24;
		*/
		bayer_pixal_11 <= bayer_pixal_20;
		bayer_pixal_12 <= bayer_pixal_21;
		bayer_pixal_13 <= bayer_pixal_23;
		bayer_pixal_14 <= bayer_pixal_24;
		bayer_pixal_15 <= bayer_pixal_12;
		bayer_pixal_16 <= bayer_central;
		bayer_pixal_17 <= bayer_pixal_13;
		bayer_pixal_18 <= bayer_pixal_14;
		bayer_pixal_19 <= bayer_pixal_14;
		bayer_pixal_20 <= bayer_pixal_15;
		bayer_pixal_21 <= bayer_pixal_16;
		bayer_pixal_22 <= bayer_pixal_17;
		bayer_pixal_23 <= bayer_pixal_18;
		bayer_pixal_24 <= bayer_pixal_19;

		bayer_new_central <= bayer_pixal_new_3;
		bayer_pixal_new_1 <= bayer_pixal_new_6;
		bayer_pixal_new_2 <= bayer_pixal_new_7;
		bayer_pixal_new_3 <= bayer_pixal_new_8;
		bayer_pixal_new_4 <= bayer_pixal_new_2;
		bayer_pixal_new_5 <= bayer_data;
		bayer_pixal_new_6 <= bayer_pixal_new_4;
		bayer_pixal_new_7 <= bayer_new_central;
		bayer_pixal_new_8 <= bayer_pixal_new_5;
	end
	/*　最後一排的鏡射 */
	else if(bayer_mode == 3'd4) begin
		bayer_central <= bayer_pixal_22;

		if(bayer_mirror_one) begin
			bayer_pixal_1 <= bayer_pixal_7;
			bayer_pixal_2 <= bayer_pixal_8;
			bayer_pixal_3 <= bayer_pixal_9;
			bayer_pixal_4 <= bayer_pixal_10;
			bayer_pixal_5 <= bayer_pixal_8;
			bayer_pixal_6 <= bayer_pixal_7;
			bayer_pixal_7 <= bayer_pixal_8;
			bayer_pixal_8 <= bayer_pixal_9;
			bayer_pixal_9 <= bayer_pixal_10;
			bayer_pixal_10 <= bayer_pixal_8;
		end
		/*
		bayer_pixal_1 <= bayer_pixal_12;
		bayer_pixal_2 <= bayer_central;
		bayer_pixal_3 <= bayer_pixal_13;
		bayer_pixal_4 <= bayer_pixal_14;
		bayer_pixal_5 <= bayer_central;
		bayer_pixal_6 <= bayer_pixal_20;
		bayer_pixal_7 <= bayer_pixal_21;
		bayer_pixal_8 <= bayer_pixal_22;
		bayer_pixal_9 <= bayer_pixal_23;
		bayer_pixal_10 <= bayer_pixal_24;
		*/
		bayer_pixal_11 <= bayer_pixal_20;
		bayer_pixal_12 <= bayer_pixal_21;
		bayer_pixal_13 <= bayer_pixal_23;
		bayer_pixal_14 <= bayer_pixal_24;
		bayer_pixal_15 <= bayer_pixal_12;
		bayer_pixal_16 <= bayer_central;
		bayer_pixal_17 <= bayer_pixal_13;
		bayer_pixal_18 <= bayer_pixal_14;
		bayer_pixal_19 <= bayer_central;
		bayer_pixal_20 <= bayer_pixal_15;
		bayer_pixal_21 <= bayer_pixal_16;
		bayer_pixal_22 <= bayer_pixal_17;
		bayer_pixal_23 <= bayer_pixal_18;
		bayer_pixal_24 <= bayer_pixal_19;

		bayer_new_central <= bayer_pixal_new_3;
		bayer_pixal_new_1 <= bayer_pixal_new_6;
		bayer_pixal_new_2 <= bayer_pixal_new_7;
		bayer_pixal_new_3 <= bayer_pixal_new_8;
		bayer_pixal_new_4 <= bayer_pixal_new_2;
		bayer_pixal_new_5 <= bayer_data;
		bayer_pixal_new_6 <= bayer_pixal_new_4;
		bayer_pixal_new_7 <= bayer_new_central;
		bayer_pixal_new_8 <= bayer_pixal_new_5;
	end
	else if(bayer_mode == 3'd5) begin
		bayer_central <= bayer_pixal_new_6;
		
		bayer_pixal_1 <= bayer_pixal_10;
		bayer_pixal_2 <= bayer_pixal_9;
		bayer_pixal_3 <= bayer_pixal_9;
		bayer_pixal_4 <= bayer_pixal_10;
		bayer_pixal_5 <= bayer_data_1;
		bayer_pixal_6 <= bayer_pixal_10;
		bayer_pixal_7 <= bayer_pixal_9;
		bayer_pixal_8 <= bayer_pixal_9;
		bayer_pixal_9 <= bayer_pixal_10;
		bayer_pixal_10 <= bayer_data_1;
		
		bayer_pixal_11 <= bayer_pixal_new_7;
		bayer_pixal_12 <= bayer_pixal_new_6;
		bayer_pixal_13 <= bayer_pixal_new_7;
		bayer_pixal_14 <= bayer_pixal_new_8;
		bayer_pixal_15 <= bayer_pixal_new_3;
		bayer_pixal_16 <= bayer_pixal_new_2;
		bayer_pixal_17 <= bayer_pixal_new_2;
		bayer_pixal_18 <= bayer_pixal_new_3;
		bayer_pixal_19 <= bayer_data;
		bayer_pixal_20 <= bayer_new_central;
		bayer_pixal_21 <= bayer_pixal_new_4;
		bayer_pixal_22 <= bayer_pixal_new_4;
		bayer_pixal_23 <= bayer_new_central;
		bayer_pixal_24 <= bayer_pixal_new_5;
		
		bayer_new_central <= bayer_pixal_new_3;
		bayer_pixal_new_1 <= bayer_pixal_new_6;
		bayer_pixal_new_2 <= bayer_pixal_new_7;
		bayer_pixal_new_3 <= bayer_pixal_new_8;
		bayer_pixal_new_4 <= bayer_pixal_new_2;
		bayer_pixal_new_5 <= bayer_data;
		bayer_pixal_new_6 <= bayer_pixal_new_4;
		bayer_pixal_new_7 <= bayer_new_central;
		bayer_pixal_new_8 <= bayer_pixal_new_5;
	end
	else if(bayer_mode == 3'd6) begin
		bayer_central <= bayer_pixal_new_6;
		if(bayer_mirror_one) begin
			bayer_pixal_1 <= bayer_pixal_7;
			bayer_pixal_2 <= bayer_pixal_8;
			bayer_pixal_3 <= bayer_pixal_9;
			bayer_pixal_4 <= bayer_pixal_10;
			bayer_pixal_5 <= bayer_data_1;
			bayer_pixal_6 <= bayer_pixal_7;
			bayer_pixal_7 <= bayer_pixal_8;
			bayer_pixal_8 <= bayer_pixal_9;
			bayer_pixal_9 <= bayer_pixal_10;
			bayer_pixal_10 <= bayer_data_1;
		end

		bayer_pixal_11 <= bayer_pixal_20;
		bayer_pixal_12 <= bayer_pixal_21;
		bayer_pixal_13 <= bayer_pixal_23;
		bayer_pixal_14 <= bayer_pixal_24;
		bayer_pixal_15 <= bayer_pixal_12;
		bayer_pixal_16 <= bayer_central;
		bayer_pixal_17 <= bayer_pixal_13;
		bayer_pixal_18 <= bayer_pixal_14;
		bayer_pixal_19 <= bayer_data;
		bayer_pixal_20 <= bayer_pixal_15;
		bayer_pixal_21 <= bayer_pixal_16;
		bayer_pixal_22 <= bayer_pixal_17;
		bayer_pixal_23 <= bayer_pixal_18;
		bayer_pixal_24 <= bayer_pixal_19;
		
		bayer_new_central <= bayer_pixal_new_3;
		bayer_pixal_new_1 <= bayer_pixal_new_6;
		bayer_pixal_new_2 <= bayer_pixal_new_7;
		bayer_pixal_new_3 <= bayer_pixal_new_8;
		bayer_pixal_new_4 <= bayer_pixal_new_2;
		bayer_pixal_new_5 <= bayer_data;
		bayer_pixal_new_6 <= bayer_pixal_new_4;
		bayer_pixal_new_7 <= bayer_new_central;
		bayer_pixal_new_8 <= bayer_pixal_new_5;
	end
	else if(bayer_mode == 3'd7) begin
		bayer_central <= bayer_pixal_new_6;
		
		bayer_pixal_1 <= bayer_pixal_10;
		bayer_pixal_2 <= bayer_pixal_9;
		bayer_pixal_3 <= bayer_pixal_9;
		bayer_pixal_4 <= bayer_pixal_10;
		bayer_pixal_5 <= bayer_data_1;
		bayer_pixal_6 <= bayer_pixal_10;
		bayer_pixal_7 <= bayer_pixal_9;
		bayer_pixal_8 <= bayer_pixal_9;
		bayer_pixal_9 <= bayer_pixal_10;
		bayer_pixal_10 <= bayer_data_1;
		
		bayer_pixal_11 <= bayer_pixal_20;
		bayer_pixal_12 <= bayer_pixal_21;
		bayer_pixal_13 <= bayer_pixal_23;
		bayer_pixal_14 <= bayer_pixal_24;
		bayer_pixal_15 <= bayer_pixal_12;
		bayer_pixal_16 <= bayer_central;
		bayer_pixal_17 <= bayer_pixal_13;
		bayer_pixal_18 <= bayer_pixal_14;
		bayer_pixal_19 <= bayer_data;
		bayer_pixal_20 <= bayer_pixal_15;
		bayer_pixal_21 <= bayer_pixal_16;
		bayer_pixal_22 <= bayer_pixal_17;
		bayer_pixal_23 <= bayer_pixal_18;
		bayer_pixal_24 <= bayer_pixal_19;
		
		bayer_new_central <= bayer_pixal_new_3;
		bayer_pixal_new_1 <= bayer_pixal_new_6;
		bayer_pixal_new_2 <= bayer_pixal_new_7;
		bayer_pixal_new_3 <= bayer_pixal_new_8;
		bayer_pixal_new_4 <= bayer_pixal_new_2;
		bayer_pixal_new_5 <= bayer_data;
		bayer_pixal_new_6 <= bayer_pixal_new_4;
		bayer_pixal_new_7 <= bayer_new_central;
		bayer_pixal_new_8 <= bayer_pixal_new_5;
	end
end

/*
always @(posedge clk or posedge rst) begin
	if() begin
	
	end
	else begin
	
	end

	if() begin
	
	end
	else begin
	
	end
end
*/
endmodule