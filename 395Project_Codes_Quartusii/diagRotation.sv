module diagRotation(input 				Clk,
												Reset,
												Run,
										
						 input [79:0]		subkey,
						 
						 output				done,
												key_ack,
												SRAM_DQ_imp,
						 				
						 // Memory interface
						 input [15:0]		SRAM_DQ_in,
						 output [15:0]		SRAM_DQ_out,
						 output [19:0]		SRAM_ADDR,
						 output				SRAM_OE_N,
												SRAM_WE_N
						 );
			
		logic [15:0] subblock [0:31][0:31];  //[y][x]

		logic [4:0] block_x;		//Up to 20
		logic [3:0] block_y;		//Up to 15
		
		logic [4:0] x, y; 		//For referencing pixels inside subblock
		
		logic [79:0] curr_subkey;
		
		enum logic [2:0] {WAIT, LOAD_KEY, LOAD_BLOCK, SHIFT, WRITE_BLOCK} state, next_state;
		
		always_ff @ (posedge Clk or posedge Reset)
		begin
				if(Reset == 1'b1)
				begin
						for(int i = 0; i < 32; i++)
								for(int j = 0; j < 32; j++)
										subblock[i][j] <= 16'b0;
						block_x <= 5'b0;
						block_y <= 4'b0;
						x <= 5'b0;
						y <= 5'b0;
						curr_subkey <= 80'b0;
						state <= WAIT;
				end 
				else begin
						state <= next_state;
						unique case(state)
						WAIT: begin 
								block_x <= 5'b0;
								block_y <= 4'b0;
								x <= 5'b0;
								y <= 5'b0;
								curr_subkey <= 80'b0;
						end 
						LOAD_KEY: begin
								if(block_y[1:0] == 2'b00)
										curr_subkey <= subkey;
						end 
						LOAD_BLOCK: begin
								x <= x + 1'b1;
								if(x == 5'd31)
										y <= y + 1'b1;
								subblock[y][x] <= SRAM_DQ_in;
						end 
						SHIFT: begin
								x <= 5'b0;
								y <= 5'b0;
								curr_subkey <= {curr_subkey[78:0], 1'b0};
								
								if(curr_subkey[79] == 1'b0)
								begin
										for(int i = 0; i < 31; i++)
										begin
												subblock[0][i] <= subblock[31-i][31];
												subblock[i+1][0] <= subblock[31][30-i];
										end 
										for(int i = 1; i < 32; i++)
												for(int j = 1; j < 32; j++)
														subblock[i][j] <= subblock[i-1][j-1];
								end 
								else begin
										for(int i = 0; i < 31; i++)
										begin
												subblock[0][31-i] <= subblock[31-i][0];
												subblock[i+1][31] <= subblock[31][i+1];
										end 
										for(int i = 1; i < 32; i++)
												for(int j = 0; j < 31; j++)
														subblock[i][j] <= subblock[i-1][j+1];
								end 
						end 
						WRITE_BLOCK: begin
								x <= x + 1'b1;
								if(x == 5'd31)
								begin 
										y <= y + 1'b1;
										if(y == 5'd31)
										begin
												if(block_x == 5'd19)
												begin
														block_x <= 5'b0;
														block_y <= block_y + 1'b1;
												end 
												else
														block_x <= block_x + 1'b1;
										end 
								end 
						end 
						endcase
				end 
		end
	
		always_comb
		begin
				SRAM_DQ_imp = 1'b1;
				SRAM_ADDR = 20'b0;
				SRAM_DQ_out = 16'b0;
				SRAM_OE_N = 1'b1;
				SRAM_WE_N = 1'b1;
				
				done = 1'b0;
				key_ack = 1'b0;
				next_state = state;
				
				unique case(state)
				WAIT: begin
						if(Run == 1'b1)
								next_state = LOAD_KEY;
				end 
				LOAD_KEY: begin
						if(block_y == 5'd15)
						begin
								next_state = WAIT;
								done = 1'b1;
						end 
						else begin 
								if(block_y[1:0] == 2'b00)
										key_ack = 1'b1;		
						end 
						next_state = LOAD_BLOCK;
				end 
				LOAD_BLOCK: begin
						SRAM_ADDR = 20'd640*(6'd32*block_y + y) + 6'd32*block_x + x;
						SRAM_OE_N = 1'b0;
						if(x == 5'd31 && y == 5'd31)
								next_state = SHIFT;
				end 
				SHIFT: begin
						next_state = WRITE_BLOCK;
				end 
				WRITE_BLOCK: begin
						SRAM_ADDR = 20'd640*(6'd32*block_y + y) + 6'd32*block_x + x;
						SRAM_DQ_imp = 1'b0;
						SRAM_DQ_out = subblock[y][x];
						SRAM_WE_N = 1'b0;
						if(x == 5'd31 && y == 5'd31 && block_x == 5'd19)
								next_state = LOAD_KEY;
				end 
				endcase
		end 
			
endmodule 