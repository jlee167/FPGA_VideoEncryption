/*
Author: Jihoon Lee, Zachary Splingaire
Date: 5/8/2016
Module: Multiplier80
Function :	Simple 80 bit Multiplication module
Input: 80 bit key
output : Encryptiod 80 bit key
*/

module multiplier80(input 						Clk,
														Reset,
														Run,
						  input [79:0] 			num1,
														num2,
						  output						done,
						  output logic [79:0]	out);
			
		logic [9:0] counter;
		logic [79:0] shifter, checker;
		
		enum logic {WAIT, MULTIPLY} state, next_state;
			
		always_ff @ (posedge Clk or posedge Reset)
		begin
				if(Reset == 1'b1)
				begin
						counter <= 10'b0;
						state <= WAIT;
						out <= 80'b0;
				end 
				else begin
						state <= next_state;
						case(state)
						WAIT: begin
								checker <= num1;
								shifter <= num2;
								counter <= 10'b0;
								if(Run == 1'b1)
										out <= 80'b0;		//Clear sum for next calculation.
						end 
						MULTIPLY: begin
								counter++;
								if(checker[79] == 1'b1)
										out += shifter;
								checker <= {checker[78:0], 1'b0};
								shifter <= {1'b0, shifter[79:1]};
						end 
						endcase
				end 
		end 
			
		always_comb
		begin
				case(state)
				WAIT: begin
						done = 1'b0;
						if(Run == 1'b1)
								next_state = MULTIPLY;
						else
								next_state = WAIT;
				end 
				MULTIPLY: begin
						if(counter == 10'd79)
						begin
								next_state = WAIT;
								done = 1'b1;
						end 
						else begin
								next_state = MULTIPLY;
								done = 1'b0;
						end 
				end 
				endcase
		end 
			
endmodule 