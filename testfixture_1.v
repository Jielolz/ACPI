`define CYCLE      12.5          	  // Modify your clock period here
`define SDFFILE    "./SYN/ACPI_syn.sdf"	  // Modify your sdf file name
`define End_CYCLE  100000000000              // Modify cycle times once your design need more cycle times!

`define PAT        "./lena_128x128_bayer_cfa.dat"    
module testfixture_1;

parameter N_PAT = 16384; // 128 x 128 pixel
parameter MEM = 128;

reg [7:0] bayer_mem [0:N_PAT-1];

wire [13:0] acpi_data;
reg   clk = 0;
reg   rst = 0;

wire [14:0] bayer_addr;
wire [13:0] bayer_addr_1;
wire [13:0] bayer_addr_2;
wire [13:0] acpi_addr;
reg [7:0] bayer_data;
reg [7:0] bayer_data_1;
reg [7:0] bayer_data_2;
reg bayer_ready = 0;
integer out;
//reg [7:0] ACPI;
integer i;

		ACPI ACPI( .clk(clk), .rst(rst), .bayer_data_1(bayer_data_1), .bayer_addr_2(bayer_addr_2), .bayer_data_2(bayer_data_2),
						.bayer_addr(bayer_addr), .bayer_addr_1(bayer_addr_1), .bayer_mirror(bayer_mirror), .bayer_mirror_one(bayer_mirror_one), .bayer_mirror_two(bayer_mirror_two), .bayer_req(bayer_req), .bayer_ready(bayer_ready), .bayer_data(bayer_data), 
						.acpi_addr(acpi_addr), .acpi_valid(acpi_valid), .acpi_valid_1(acpi_valid_1), .acpi_data(acpi_data), .finish(finish));
			
	 acpi_mem u_acpi_mem(.acpi_valid_1(acpi_valid_1), .acpi_data(acpi_data), .acpi_addr(acpi_addr), .clk(clk));
	 

`ifdef SDF
	initial $sdf_annotate(`SDFFILE, ACPI);
`endif

initial	$readmemh (`PAT, bayer_mem);


always begin 
	#(`CYCLE/2) clk = ~clk; 
end

initial begin
	$dumpfile("ACPI1111.vcd");
	$dumpvars;
end

initial begin
	wait(finish);
	out = $fopen("green.dat");
	for(i = 0 ; i < 16384; i = i+1) begin
		$fwrite(out,"%h\n",u_acpi_mem.ACPI_M[i]);
	end
	$fclose(out);
	
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
	bayer_data='h0; 
	#100 $finish;
end
endmodule
