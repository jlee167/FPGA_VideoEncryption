/*
Author: Jihoon Lee, Zachary Splingaire
Date: 5/8/2016
Module: Bern
Function :	80 bit Key encryption through Bernouile Map Algorithm

Input: 80 bit key
output : Encryptiod 80 bit key
*/

module bernMap(input 						Clk,
													Reset,
													Run,
					 input [79:0]				in,
					 output logic [79:0]		out,
					 output						done);
			
		
		enum logic [1:0] {LOAD, COMPUTE, HOLD} state, next_state;
				
		always_ff @ (posedge Clk or posedge Reset)
		begin
				if(Reset == 1'b1)
				begin
						out <= 80'b0;
						state <= LOAD;
				end 
				else begin
						state <= next_state;
						unique case(state)
						LOAD: begin
								if(Run == 1'b1)
										out <= in;
						end 
						// Encryption CORE
						COMPUTE: begin
								if(out < 80'h40000000000000000000)
										out <= {out[78:0], 1'b0};
								else
										out <= {out[78:0], 1'b0} + 80'h80000000000000000000;
						end 
						HOLD: begin
						
						end 
						endcase
				end 
		end 
		
		always_comb
		begin
				done = 1'b0;
				unique case(state)
				LOAD: begin
						if(Run == 1'b1)
								next_state = COMPUTE;
						else
								next_state = LOAD;
				end 
				COMPUTE: begin
						next_state = HOLD;
				end 
				HOLD: begin
						done = 1'b1;
						if(Run == 1'b1)
								next_state = HOLD;
						else
								next_state = LOAD;
				end 
				endcase
		end 
		
endmodule 