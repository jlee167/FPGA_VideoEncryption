module encryptor (	input clk, wren,
							//input [7:0] R, G, B,
							output [7:0] R_OUT,G_OUT,B_OUT);

logic [31:0] R_prev, G_prev, B_prev;
wire [31:0] R_xor1, G_xor1, B_xor1;
wire [31:0] R_xor2, G_xor2, B_xor2;

assign R_xor1 = R_prev ^ (R_prev << 13);
assign G_xor1 = G_prev ^ (G_prev << 13);
assign B_xor1 = B_prev ^ (B_prev << 13);

assign R_xor2 = R_xor1 ^ (R_xor1 >> 7);
assign G_xor2 = G_xor1 ^ (G_xor1 >> 7);
assign B_xor2 = B_xor1 ^ (B_xor1 >> 7);


always @ ( posedge clk && wren )
begin
	if (R_prev == 32'd0)
		R_prev <= 32'd33;
	else
		R_prev <= R_xor2 ^ ( R_xor2 << 5); 
		
	if (G_prev == 32'd0)
		G_prev <= 32'd63;
	else
		G_prev <= G_xor2 ^ ( G_xor2 << 5); 
		
	if (B_prev == 32'd0)
		B_prev <= 32'd11;
	else
		B_prev <= B_xor2 ^ ( B_xor2 << 5); 
end

assign R_OUT = R_prev[7:0];
assign G_OUT = G_prev[7:0];
assign B_OUT = B_prev[7:0];

endmodule