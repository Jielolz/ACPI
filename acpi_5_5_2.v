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

`define STATE_INPUT	 2'd0
`define STATE_CAL 	 2'd1
`define STATE_OUTPUT 2'd2
`define STATE_IDLE	 2'd3

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

reg [1:0] state, next_state;
reg [3:0] entries_filled;

// FSM , counter

always @(posedge clk or posedge rst) begin
	if(rst)
		state <= `STATE_INPUT;
	else
		state <= next_state;
end

always@(*) begin
	case(state) 
		`STATE_INPUT: begin // 00
			if(entries_filled == 4'd8)
				nxt_state = `STATE_CAL; // 01
			else
				nxt_state = `STATE_INPUT; // 00
		end
		`STATE_CAL: begin // 01
			nxt_state = `STATE_OUTPUT; // 10
		end
		`STATE_OUTPUT: begin // 10
			nxt_state = `STATE_INPUT; // 00
		end
		`STATE_IDLE: begin // 11
			nxt_state = `STATE_IDLE; // 11
		end
		default: nxt_state = `STATE_IDLE; // 11
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
		entries_filled <= 4'd0;
	end
	else if(gray_ready) begin
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

always@(posedge clk or posedge rst) begin
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
		apci_addr <= 14'd129;
	end
	else begin
		acpi_addr <= next_acpi_addr;
	end
end

always @(*) begin
	if(apci_valid) begin
		if(acpi_addr[6] & acpi_addr[5] & acpi_addr[4] & acpi_addr[3] & acpi_addr[2] & acpi_addr[1]) begin
			next_acpi_addr = acpi_addr + 3;
		end
		else begin
		 	next_acpi_addr = acpi_addr + 1;
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
		if(acpi_addr == 16254)
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
	end
	else begin
		bayer_central <= bayer_pixal_22;
		bayer_pixal_1 <= bayer_pixal_14;
		bayer_pixal_2 <= bayer_pixal_13;
		bayer_pixal_3 <= bayer_pixal_13;
		bayer_pixal_4 <= bayer_pixal_14;
		bayer_pixal_5 <= bayer_gray;
		bayer_pixal_6 <= bayer_pixal_23;
		bayer_pixal_7 <= bayer_centra22;
		bayer_pixal_8 <= bayer_centra22;
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
		bayer_pixal_19 <= gray_data;
		bayer_pixal_20 <= bayer_pixal_18;
		bayer_pixal_21 <= bayer_pixal_17;
		bayer_pixal_22 <= bayer_pixal_17;
		bayer_pixal_23 <= bayer_pixal_18;
		bayer_pixal_24 <= bayer_pixal_19;
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