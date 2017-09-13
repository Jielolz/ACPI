`define CYCLE      12.5          	  // Modify your clock period here

`define PAT        "./lena_128x128_bayer_cfa.dat"    
module testfixture_1;

parameter N_PAT = 16384; // 128 x 128 pixel
parameter MEM = 128;

reg [7:0] bayer_mem [0:N_PAT-1];

wire [13:0] green_data;
wire [13:0] blue_data;
wire [13:0] b_data_1;
wire [13:0] b_data_2;
wire [13:0] r_data_1;
wire [13:0] r_data_2;
reg   clk = 0;
reg   rst = 0;

wire [14:0] bayer_addr;
wire [13:0] bayer_addr_1;
wire [13:0] bayer_addr_2;
wire [13:0] green_addr;
wire [13:0] blue_red_addr;
wire [13:0] b_addr_1;
wire [13:0] b_addr_2;
wire [13:0] r_addr_1;
wire [13:0] r_addr_2;
reg [7:0] bayer_data;
reg [13:0] g_data;
reg [13:0] g_data_1;
reg [13:0] g_data_2;
reg [7:0] bayer_data_1;
reg [7:0] bayer_data_2;
reg bayer_ready = 0;
integer green, blue, red;
//reg [7:0] ACPI;
integer i;

		ACPI ACPI( .clk(clk), .rst(rst), .bayer_data_1(bayer_data_1), .bayer_addr_2(bayer_addr_2), .bayer_data_2(bayer_data_2), .g_data(g_data), .g_data_1(g_data_1), .g_data_2(g_data_2), .b_addr_1(b_addr_1), .b_addr_2(b_addr_2), .b_data_1(b_data_1), .b_data_2(b_data_2), .r_addr_1(r_addr_1), .r_addr_2(r_addr_2), .r_data_1(r_data_1), .r_data_2(r_data_2),
						.bayer_addr(bayer_addr), .bayer_addr_1(bayer_addr_1), .bayer_mirror(bayer_mirror), .bayer_mirror_one(bayer_mirror_one), .bayer_mirror_two(bayer_mirror_two), .bayer_req(bayer_req), .bayer_ready(bayer_ready), .bayer_data(bayer_data), 
						.green_addr(green_addr), .blue_red_addr(blue_red_addr), .green_valid(green_valid), .blue_valid(blue_valid), .red_valid(red_valid), .green_data(green_data), .blue_data(blue_data), .finish(finish), .finish_rb(finish_rb));
			
	 green_mem u_green_mem(.green_valid(green_valid), .green_data(green_data), .green_addr(green_addr), .clk(clk));
	 blue_mem u_blue_mem(.blue_valid(blue_valid), .blue_data(blue_data), .b_addr_1(b_addr_1), .b_addr_2(b_addr_2), .b_data_1(b_data_1), .b_data_2(b_data_2), .blue_red_addr(blue_red_addr), .clk(clk));
	 red_mem u_red_mem(.red_valid(red_valid), .blue_data(blue_data), .r_addr_1(r_addr_1), .r_addr_2(r_addr_2), .r_data_1(r_data_1), .r_data_2(r_data_2), .blue_red_addr(blue_red_addr), .clk(clk));

initial	$readmemh (`PAT, bayer_mem);


always begin 
	#(`CYCLE/2) clk = ~clk; 
end

initial begin
	$dumpfile("ACPI1111.vcd");
	$dumpvars;
end

initial begin
	wait(finish_rb);
	green = $fopen("green.dat");
	blue = $fopen("blue.dat");
	red = $fopen("red.dat");
	for(i = 0 ; i <= 16383; i = i+1) begin
		$fwrite(green,"%h\n",u_green_mem.GREEN_M[i]);
		$fwrite(blue,"%h\n",u_blue_mem.BLUE_M[i]);
		$fwrite(red,"%h\n",u_red_mem.RED_M[i]);
	end
	$fclose(green);
	$fclose(blue);
	$fclose(red);
end

