/*
Author: Jihoon Lee, Zachary Splingaire
Date: 5/8/2016
Module: quadMap
Function :	80 bit Key encryption through QuadMap Algorithm

Input: 80 bit key
output : Encryptiod 80 bit key
*/

module quadMap(input 						Clk,
													Reset,
													Run,
					 input [79:0]				in,
					 output logic [79:0]		out,
					 output						done);
			

		logic [79:0] op1, op2, mult_out;
		logic multiply, mult_done;
		
		enum logic [1:0] {LOAD, COMPUTE, ADD, HOLD} state, next_state;
		
		multiplier80 mult(.Clk(Clk), .Reset(Reset), .Run(multiply), .num1(op1), .num2(op2), .out(mult_out), .done(mult_done));
		
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
						COMPUTE: begin
								if(mult_done == 1'b1)
										out <= mult_out;
						end 
						ADD: begin
								out <= out + 80'h30000000000000000000; // Add c = 3/8
						end 
						HOLD: begin
						
						end 
						endcase
				end 
		end 
		
		always_comb
		begin
				multiply = 1'b0;
				done = 1'b0;
				op1 = out;
				op2 = out;
				unique case(state)
				LOAD: begin
						if(Run == 1'b1)
								next_state = COMPUTE;
						else
								next_state = LOAD;
				end 
				// Encryption CORE
				COMPUTE: begin
						multiply = 1'b1;
						if(mult_done == 1'b1)
								next_state = ADD;
						else
								next_state = COMPUTE;
				end 
				ADD: begin
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