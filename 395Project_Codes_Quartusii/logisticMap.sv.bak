/*
Author: Jihoon Lee, Zachary Splingaire
Date: 5/8/2016
Module: LogicticMap
Function :	80 bit Key encryption through Logistic Map Algorithm

Input: 80 bit key
output : Encryptiod 80 bit key
*/

module logisticMap(input 						Clk,
														Reset,
														Run,
						 input [79:0]				in,
						 output logic [79:0]		out,
						 output						done);
			

		logic [79:0] op1, op2, mult_out;
		logic multiply, mult_done;
		
		enum logic [2:0] {WAIT, COMPUTE1, PAUSE, COMPUTE2, SHIFT, HOLD} state, next_state;
		
		multiplier80 mult(.Clk(Clk), .Reset(Reset), .Run(multiply), .num1(op1), .num2(op2), .out(mult_out), .done(mult_done));
		
		always_ff @ (posedge Clk or posedge Reset)
		begin
				if(Reset == 1'b1)
				begin
						state <= WAIT;
						out <= 80'b0;
				end 
				else begin
						state <= next_state;
						unique case(state)
						WAIT: begin
								if(Run == 1'b1)
										out <= in;
						end 

						COMPUTE1: begin
								
						end 
						PAUSE: begin 
								out <= mult_out;
						end
						// Encryption CORE
						COMPUTE2: begin
								if(mult_done == 1'b1)
										out <= mult_out[78:0];
						end  
						SHIFT: begin
								out <= {out[78:0], 1'b0};
						end 
						HOLD: begin
						
						end 
						endcase
				end 
		end 
		
		always_comb
		begin
				done = 1'b0;
				multiply = 1'b0;
				unique case(state)
				WAIT: begin
						op1 = out;
						op2 = 80'h80000000000000000000 - out;
						multiply = 1'b0;
						if(Run == 1'b1)
								next_state = COMPUTE1;
						else
								next_state = WAIT;
				end 
				COMPUTE1: begin
						op1 = out;
						op2 = 80'h80000000000000000000 - out;
						multiply = 1'b1;
						if(mult_done == 1'b1)
						begin 
								next_state = PAUSE;
						end 
						else begin
								next_state = COMPUTE1;
						end 
				end 
				PAUSE: begin
						multiply = 1'b0;
						op1 = out;
						op2 = 80'hF0000000000000000000;
						next_state = COMPUTE2;
				end 
				COMPUTE2: begin
						op1 = out;
						op2 = 80'hF0000000000000000000;   // 1.875
						multiply = 1'b1;
						if(mult_done == 1'b1)
						begin
								next_state = SHIFT;
						end 
						else begin
								next_state = COMPUTE2;
						end 
				end 
				SHIFT: begin
						op1 = 80'b0;
						op2 = 80'b0;
						next_state = HOLD;
				end 
				HOLD: begin
						op1 = out;
						op2 = 80'b0;
						multiply = 1'b0;
						done = 1'b1;
						if(Run == 1'b1)
								next_state = HOLD;
						else
								next_state = WAIT;
				end 
				endcase
		end 
			
endmodule 