initial begin  // data input
	@(negedge clk)  rst = 1'b1; 
	#(`CYCLE*2);    rst = 1'b0; 
	@(negedge clk)  bayer_ready = 1'b1;
	while (finish == 0) begin             
		if(bayer_req) begin
			if(bayer_addr > 16383) begin
				bayer_data <= bayer_data;
			end
			else begin
				bayer_data = bayer_mem[bayer_addr];
			end 
			bayer_data_1 = bayer_mem[bayer_addr_1]; 
			bayer_data_2 = bayer_mem[bayer_addr_2];
		end 
		else begin
			bayer_data_1 = 'h0;
			bayer_data = 'h0;  
		end                    
		@(negedge clk); 
	end     
	bayer_ready = 0;
	bayer_data = 'h0;

/////////////////////////////////
//                             //
//  red and blue interpolation //
//                             //
/////////////////////////////////

	@(negedge clk)  rst = 1'b1; 
	#(`CYCLE*2);    rst = 1'b0; 
	@(negedge clk)  bayer_ready = 1'b1;
	while (finish == 0) begin             
		if(bayer_req) begin
			if(bayer_addr > 16383) begin
				bayer_data <= bayer_data;
				g_data <= g_data;
			end
			else begin
				bayer_data = bayer_mem[bayer_addr];
				g_data = u_green_mem.GREEN_M[bayer_addr];
			end 
			bayer_data_1 = bayer_mem[bayer_addr_1]; 
			bayer_data_2 = bayer_mem[bayer_addr_2];
			g_data_1 = u_green_mem.GREEN_M[bayer_addr_1];
			g_data_2 = u_green_mem.GREEN_M[bayer_addr_2];
		end 
		else begin
			bayer_data_1 = 'h0;
			bayer_data = 'h0;  
			g_data_1 = 'h0;
			g_data = 'h0;
		end                    
		@(negedge clk); 
	end     
	bayer_ready = 0;
	bayer_data = 'h0;
	g_data = 'h0;  


	#1000 $finish;
end
endmodule

module green_mem (green_valid, green_data, green_addr, clk);
input		 green_valid;
input [13:0] green_addr;
input [13:0] green_data;
input		 clk;

reg [15:0] GREEN_M [0:16383];
integer i;

initial begin
	for (i=0; i<=16383; i=i+1)
		GREEN_M[i] = 0;
end

always @(negedge clk)
	if (green_valid) 
		GREEN_M[green_addr] <= green_data;

endmodule

module blue_mem (blue_valid, blue_data, b_data_1, b_data_2, b_addr_1, b_addr_2, blue_red_addr, clk);
input 		 blue_valid;
input [13:0] blue_red_addr;
input [13:0] b_addr_1;
input [13:0] b_addr_2;
input [13:0] blue_data;
input [13:0] b_data_1;
input [13:0] b_data_2;
input 		 clk;

reg [15:0] BLUE_M [0:16383];

integer i;

initial begin
	for (i=0; i<=16383; i=i+1)
		BLUE_M[i] = 0;
end

always @(negedge clk) begin
	if (blue_valid) begin
		BLUE_M[blue_red_addr] <= blue_data;
		BLUE_M[b_addr_1] <= b_data_2;
		BLUE_M[b_addr_2] <= b_data_1;
	end
end
endmodule

module red_mem (red_valid, blue_data, r_data_1, r_data_2, r_addr_1, r_addr_2, blue_red_addr, clk);
input 		 red_valid;
input [13:0] blue_red_addr;
input [13:0] r_addr_1;
input [13:0] r_addr_2;
input [13:0] blue_data;
input [13:0] r_data_1;
input [13:0] r_data_2;
input 		 clk;

reg [15:0] RED_M [0:16383];
integer i;

initial begin
	for (i=0; i<=16383; i=i+1)
		RED_M[i] = 0;
end

always @(negedge clk) begin
	if (red_valid) begin
		RED_M[blue_red_addr] <= blue_data;
		RED_M[r_addr_1] <= r_data_1;
		RED_M[r_addr_2] <= r_data_2;
	end
end
endmodule
