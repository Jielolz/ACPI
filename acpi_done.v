/*
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--                           Author:   Zheng-Jie,Li               ______        --
--                          Created:   08.28.2017                    |     ___  --
--                                                                   |  ` |___| --
--           (c) Copyright 2017, Zheng-Jie,Li, All rights reserved.\_|  | |___  --
--                                                                              --
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
*/

`timescale 1ns / 10ps

module ACPI(clk, rst, b_addr_1, b_addr_2, r_addr_1, r_addr_2, r_data_1, r_data_2, b_data_1, b_data_2, bayer_addr, bayer_addr_1, bayer_addr_2, bayer_mirror, bayer_mirror_one, bayer_mirror_two, bayer_req, bayer_ready, bayer_data, bayer_data_1, bayer_data_2, g_data, g_data_1, g_data_2, green_addr, blue_red_addr, green_valid, blue_valid, red_valid, green_data, blue_data, finish, finish_rb);
input 		  clk;
input 		  rst;
output [14:0] bayer_addr;
output [13:0] bayer_addr_1;
output [13:0] bayer_addr_2;
output        bayer_mirror;
output        bayer_mirror_one;
output 		  bayer_mirror_two;
output  	  bayer_req;
input 		  bayer_ready;
input [7:0]   bayer_data;
input [13:0]  g_data;
input [7:0]   bayer_data_1;
input [13:0]  g_data_1;
input [7:0]	  bayer_data_2;
input [13:0]  g_data_2;
output [13:0] green_addr;
output [13:0] blue_red_addr;
output [13:0] b_addr_1;
output [13:0] b_addr_2;
output [13:0] r_addr_1;
output [13:0] r_addr_2;
output        green_valid;
output        blue_valid;
output        red_valid;
output [13:0] blue_data;
output [13:0] green_data;
output [13:0] b_data_1;
output [13:0] b_data_2;
output [13:0] r_data_1;
output [13:0] r_data_2;
output 		  finish;
output    	  finish_rb;

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

reg [14:0] bayer_addr;
reg [13:0] bayer_addr_1;
reg [13:0] bayer_addr_2;
reg        bayer_mirror;
reg        bayer_mirror_one;
reg        bayer_mirror_two;
reg 	   bayer_req;
reg [2:0]  bayer_mode;
reg [13:0] green_addr, next_green_addr;
reg [13:0] blue_red_addr, next_blue_red_addr, b_addr_1, b_addr_2, r_addr_1, r_addr_2;
reg        green_valid;
reg        blue_valid;
reg        red_valid;
reg [13:0] green_data, blue_data;
reg 	   finish;
reg 	   finish_rb;

// 25 temp registers

reg [7:0] bayer_central, bayer_pixal_1, bayer_pixal_2, bayer_pixal_3, bayer_pixal_4;
reg [7:0] bayer_pixal_5, bayer_pixal_6, bayer_pixal_7, bayer_pixal_8, bayer_pixal_9;
reg [7:0] bayer_pixal_10, bayer_pixal_11, bayer_pixal_12, bayer_pixal_13, bayer_pixal_14;
reg [7:0] bayer_pixal_15, bayer_pixal_16, bayer_pixal_17, bayer_pixal_18, bayer_pixal_19;
reg [7:0] bayer_pixal_20, bayer_pixal_21, bayer_pixal_22, bayer_pixal_23, bayer_pixal_24;

reg [7:0] bayer_pixal_new_1, bayer_pixal_new_2, bayer_pixal_new_3;
reg [7:0] bayer_pixal_new_4, bayer_new_central, bayer_pixal_new_5;
reg [7:0] bayer_pixal_new_6, bayer_pixal_new_7, bayer_pixal_new_8;

///////////////////////////////////////////////////////////////////////////////////////////
reg [13:0] bayer_n_central, bayer_pixal_n_1, bayer_pixal_n_2, bayer_pixal_n_3, bayer_pixal_n_4;
reg [13:0] bayer_pixal_n_5, bayer_pixal_n_6, bayer_pixal_n_7, bayer_pixal_n_8, bayer_pixal_n_9;
reg [13:0] bayer_pixal_n_10, bayer_pixal_n_11, bayer_pixal_n_12, bayer_pixal_n_13, bayer_pixal_n_14;
reg [13:0] bayer_pixal_n_15, bayer_pixal_n_16, bayer_pixal_n_17, bayer_pixal_n_18, bayer_pixal_n_19;
reg [13:0] bayer_pixal_n_20, bayer_pixal_n_21, bayer_pixal_n_22, bayer_pixal_n_23, bayer_pixal_n_24;

reg [13:0] bayer_pixal_new_n_1, bayer_pixal_new_n_2, bayer_pixal_new_n_3;
reg [13:0] bayer_pixal_new_n_4, bayer_new_n_central, bayer_pixal_new_n_5;
reg [13:0] bayer_pixal_new_n_6, bayer_pixal_new_n_7, bayer_pixal_new_n_8;
//////////////////////////////////////////////////////////////////////////////////////////

// Blue and Red interpolation register

reg [13:0] b_r_central, dn_1, dn_2_1, dn_2_2, dp_1, dp_2_1, dp_2_2;
reg [13:0] dn, dp;
reg [13:0] br_1, br_2, br_3, br_4, br_5, br_6;
reg [13:0] br_central, br_g;                      

// Blue and Red interpolation alone register

reg [13:0] b_cen_1, b_cen_2, b_1_3, b_1, b_2, b_2_4, b_3, b_4;
reg [13:0] b_data_1, b_data_2;
reg [13:0] r_cen_1, r_cen_2, r_1_3, r_1, r_2, r_2_4, r_3, r_4;
reg [13:0] r_data_1, r_data_2;

// Green interpolation register

reg [13:0] g_central, dh_1, dh_2_1, dh_2_2, dv_1, dv_2_1, dv_2_2;
reg [13:0] dh, dv;
reg [13:0] green_1, green_2, green_3, green_4, green_5, green_6;
reg [13:0] green_central, green_r_b;

reg [1:0] state_mirror, next_state_mirror, state, next_state;
reg [2:0] state_1, next_state_1;
reg [3:0] entries_filled, entries_filled_1;

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
			if(next_green_addr[7] & ~next_green_addr[6] & ~next_green_addr[5] & ~next_green_addr[4] & ~next_green_addr[3] & ~next_green_addr[2] & ~next_green_addr[1] & ~next_green_addr[0] && state_1[1]) begin
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
		green_valid <= 1'b0;
	end
	else if(state_1 == `STATE_6) begin
		green_valid <= 1'b1;
	end
	else if(next_green_addr[7] & ~next_green_addr[6] & ~next_green_addr[5] & ~next_green_addr[4] & ~next_green_addr[3] & ~next_green_addr[2] & ~next_green_addr[1] & ~next_green_addr[0] && state_1[1]) begin
		green_valid <= 1'b1;
	end
	else begin
		green_valid <= 1'b0;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		blue_valid <= 1'b0;
	end
	else if(blue_data && state_1 == `STATE_6 && green_addr <= 14'd127) begin
		blue_valid <= 1'b1;
	end
	else if(blue_data && state_1 == `STATE_6 && ~green_addr[7]) begin
		blue_valid <= 1'b1;
	end
	else begin
		blue_valid <= 1'b0;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		red_valid <= 1'b0;
	end
	else if(blue_data && state_1 == `STATE_6 && green_addr[7]) begin
		red_valid <= 1'b1;
	end
	else if(blue_data && next_green_addr[7] & ~next_green_addr[6] & ~next_green_addr[5] & ~next_green_addr[4] & ~next_green_addr[3] & ~next_green_addr[2] & ~next_green_addr[1] & ~next_green_addr[0] && state_1[1]) begin
		red_valid <= 1'b1;
	end
	else begin
		red_valid <= 1'b0;
	end
end

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

always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_mirror <= 1'b0;
	end
	else begin
		if(bayer_mode == 3'd5 && state_mirror == 2'd2 | state_mirror == 2'd0) begin
			bayer_mirror = 1'b1;
		end
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

always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_mirror_two <= 1'b0;
	end
	else if(bayer_addr_2 && ~state_mirror[0] & ~state_mirror[1]) begin
		bayer_mirror_two <= 1'b1;
	end
	else begin
		bayer_mirror_two <= 1'b0;
	end
end

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

always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_addr_1 <= 14'd0;
	end
	else if(bayer_mirror && ~bayer_mirror_one) begin
		bayer_addr_1 <= bayer_addr_1 + 14'd1;
	end
	else if(~bayer_addr_1[0] & ~bayer_addr_1[1] & ~bayer_addr_1[2] & ~bayer_addr_1[3] & ~bayer_addr_1[4] & ~bayer_addr_1[5] & ~bayer_addr_1[6]) begin
		bayer_addr_1 <= bayer_addr_1;
	end	
	else if(bayer_mirror_one) begin
		bayer_addr_1 <= bayer_addr_1 + 14'd1;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_addr_2 <= 14'd0;
	end
	else if(bayer_mirror && ~bayer_mirror_two && green_addr[8] | green_addr[9] | green_addr[10] | green_addr[11] | green_addr[12] | green_addr[13]) begin
		bayer_addr_2 <= bayer_addr_2 + 14'd1;
	end
	else if(~bayer_addr_2[0] & ~bayer_addr_2[1] & ~bayer_addr_2[2] & ~bayer_addr_2[3] & ~bayer_addr_2[4] & ~bayer_addr_2[5] & ~bayer_addr_2[6]) begin
		bayer_addr_2 <= bayer_addr_2;
	end
	else if(bayer_mirror_two) begin
		bayer_addr_2 <= bayer_addr_2 + 14'd1;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_addr <= 14'd129;
	end
	else if(bayer_ready) begin
		if(entries_filled == 4'd0) begin
			if(bayer_addr[6] & bayer_addr[5] & bayer_addr[4] & bayer_addr[3] & bayer_addr[2] & bayer_addr[1] & bayer_addr[0]) begin
				bayer_addr <= bayer_addr - 14'd127;
			end
			else begin
				bayer_addr <= bayer_addr - 14'd129;
			end 
		end
		else if(entries_filled == 4'd1) begin
			bayer_addr <= bayer_addr + 14'd256;
		end
		else if(entries_filled == 4'd2) begin
			bayer_addr <= bayer_addr - 14'd128;
		end
		else if(entries_filled == 4'd3) begin
			bayer_addr <= bayer_addr - 14'd127; 
		end
		else if(entries_filled == 4'd4) begin       
			bayer_addr <= bayer_addr + 14'd256;        
		end                                           
		else if(entries_filled == 4'd5) begin
			bayer_addr <= bayer_addr - 14'd128;
		end
		else if(entries_filled == 4'd6) begin
			bayer_addr <= bayer_addr - 14'd127;
		end
		else if(entries_filled == 4'd7) begin
			bayer_addr <= bayer_addr + 14'd256;
		end
		else if(entries_filled == 4'd8) begin
			bayer_addr <= bayer_addr - 14'd128;
		end
	end
	else begin
		bayer_addr <= bayer_addr;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		green_addr <= 14'd1;
	end
	else begin
		green_addr <= next_green_addr;
	end
end

always @(*) begin
	if(green_valid) begin
		if(green_addr[6] & green_addr[5] & green_addr[4] & green_addr[3] & green_addr[2] & green_addr[1] & green_addr[0]) begin
			next_green_addr = green_addr + 1;
		end
		else if(green_addr[6] & green_addr[5] & green_addr[4] & green_addr[3] & green_addr[2] & green_addr[1]) begin
			next_green_addr = green_addr + 3;
		end
		else begin
			next_green_addr = green_addr + 2;
		end
	end
	else begin
		next_green_addr = green_addr;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		blue_red_addr <= 14'd1;
	end
	else begin
		blue_red_addr <= next_blue_red_addr;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		b_addr_1 <= 14'd0;
	end
	else begin
		b_addr_1 <= next_blue_red_addr - 14'd1;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		b_addr_2 <= 14'd129;
	end
	else begin
		b_addr_2 <= next_blue_red_addr + 14'd128;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		r_addr_1 <= 14'd1;
	end
	else begin
		r_addr_1 <= next_blue_red_addr - 14'd128;
		/*
		if(r_addr_1[13]) begin
			r_addr_1 = 14'd128;
		end
		*/
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		r_addr_2 <= 14'd2;
	end
	else begin
		r_addr_2 <= next_blue_red_addr + 14'd1;
	end
end

always @(*) begin
	if(red_valid || blue_valid) begin
		if(blue_red_addr[6] & blue_red_addr[5] & blue_red_addr[4] & blue_red_addr[3] & blue_red_addr[2] & blue_red_addr[1] & blue_red_addr[0]) begin
			next_blue_red_addr = blue_red_addr + 1;
		end
		else if(blue_red_addr[6] & blue_red_addr[5] & blue_red_addr[4] & blue_red_addr[3] & blue_red_addr[2] & blue_red_addr[1])  begin
			next_blue_red_addr = blue_red_addr + 3;
		end
		else begin
			next_blue_red_addr = blue_red_addr + 2;
		end
	end
	else begin
		next_blue_red_addr = blue_red_addr;
	end
end
 
always @(posedge clk or posedge rst) begin
	if(rst) begin
		finish <= 1'b0;
	end
	else begin
		if(green_addr == 16382 && green_valid == 1)
			finish <= 1'd1;
		else
			finish <= 1'd0;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		finish_rb <= 1'b0;
	end
	else begin 
		if(green_addr == 16382 && red_valid == 1)
			finish_rb <= 1'b1;
		else 
			finish_rb <= 1'b0;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		green_data <= 14'd0;
	end
	else begin
		green_data <= green_r_b;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		blue_data <= 14'd0;
	end
	else begin
		blue_data <= br_g;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		b_data_1 <= 14'd0;
		b_data_2 <= 14'd0;
	end
	else begin
		b_data_1 <= b_1_3;
		b_data_2 <= b_2_4;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		r_data_1 <= 14'd0;
		r_data_2 <= 14'd0;
	end
	else begin
		r_data_1 <= r_1_3;
		r_data_2 <= r_2_4;
	end
end

// change 5*5 pixal array (25 registers)

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
		if(green_addr[7] | green_addr[8] | green_addr[9] | green_addr[10] | green_addr[11] | green_addr[12] | green_addr[13]) begin
			if(bayer_mirror_one) begin
				if(bayer_mirror_two) begin
					bayer_pixal_1 <= bayer_pixal_2;
					bayer_pixal_2 <= bayer_pixal_3;
					bayer_pixal_3 <= bayer_pixal_4;
					bayer_pixal_4 <= bayer_pixal_5;
					bayer_pixal_5 <= bayer_pixal_5;
					bayer_pixal_6 <= bayer_pixal_7;
					bayer_pixal_7 <= bayer_pixal_8;
					bayer_pixal_8 <= bayer_pixal_9;
					bayer_pixal_9 <= bayer_pixal_10;
					bayer_pixal_10 <= bayer_pixal_10;
				end
				else begin
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
			end
		end
		else begin
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
		end
		bayer_central <= bayer_pixal_22;
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
		if(green_addr[7] | green_addr[8] | green_addr[9] | green_addr[10] | green_addr[11] | green_addr[12] | green_addr[13]) begin
			if(bayer_mirror_one) begin
				if(bayer_mirror_two) begin
					bayer_pixal_1 <= bayer_pixal_2;
					bayer_pixal_2 <= bayer_pixal_3;
					bayer_pixal_3 <= bayer_pixal_4;
					bayer_pixal_4 <= bayer_pixal_5;
					bayer_pixal_5 <= bayer_pixal_3;
					bayer_pixal_6 <= bayer_pixal_7;
					bayer_pixal_7 <= bayer_pixal_8;
					bayer_pixal_8 <= bayer_pixal_9;
					bayer_pixal_9 <= bayer_pixal_10;
					bayer_pixal_10 <= bayer_pixal_8;
				end
				else begin
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
			end
		end
		else begin
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
		end
		bayer_central <= bayer_pixal_22;
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
		if(green_addr[8] | green_addr[9] | green_addr[10] | green_addr[11] | green_addr[12] | green_addr[13]) begin
			bayer_pixal_1 <= bayer_pixal_5;
			bayer_pixal_2 <= bayer_pixal_4;
			bayer_pixal_3 <= bayer_pixal_4;
			bayer_pixal_4 <= bayer_pixal_5;
			bayer_pixal_5 <= bayer_data_2;
			bayer_pixal_6 <= bayer_pixal_10;
			bayer_pixal_7 <= bayer_pixal_9;
			bayer_pixal_8 <= bayer_pixal_9;
			bayer_pixal_9 <= bayer_pixal_10;
			bayer_pixal_10 <= bayer_data_1;
		end
		else begin
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
		end
		bayer_central <= bayer_pixal_new_6;
		bayer_pixal_11 <= bayer_pixal_new_7;
		bayer_pixal_12 <= bayer_pixal_new_6;
		bayer_pixal_13 <= bayer_pixal_new_7;
		bayer_pixal_14 <= bayer_pixal_new_8;
		bayer_pixal_15 <= bayer_pixal_new_3;
		bayer_pixal_16 <= bayer_pixal_new_2;
		bayer_pixal_17 <= bayer_pixal_new_2;
		bayer_pixal_18 <= bayer_pixal_new_3;
		bayer_pixal_19 <= bayer_data;

		if(green_addr[7] & green_addr[8] & green_addr[9] & green_addr[10] & green_addr[11] & green_addr[12] & green_addr[13]) begin
			bayer_pixal_20 <= bayer_pixal_10;
			bayer_pixal_21 <= bayer_pixal_9;
			bayer_pixal_22 <= bayer_pixal_9;
			bayer_pixal_23 <= bayer_pixal_10;
			bayer_pixal_24 <= bayer_data_1;
		end
		else if(green_addr[8] & green_addr[9] & green_addr[10] & green_addr[11] & green_addr[12] & green_addr[13]) begin
			bayer_pixal_20 <= bayer_pixal_new_3;
			bayer_pixal_21 <= bayer_pixal_new_2;
			bayer_pixal_22 <= bayer_pixal_new_2;
			bayer_pixal_23 <= bayer_pixal_new_3;
			bayer_pixal_24 <= bayer_data;
		end
		else begin
			bayer_pixal_20 <= bayer_new_central;
			bayer_pixal_21 <= bayer_pixal_new_4;
			bayer_pixal_22 <= bayer_pixal_new_4;
			bayer_pixal_23 <= bayer_new_central;
			bayer_pixal_24 <= bayer_pixal_new_5;
		end
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
		if(bayer_mirror_one) begin
			if(bayer_mirror_two) begin
				bayer_pixal_1 <= bayer_pixal_2;
				bayer_pixal_2 <= bayer_pixal_3;
				bayer_pixal_3 <= bayer_pixal_4;
				bayer_pixal_4 <= bayer_pixal_5;
				bayer_pixal_5 <= bayer_data_2;
				bayer_pixal_6 <= bayer_pixal_7;
				bayer_pixal_7 <= bayer_pixal_8;
				bayer_pixal_8 <= bayer_pixal_9;
				bayer_pixal_9 <= bayer_pixal_10;
				bayer_pixal_10 <= bayer_data_1;
			end
			else begin
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
		end
		if(green_addr[7] & green_addr[8] & green_addr[9] & green_addr[10] & green_addr[11] & green_addr[12] & green_addr[13] && bayer_mirror_two) begin
			bayer_central <= bayer_pixal_22;
			bayer_pixal_11 <= bayer_pixal_20;
			bayer_pixal_12 <= bayer_pixal_21;
			bayer_pixal_13 <= bayer_pixal_23;
			bayer_pixal_14 <= bayer_pixal_24;
			bayer_pixal_15 <= bayer_pixal_12;
			bayer_pixal_16 <= bayer_central;
			bayer_pixal_17 <= bayer_pixal_13;
			bayer_pixal_18 <= bayer_pixal_14;
			bayer_pixal_19 <= bayer_data;
			bayer_pixal_20 <= bayer_pixal_7;
			bayer_pixal_21 <= bayer_pixal_8;
			bayer_pixal_22 <= bayer_pixal_9;
			bayer_pixal_23 <= bayer_pixal_10;
			bayer_pixal_24 <= bayer_data_1;
		end
		else if(green_addr[8] & green_addr[9] & green_addr[10] & green_addr[11] & green_addr[12] & green_addr[13] && bayer_mirror_two) begin
			bayer_central <= bayer_pixal_22;
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
			bayer_pixal_24 <= bayer_data;
		end
		else begin
			bayer_central <= bayer_pixal_22;
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
		end	
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
//////////////////////////////////////////
/* The new block calculate blue and red */
//////////////////////////////////////////
always @(posedge clk or posedge rst) begin
	if(rst) begin
		bayer_n_central <= 8'd0; 
		bayer_pixal_n_1 <= 8'd0; 
		bayer_pixal_n_2 <= 8'd0; 
		bayer_pixal_n_3 <= 8'd0; 
		bayer_pixal_n_4 <= 8'd0;
		bayer_pixal_n_5 <= 8'd0; 
		bayer_pixal_n_6 <= 8'd0; 
		bayer_pixal_n_7 <= 8'd0; 
		bayer_pixal_n_8 <= 8'd0; 
		bayer_pixal_n_9 <= 8'd0;
		bayer_pixal_n_10 <= 8'd0; 
		bayer_pixal_n_11 <= 8'd0; 
		bayer_pixal_n_12 <= 8'd0; 
		bayer_pixal_n_13 <= 8'd0; 
		bayer_pixal_n_14 <= 8'd0;
		bayer_pixal_n_15 <= 8'd0; 
		bayer_pixal_n_16 <= 8'd0; 
		bayer_pixal_n_17 <= 8'd0; 
		bayer_pixal_n_18 <= 8'd0; 
		bayer_pixal_n_19 <= 8'd0;
		bayer_pixal_n_20 <= 8'd0; 
		bayer_pixal_n_21 <= 8'd0; 
		bayer_pixal_n_22 <= 8'd0; 
		bayer_pixal_n_23 <= 8'd0; 
		bayer_pixal_n_24 <= 8'd0; 
		bayer_new_n_central <= 8'd0;
		bayer_pixal_new_n_1 <= 8'd0;
		bayer_pixal_new_n_2 <= 8'd0;
		bayer_pixal_new_n_3 <= 8'd0;
		bayer_pixal_new_n_4 <= 8'd0;
		bayer_pixal_new_n_5 <= 8'd0;
		bayer_pixal_new_n_6 <= 8'd0;
		bayer_pixal_new_n_7 <= 8'd0;
		bayer_pixal_new_n_8 <= 8'd0;
	end
	/* 一開始讀進3*3 鏡射成5*5*/
	else if(bayer_mode == 3'd1) begin
		bayer_n_central <= bayer_pixal_n_22;
		bayer_pixal_n_1 <= bayer_pixal_n_14;
		bayer_pixal_n_2 <= bayer_pixal_n_13;
		bayer_pixal_n_3 <= bayer_pixal_n_13;
		bayer_pixal_n_4 <= bayer_pixal_n_14;
		bayer_pixal_n_5 <= g_data;
		bayer_pixal_n_6 <= bayer_pixal_n_23;
		bayer_pixal_n_7 <= bayer_pixal_n_22;
		bayer_pixal_n_8 <= bayer_pixal_n_22;
		bayer_pixal_n_9 <= bayer_pixal_n_23;
		bayer_pixal_n_10 <= bayer_pixal_n_24;
		bayer_pixal_n_11 <= bayer_pixal_n_23;
		bayer_pixal_n_12 <= bayer_pixal_n_22;
		bayer_pixal_n_13 <= bayer_pixal_n_23;
		bayer_pixal_n_14 <= bayer_pixal_n_24;
		bayer_pixal_n_15 <= bayer_pixal_n_14;
		bayer_pixal_n_16 <= bayer_pixal_n_13;
		bayer_pixal_n_17 <= bayer_pixal_n_13;
		bayer_pixal_n_18 <= bayer_pixal_n_14;
		bayer_pixal_n_19 <= g_data;
		bayer_pixal_n_20 <= bayer_pixal_n_18;
		bayer_pixal_n_21 <= bayer_pixal_n_17;
		bayer_pixal_n_22 <= bayer_pixal_n_17;
		bayer_pixal_n_23 <= bayer_pixal_n_18;
		bayer_pixal_n_24 <= bayer_pixal_n_19;
		bayer_new_n_central <= bayer_pixal_new_n_3;
		bayer_pixal_new_n_1 <= bayer_pixal_new_n_6;
		bayer_pixal_new_n_2 <= bayer_pixal_new_n_7;
		bayer_pixal_new_n_3 <= bayer_pixal_new_n_8;
		bayer_pixal_new_n_4 <= bayer_pixal_new_n_2;
		bayer_pixal_new_n_5 <= g_data;
		bayer_pixal_new_n_6 <= bayer_pixal_new_n_4;
		bayer_pixal_new_n_7 <= bayer_new_n_central;
		bayer_pixal_new_n_8 <= bayer_pixal_new_n_5;
	end
	/* 第一個鏡射5*5完成後 再讀進新的一排(5個data , 新的3個data去鏡射上面兩個data) */
	/* 其他的都往左移一位 依此類推 */
	else if(bayer_mode == 3'd2) begin
		bayer_n_central <= bayer_pixal_n_22;
		bayer_pixal_n_1 <= bayer_pixal_n_12;
		bayer_pixal_n_2 <= bayer_n_central;
		bayer_pixal_n_3 <= bayer_pixal_n_13;
		bayer_pixal_n_4 <= bayer_pixal_n_14;
		bayer_pixal_n_5 <= g_data;
		bayer_pixal_n_6 <= bayer_pixal_n_20;
		bayer_pixal_n_7 <= bayer_pixal_n_21;
		bayer_pixal_n_8 <= bayer_pixal_n_22;
		bayer_pixal_n_9 <= bayer_pixal_n_23;
		bayer_pixal_n_10 <= bayer_pixal_n_24;
		bayer_pixal_n_11 <= bayer_pixal_n_20;
		bayer_pixal_n_12 <= bayer_pixal_n_21;
		bayer_pixal_n_13 <= bayer_pixal_n_23;
		bayer_pixal_n_14 <= bayer_pixal_n_24;
		bayer_pixal_n_15 <= bayer_pixal_n_12;
		bayer_pixal_n_16 <= bayer_n_central;
		bayer_pixal_n_17 <= bayer_pixal_n_13;
		bayer_pixal_n_18 <= bayer_pixal_n_14;
		bayer_pixal_n_19 <= g_data;
		bayer_pixal_n_20 <= bayer_pixal_n_15;
		bayer_pixal_n_21 <= bayer_pixal_n_16;
		bayer_pixal_n_22 <= bayer_pixal_n_17;
		bayer_pixal_n_23 <= bayer_pixal_n_18;
		bayer_pixal_n_24 <= bayer_pixal_n_19;
		bayer_new_n_central <= bayer_pixal_new_n_3;
		bayer_pixal_new_n_1 <= bayer_pixal_new_n_6;
		bayer_pixal_new_n_2 <= bayer_pixal_new_n_7;
		bayer_pixal_new_n_3 <= bayer_pixal_new_n_8;
		bayer_pixal_new_n_4 <= bayer_pixal_new_n_2;
		bayer_pixal_new_n_5 <= g_data;
		bayer_pixal_new_n_6 <= bayer_pixal_new_n_4;
		bayer_pixal_new_n_7 <= bayer_new_n_central;
		bayer_pixal_new_n_8 <= bayer_pixal_new_n_5;
	end
	/* 倒數第二排的鏡射 ， */
	else if(bayer_mode == 3'd3) begin
		if(green_addr[7] | green_addr[8] | green_addr[9] | green_addr[10] | green_addr[11] | green_addr[12] | green_addr[13]) begin
			if(bayer_mirror_one) begin
				if(bayer_mirror_two) begin
					bayer_pixal_n_1 <= bayer_pixal_n_2;
					bayer_pixal_n_2 <= bayer_pixal_n_3;
					bayer_pixal_n_3 <= bayer_pixal_n_4;
					bayer_pixal_n_4 <= bayer_pixal_n_5;
					bayer_pixal_n_5 <= bayer_pixal_n_5;
					bayer_pixal_n_6 <= bayer_pixal_n_7;
					bayer_pixal_n_7 <= bayer_pixal_n_8;
					bayer_pixal_n_8 <= bayer_pixal_n_9;
					bayer_pixal_n_9 <= bayer_pixal_n_10;
					bayer_pixal_n_10 <= bayer_pixal_n_10;
				end
				else begin
					bayer_pixal_n_1 <= bayer_pixal_n_7;
					bayer_pixal_n_2 <= bayer_pixal_n_8;
					bayer_pixal_n_3 <= bayer_pixal_n_9;
					bayer_pixal_n_4 <= bayer_pixal_n_10;
					bayer_pixal_n_5 <= bayer_pixal_n_10;
					bayer_pixal_n_6 <= bayer_pixal_n_7;
					bayer_pixal_n_7 <= bayer_pixal_n_8;
					bayer_pixal_n_8 <= bayer_pixal_n_9;
					bayer_pixal_n_9 <= bayer_pixal_n_10;
					bayer_pixal_n_10 <= bayer_pixal_n_10;
				end
			end
		end
		else begin
			bayer_pixal_n_1 <= bayer_pixal_n_12;
			bayer_pixal_n_2 <= bayer_n_central;
			bayer_pixal_n_3 <= bayer_pixal_n_13;
			bayer_pixal_n_4 <= bayer_pixal_n_14;
			bayer_pixal_n_5 <= bayer_pixal_n_14;
			bayer_pixal_n_6 <= bayer_pixal_n_20;
			bayer_pixal_n_7 <= bayer_pixal_n_21;
			bayer_pixal_n_8 <= bayer_pixal_n_22;
			bayer_pixal_n_9 <= bayer_pixal_n_23;
			bayer_pixal_n_10 <= bayer_pixal_n_24;
		end
		bayer_n_central <= bayer_pixal_n_22;
		bayer_pixal_n_11 <= bayer_pixal_n_20;
		bayer_pixal_n_12 <= bayer_pixal_n_21;
		bayer_pixal_n_13 <= bayer_pixal_n_23;
		bayer_pixal_n_14 <= bayer_pixal_n_24;
		bayer_pixal_n_15 <= bayer_pixal_n_12;
		bayer_pixal_n_16 <= bayer_n_central;
		bayer_pixal_n_17 <= bayer_pixal_n_13;
		bayer_pixal_n_18 <= bayer_pixal_n_14;
		bayer_pixal_n_19 <= bayer_pixal_n_14;
		bayer_pixal_n_20 <= bayer_pixal_n_15;
		bayer_pixal_n_21 <= bayer_pixal_n_16;
		bayer_pixal_n_22 <= bayer_pixal_n_17;
		bayer_pixal_n_23 <= bayer_pixal_n_18;
		bayer_pixal_n_24 <= bayer_pixal_n_19;
		bayer_new_n_central <= bayer_pixal_new_n_3;
		bayer_pixal_new_n_1 <= bayer_pixal_new_n_6;
		bayer_pixal_new_n_2 <= bayer_pixal_new_n_7;
		bayer_pixal_new_n_3 <= bayer_pixal_new_n_8;
		bayer_pixal_new_n_4 <= bayer_pixal_new_n_2;
		bayer_pixal_new_n_5 <= g_data;
		bayer_pixal_new_n_6 <= bayer_pixal_new_n_4;
		bayer_pixal_new_n_7 <= bayer_new_n_central;
		bayer_pixal_new_n_8 <= bayer_pixal_new_n_5;
	end
	/*　最後一排的鏡射 */
	else if(bayer_mode == 3'd4) begin
		if(green_addr[7] | green_addr[8] | green_addr[9] | green_addr[10] | green_addr[11] | green_addr[12] | green_addr[13]) begin
			if(bayer_mirror_one) begin
				if(bayer_mirror_two) begin
					bayer_pixal_n_1 <= bayer_pixal_n_2;
					bayer_pixal_n_2 <= bayer_pixal_n_3;
					bayer_pixal_n_3 <= bayer_pixal_n_4;
					bayer_pixal_n_4 <= bayer_pixal_n_5;
					bayer_pixal_n_5 <= bayer_pixal_n_3;
					bayer_pixal_n_6 <= bayer_pixal_n_7;
					bayer_pixal_n_7 <= bayer_pixal_n_8;
					bayer_pixal_n_8 <= bayer_pixal_n_9;
					bayer_pixal_n_9 <= bayer_pixal_n_10;
					bayer_pixal_n_10 <= bayer_pixal_n_8;
				end
				else begin
					bayer_pixal_n_1 <= bayer_pixal_n_7;
					bayer_pixal_n_2 <= bayer_pixal_n_8;
					bayer_pixal_n_3 <= bayer_pixal_n_9;
					bayer_pixal_n_4 <= bayer_pixal_n_10;
					bayer_pixal_n_5 <= bayer_pixal_n_8;
					bayer_pixal_n_6 <= bayer_pixal_n_7;
					bayer_pixal_n_7 <= bayer_pixal_n_8;
					bayer_pixal_n_8 <= bayer_pixal_n_9;
					bayer_pixal_n_9 <= bayer_pixal_n_10;
					bayer_pixal_n_10 <= bayer_pixal_n_8;
				end
			end
		end
		else begin
			bayer_pixal_n_1 <= bayer_pixal_n_12;
			bayer_pixal_n_2 <= bayer_n_central;
			bayer_pixal_n_3 <= bayer_pixal_n_13;
			bayer_pixal_n_4 <= bayer_pixal_n_14;
			bayer_pixal_n_5 <= bayer_n_central;
			bayer_pixal_n_6 <= bayer_pixal_n_20;
			bayer_pixal_n_7 <= bayer_pixal_n_21;
			bayer_pixal_n_8 <= bayer_pixal_n_22;
			bayer_pixal_n_9 <= bayer_pixal_n_23;
			bayer_pixal_n_10 <= bayer_pixal_n_24;
		end
		bayer_n_central <= bayer_pixal_n_22;
		bayer_pixal_n_11 <= bayer_pixal_n_20;
		bayer_pixal_n_12 <= bayer_pixal_n_21;
		bayer_pixal_n_13 <= bayer_pixal_n_23;
		bayer_pixal_n_14 <= bayer_pixal_n_24;
		bayer_pixal_n_15 <= bayer_pixal_n_12;
		bayer_pixal_n_16 <= bayer_n_central;
		bayer_pixal_n_17 <= bayer_pixal_n_13;
		bayer_pixal_n_18 <= bayer_pixal_n_14;
		bayer_pixal_n_19 <= bayer_n_central;
		bayer_pixal_n_20 <= bayer_pixal_n_15;
		bayer_pixal_n_21 <= bayer_pixal_n_16;
		bayer_pixal_n_22 <= bayer_pixal_n_17;
		bayer_pixal_n_23 <= bayer_pixal_n_18;
		bayer_pixal_n_24 <= bayer_pixal_n_19;
		bayer_new_n_central <= bayer_pixal_new_n_3;
		bayer_pixal_new_n_1 <= bayer_pixal_new_n_6;
		bayer_pixal_new_n_2 <= bayer_pixal_new_n_7;
		bayer_pixal_new_n_3 <= bayer_pixal_new_n_8;
		bayer_pixal_new_n_4 <= bayer_pixal_new_n_2;
		bayer_pixal_new_n_5 <= g_data;
		bayer_pixal_new_n_6 <= bayer_pixal_new_n_4;
		bayer_pixal_new_n_7 <= bayer_new_n_central;
		bayer_pixal_new_n_8 <= bayer_pixal_new_n_5;
	end
	else if(bayer_mode == 3'd5) begin
		if(green_addr[8] | green_addr[9] | green_addr[10] | green_addr[11] | green_addr[12] | green_addr[13]) begin
			bayer_pixal_n_1 <= bayer_pixal_n_5;
			bayer_pixal_n_2 <= bayer_pixal_n_4;
			bayer_pixal_n_3 <= bayer_pixal_n_4;
			bayer_pixal_n_4 <= bayer_pixal_n_5;
			bayer_pixal_n_5 <= g_data_2;
			bayer_pixal_n_6 <= bayer_pixal_n_10;
			bayer_pixal_n_7 <= bayer_pixal_n_9;
			bayer_pixal_n_8 <= bayer_pixal_n_9;
			bayer_pixal_n_9 <= bayer_pixal_n_10;
			bayer_pixal_n_10 <= g_data_1;
		end
		else begin
			bayer_pixal_n_1 <= bayer_pixal_n_10;
			bayer_pixal_n_2 <= bayer_pixal_n_9;
			bayer_pixal_n_3 <= bayer_pixal_n_9;
			bayer_pixal_n_4 <= bayer_pixal_n_10;
			bayer_pixal_n_5 <= g_data_1;
			bayer_pixal_n_6 <= bayer_pixal_n_10;
			bayer_pixal_n_7 <= bayer_pixal_n_9;
			bayer_pixal_n_8 <= bayer_pixal_n_9;
			bayer_pixal_n_9 <= bayer_pixal_n_10;
			bayer_pixal_n_10 <= g_data_1;
		end
		bayer_n_central <= bayer_pixal_new_n_6;
		bayer_pixal_n_11 <= bayer_pixal_new_n_7;
		bayer_pixal_n_12 <= bayer_pixal_new_n_6;
		bayer_pixal_n_13 <= bayer_pixal_new_n_7;
		bayer_pixal_n_14 <= bayer_pixal_new_n_8;
		bayer_pixal_n_15 <= bayer_pixal_new_n_3;
		bayer_pixal_n_16 <= bayer_pixal_new_n_2;
		bayer_pixal_n_17 <= bayer_pixal_new_n_2;
		bayer_pixal_n_18 <= bayer_pixal_new_n_3;
		bayer_pixal_n_19 <= g_data;

		if(green_addr[7] & green_addr[8] & green_addr[9] & green_addr[10] & green_addr[11] & green_addr[12] & green_addr[13]) begin
			bayer_pixal_n_20 <= bayer_pixal_n_10;
			bayer_pixal_n_21 <= bayer_pixal_n_9;
			bayer_pixal_n_22 <= bayer_pixal_n_9;
			bayer_pixal_n_23 <= bayer_pixal_n_10;
			bayer_pixal_n_24 <= g_data_1;
		end
		else if(green_addr[8] & green_addr[9] & green_addr[10] & green_addr[11] & green_addr[12] & green_addr[13]) begin
			bayer_pixal_n_20 <= bayer_pixal_new_n_3;
			bayer_pixal_n_21 <= bayer_pixal_new_n_2;
			bayer_pixal_n_22 <= bayer_pixal_new_n_2;
			bayer_pixal_n_23 <= bayer_pixal_new_n_3;
			bayer_pixal_n_24 <= g_data;
		end
		else begin
			bayer_pixal_n_20 <= bayer_new_n_central;
			bayer_pixal_n_21 <= bayer_pixal_new_n_4;
			bayer_pixal_n_22 <= bayer_pixal_new_n_4;
			bayer_pixal_n_23 <= bayer_new_n_central;
			bayer_pixal_n_24 <= bayer_pixal_new_n_5;
		end
		bayer_new_n_central <= bayer_pixal_new_n_3;
		bayer_pixal_new_n_1 <= bayer_pixal_new_n_6;
		bayer_pixal_new_n_2 <= bayer_pixal_new_n_7;
		bayer_pixal_new_n_3 <= bayer_pixal_new_n_8;
		bayer_pixal_new_n_4 <= bayer_pixal_new_n_2;
		bayer_pixal_new_n_5 <= g_data;
		bayer_pixal_new_n_6 <= bayer_pixal_new_n_4;
		bayer_pixal_new_n_7 <= bayer_new_n_central;
		bayer_pixal_new_n_8 <= bayer_pixal_new_n_5;
	end
	else if(bayer_mode == 3'd6) begin
		if(bayer_mirror_one) begin
			if(bayer_mirror_two) begin
				bayer_pixal_n_1 <= bayer_pixal_n_2;
				bayer_pixal_n_2 <= bayer_pixal_n_3;
				bayer_pixal_n_3 <= bayer_pixal_n_4;
				bayer_pixal_n_4 <= bayer_pixal_n_5;
				bayer_pixal_n_5 <= g_data_2;
				bayer_pixal_n_6 <= bayer_pixal_n_7;
				bayer_pixal_n_7 <= bayer_pixal_n_8;
				bayer_pixal_n_8 <= bayer_pixal_n_9;
				bayer_pixal_n_9 <= bayer_pixal_n_10;
				bayer_pixal_n_10 <= g_data_1;
			end
			else begin
				bayer_pixal_n_1 <= bayer_pixal_n_7;
				bayer_pixal_n_2 <= bayer_pixal_n_8;
				bayer_pixal_n_3 <= bayer_pixal_n_9;
				bayer_pixal_n_4 <= bayer_pixal_n_10;
				bayer_pixal_n_5 <= g_data_1;
				bayer_pixal_n_6 <= bayer_pixal_n_7;
				bayer_pixal_n_7 <= bayer_pixal_n_8;
				bayer_pixal_n_8 <= bayer_pixal_n_9;
				bayer_pixal_n_9 <= bayer_pixal_n_10;
				bayer_pixal_n_10 <= g_data_1;
			end
		end
		/////////////////////////////////////////////////
		if(green_addr[7] & green_addr[8] & green_addr[9] & green_addr[10] & green_addr[11] & green_addr[12] & green_addr[13] && bayer_mirror_two) begin
			bayer_n_central <= bayer_pixal_n_22;
			bayer_pixal_n_11 <= bayer_pixal_n_20;
			bayer_pixal_n_12 <= bayer_pixal_n_21;
			bayer_pixal_n_13 <= bayer_pixal_n_23;
			bayer_pixal_n_14 <= bayer_pixal_n_24;
			bayer_pixal_n_15 <= bayer_pixal_n_12;
			bayer_pixal_n_16 <= bayer_n_central;
			bayer_pixal_n_17 <= bayer_pixal_n_13;
			bayer_pixal_n_18 <= bayer_pixal_n_14;
			bayer_pixal_n_19 <= g_data;
			bayer_pixal_n_20 <= bayer_pixal_n_7;
			bayer_pixal_n_21 <= bayer_pixal_n_8;
			bayer_pixal_n_22 <= bayer_pixal_n_9;
			bayer_pixal_n_23 <= bayer_pixal_n_10;
			bayer_pixal_n_24 <= g_data_1;
		end
		else if(green_addr[8] & green_addr[9] & green_addr[10] & green_addr[11] & green_addr[12] & green_addr[13] && bayer_mirror_two) begin
			bayer_n_central <= bayer_pixal_n_22;
			bayer_pixal_n_11 <= bayer_pixal_n_20;
			bayer_pixal_n_12 <= bayer_pixal_n_21;
			bayer_pixal_n_13 <= bayer_pixal_n_23;
			bayer_pixal_n_14 <= bayer_pixal_n_24;
			bayer_pixal_n_15 <= bayer_pixal_n_12;
			bayer_pixal_n_16 <= bayer_n_central;
			bayer_pixal_n_17 <= bayer_pixal_n_13;
			bayer_pixal_n_18 <= bayer_pixal_n_14;
			bayer_pixal_n_19 <= g_data;
			bayer_pixal_n_20 <= bayer_pixal_n_15;
			bayer_pixal_n_21 <= bayer_pixal_n_16;
			bayer_pixal_n_22 <= bayer_pixal_n_17;
			bayer_pixal_n_23 <= bayer_pixal_n_18;
			bayer_pixal_n_24 <= g_data;
		end
		else begin
			bayer_n_central <= bayer_pixal_n_22;
			bayer_pixal_n_11 <= bayer_pixal_n_20;
			bayer_pixal_n_12 <= bayer_pixal_n_21;
			bayer_pixal_n_13 <= bayer_pixal_n_23;
			bayer_pixal_n_14 <= bayer_pixal_n_24;
			bayer_pixal_n_15 <= bayer_pixal_n_12;
			bayer_pixal_n_16 <= bayer_n_central;
			bayer_pixal_n_17 <= bayer_pixal_n_13;
			bayer_pixal_n_18 <= bayer_pixal_n_14;
			bayer_pixal_n_19 <= g_data;
			bayer_pixal_n_20 <= bayer_pixal_n_15;
			bayer_pixal_n_21 <= bayer_pixal_n_16;
			bayer_pixal_n_22 <= bayer_pixal_n_17;
			bayer_pixal_n_23 <= bayer_pixal_n_18;
			bayer_pixal_n_24 <= bayer_pixal_n_19;
		end	
		bayer_new_n_central <= bayer_pixal_new_n_3;
		bayer_pixal_new_n_1 <= bayer_pixal_new_n_6;
		bayer_pixal_new_n_2 <= bayer_pixal_new_n_7;
		bayer_pixal_new_n_3 <= bayer_pixal_new_n_8;
		bayer_pixal_new_n_4 <= bayer_pixal_new_n_2;
		bayer_pixal_new_n_5 <= g_data;
		bayer_pixal_new_n_6 <= bayer_pixal_new_n_4;
		bayer_pixal_new_n_7 <= bayer_new_n_central;
		bayer_pixal_new_n_8 <= bayer_pixal_new_n_5;
	end
end

/* calculate Green pixal */

always @(*) begin
	if(rst) begin
		g_central = 14'd0;
		dh = 14'd0;
		dh_1 = 14'd0;
		dh_2_1 = 14'd0;
		dh_2_2 = 14'd0;
		dv = 14'd0;
		dv_1 = 14'd0;
		dv_2_1 = 14'd0;
		dv_2_2 = 14'd0;
		green_central = 14'd0;
		green_1 = 14'd0;
		green_2 = 14'd0;
		green_3 = 14'd0;
		green_4 = 14'd0;
		green_5 = 14'd0;
		green_6 = 14'd0;
		green_r_b = 14'd0;
	end
	else begin
		g_central = bayer_central << 1; 
		if(bayer_pixal_12 >= bayer_pixal_13) begin
			dh_1 = bayer_pixal_12 - bayer_pixal_13;
		end
		else begin 
			dh_1 = bayer_pixal_13 - bayer_pixal_12;
		end
		dh_2_1 = bayer_pixal_11 + bayer_pixal_14;
		if(g_central > dh_2_1 || g_central == dh_2_1) begin
			dh_2_2 = g_central - dh_2_1;
		end
		else begin
			dh_2_2 = dh_2_1 - g_central;
		end
		if(bayer_pixal_8 >= bayer_pixal_17) begin
			dv_1 = bayer_pixal_8 - bayer_pixal_17;
		end
		else begin
			dv_1 = bayer_pixal_17 - bayer_pixal_8;
		end	
		dv_2_1 = bayer_pixal_3 + bayer_pixal_22;
		if(g_central >= dv_2_1) begin
			dv_2_2 = g_central - dv_2_1;
		end
		else begin
			dv_2_2 = dv_2_1 - g_central;
		end
		dh = dh_1 + dh_2_2;
		dv = dv_1 + dv_2_2;

		green_central = bayer_central << 2;

		green_1 = (bayer_pixal_12 + bayer_pixal_13) << 2;
		green_2 = (bayer_pixal_12 + bayer_pixal_13 + bayer_pixal_8 + bayer_pixal_17) << 1;
		green_3 = (bayer_pixal_8 + bayer_pixal_17) << 2;

		green_4 = green_central - ((bayer_pixal_11 + bayer_pixal_14) << 1);
		
		green_5 = green_central - (bayer_pixal_11 + bayer_pixal_14 + bayer_pixal_3 + bayer_pixal_22);	
		
		green_6 = green_central - ((bayer_pixal_3 + bayer_pixal_22) << 1);

		if(dh < dv) begin
			if(green_4[13]) begin
				green_4 = ~green_4 + 1;
				green_r_b = green_1 - green_4;
				if(green_r_b[13]) begin
					green_r_b = ~green_r_b + 1;
				end
			end
			else begin
				green_r_b = green_1 + green_4;
			end
		end
		else if(dv < dh) begin
			if(green_6[13]) begin 
				green_6 = ~green_6 + 1;
				green_r_b = green_3 - green_6;
				if(green_r_b[13]) begin
					green_r_b = ~green_r_b + 1;
				end
			end
			else begin
				green_r_b = green_3 + green_6;
			end
		end
		else begin
			if(green_5[13]) begin
				green_5 = ~green_5 + 1;
				green_r_b = green_2 - green_5;	
				if(green_r_b[13]) begin
					green_r_b = ~green_r_b + 1;
				end
			end
			else begin
				green_r_b = green_2 + green_5;
			end
		end
	end
end      

//////////////////////////////////
// calculate blue and red pixal //
//////////////////////////////////

always @(*) begin
	if(rst) begin
		b_r_central = 14'd0;
		dn = 14'd0;
		dn_1 = 14'd0;
		dn_2_1 = 14'd0;
		dn_2_2 = 14'd0;
		dp = 14'd0;
		dp_1 = 14'd0;
		dp_2_1 = 14'd0;
		dp_2_2 = 14'd0;
		br_central = 14'd0;
		br_1 = 14'd0;
		br_2 = 14'd0;
		br_3 = 14'd0;
		br_4 = 14'd0;
		br_5 = 14'd0;
		br_6 = 14'd0;
		br_g = 14'd0;
	end
	else begin
		if(bayer_pixal_n_7 == 0) begin
			bayer_pixal_n_7 = bayer_pixal_7 << 3;
		end
		if(bayer_pixal_n_9 == 0) begin
			bayer_pixal_n_9 = bayer_pixal_9 << 3;
		end
		if(bayer_pixal_n_16 == 0) begin
			bayer_pixal_n_16 = bayer_pixal_16 << 3;
		end
		if(bayer_pixal_n_18 == 0) begin
			bayer_pixal_n_18 = bayer_pixal_18 << 3;
		end
		if(bayer_n_central == 0) begin
			bayer_n_central = bayer_central << 3;
		end
		b_r_central = bayer_n_central >> 2;
		if(bayer_pixal_7 >= bayer_pixal_18) begin
			dn_1 = bayer_pixal_7 - bayer_pixal_18;
		end
		else begin
			dn_1 = bayer_pixal_18 - bayer_pixal_7;
		end
		dn_2_1 = (bayer_pixal_n_7 + bayer_pixal_n_18) >> 3;
		if(b_r_central >= dn_2_1) begin
			dn_2_2 = b_r_central - dn_2_1;
		end
		else begin
			dn_2_2 = dn_2_1 - b_r_central;
		end
		if(bayer_pixal_9 >= bayer_pixal_16) begin
			dp_1 = bayer_pixal_9 - bayer_pixal_16;
		end
		else begin
			dp_1 = bayer_pixal_16 - bayer_pixal_9;
		end
		dp_2_1 = (bayer_pixal_n_9 + bayer_pixal_n_16) >> 3;
		if(b_r_central >= dp_2_1) begin
			dp_2_2 = b_r_central - dp_2_1;
		end
		else begin
			dp_2_2 = dp_2_1 - b_r_central;
		end
		dn = dn_1 + dn_2_2;
		dp = dp_1 + dp_2_2;

		br_central = bayer_n_central >> 1;

		br_1 = (bayer_pixal_7 + bayer_pixal_18) << 1;
		br_2 = (bayer_pixal_7 + bayer_pixal_9 + bayer_pixal_16 + bayer_pixal_18);
		br_3 = (bayer_pixal_9 + bayer_pixal_16) << 1; 

		br_4 = br_central - ((bayer_pixal_n_7 + bayer_pixal_n_18) >> 2);
		br_5 = br_central - ((bayer_pixal_n_7 + bayer_pixal_n_9 + bayer_pixal_n_16 + bayer_pixal_n_18) >> 3);
		br_6 = br_central - ((bayer_pixal_n_9 + bayer_pixal_n_16) >> 2);

		if(dn < dp) begin
			if(br_4[13]) begin
				br_4 = ~br_4 + 1;
				br_g = br_1 - br_4;
				if(br_g[13]) begin
					br_g = ~br_g + 1;
				end
			end
			else begin
				br_g = br_1 + br_4;
			end
		end
		else if(dp < dn) begin
			if(br_6[13]) begin
				br_6 = ~br_6 + 1;
				br_g = br_3 - br_6;
				if(br_g[13]) begin
					br_g = ~br_g + 1;
				end
			end
			else begin
				br_g = br_3 + br_6;
			end
		end
		else begin
			if(br_5[13]) begin
				br_5 = ~br_5 + 1;
				br_g = br_2 - br_5;	
				if(br_g[13]) begin
					br_g = ~br_g + 1;
				end
			end
			else begin
				br_g = br_2 + br_5;
			end
		end
	end
end

always @(*) begin
	if(rst) begin
		r_cen_1 = 14'd0;
		r_cen_2 = 14'd0;
		r_1 = 14'd0;
		r_2 = 14'd0;
		r_3 = 14'd0;
		r_4 = 14'd0;
		r_1_3 = 14'd0;
		r_2_4 = 14'd0;
	end
	else begin
		r_1 = ((bayer_pixal_7 + bayer_pixal_9) << 1);
		r_2 = ((bayer_pixal_9 + bayer_pixal_18) << 1);
		r_cen_1 = bayer_pixal_8 << 2;
		r_cen_2 = bayer_pixal_13 << 2;
		r_3 = r_cen_1 - ((bayer_pixal_n_7 + bayer_pixal_n_9) >> 2);
		r_4 = r_cen_2 - ((bayer_pixal_n_9 + bayer_pixal_n_18) >> 2);

		if(r_3[13]) begin
			r_3 = ~r_3 + 1;
			r_1_3 = r_1 - r_3;
			if(r_1_3[13]) begin
				r_1_3 = ~r_1_3 + 1;
			end
		end
		else begin
			r_1_3 = r_1 + r_3;
		end

		if(r_4[13]) begin
			r_4 = ~r_4 + 1;
			r_2_4 = r_2 - r_4;
			if(r_2_4[13]) begin
				r_2_4 = ~r_2_4 + 1;
			end
		end
		else begin
			r_2_4 = r_2 + r_4;
		end
	end
end

always @(*) begin
	if(rst) begin
		b_cen_1 = 14'd0;
		b_cen_2 = 14'd0;
		b_1 = 14'd0;
		b_2 = 14'd0;
		b_3 = 14'd0;
		b_4 = 14'd0;
		b_1_3 = 14'd0;
		b_2_4 = 14'd0;
	end
	else begin
		b_1 = ((bayer_pixal_16 + bayer_pixal_18) << 1);
		b_2 = ((bayer_pixal_7 + bayer_pixal_16) << 1);
		b_cen_1 = bayer_pixal_17 << 2;
		b_cen_2 = bayer_pixal_12 << 2;
		b_3 = b_cen_1 - ((bayer_pixal_n_16 + bayer_pixal_n_18) >> 2);
		b_4 = b_cen_2 - ((bayer_pixal_n_16 + bayer_pixal_n_7) >> 2);

		if(b_3[13]) begin
			b_3 = ~b_3 + 1;
			b_1_3 = b_1 - b_3;
			if(b_1_3[13]) begin
				b_1_3 = ~b_1_3 + 1;
			end
		end
		else begin
			b_1_3 = b_1 + b_3;
		end

		if(b_4[13]) begin
			b_4 = ~b_4 + 1;
			b_2_4 = b_2 - b_4;
			if(b_2_4[13]) begin
				b_2_4 = ~b_2_4 + 1;
			end
		end
		else begin
			b_2_4 = b_2 + b_4;
		end
	end
end

endmodule
