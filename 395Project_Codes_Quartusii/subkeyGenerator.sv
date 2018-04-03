/*
Author: Jihoon Lee, Zachary Splingaire
Date: 5/8/2016
Module: SubkeyGenerator
Function :	Takes 4 submodules that processes 80bit through Tent map, QuadMap,
				Logistic Map, and Bernouille Map each.
				80 Bit input key is processed through each map and is outputted.
				output key will then be the input key for next routine of the Image_mod
				module
				
Input: 80 bit key
output : Encryptiod 80 bit key
*/


module subkeyGenerator(input 					Clk,
														Reset,
														Run,
												
							  input [11:0]			seed,
							  input [79:0]			initial_subkey,
							  output 				done,
							  output [79:0]		subkey,
							  output [3:0] HEX1,HEX2,HEX3,HEX4
							  );
			
			
		always_ff @(posedge Clk)
		begin
			if (state == WAIT)
			begin
			HEX1 <= 4'd1;
			HEX2 <=4'd0;
			HEX3 <=4'd0;
			HEX4 <=4'd0;
			end
			
			else if (state == HOLD)
			begin
			HEX1 <= 4'd0;
			HEX2 <= 4'd1;
			HEX3 <= 4'd0;
			HEX4 <= 4'd0;
			end
			
			else if (state == LOGISTIC)
			begin
			HEX1 <= 4'd0;
			HEX2 <= 4'd0;
			HEX3 <= 4'd1;
			HEX4 <= 4'd0;
			end
			
			else if (state == TENT)
			begin
			HEX1 <= 4'd0;
			HEX2 <= 4'd0;
			HEX3 <= 4'd0;
			HEX4 <= 4'd1;
			end
			
			
		end
			
		logic [79:0] current_key;
		logic [11:0] temp_seed;
		
		logic [2:0] cycle;
		logic [3:0] map_counter;
		
		logic log_run, log_done;
		logic [79:0] log_out;
		logisticMap log(.Clk(Clk), .Reset(Reset), .Run(log_run), .in(current_key), .out(log_out), .done(log_done));
		
		logic tent_run, tent_done;
		logic [79:0] tent_out;
		tentMap tent(.Clk(Clk), .Reset(Reset), .Run(tent_run), .in(current_key), .out(tent_out), .done(tent_done));
		
		logic quad_run, quad_done;
		logic [79:0] quad_out;
		quadMap quad(.Clk(Clk), .Reset(Reset), .Run(quad_run), .in(current_key), .out(quad_out), .done(quad_done));
		
		logic bern_run, bern_done;
		logic [79:0] bern_out;
		bernMap bern(.Clk(Clk), .Reset(Reset), .Run(bern_run), .in(current_key), .out(bern_out), .done(bern_done));
		
		enum logic [2:0] {WAIT, DECIDE_MAP, LOGISTIC, TENT, QUADRATIC, BERNOULLI, HOLD} state, next_state;

		// State Routine Execution

		always_ff @ (posedge Clk or posedge Reset)
		begin
				if(Reset == 1'b1)
				begin
						current_key <= 80'b0;
						temp_seed <= 12'b0;
						cycle <= 3'b0;
						map_counter <= 4'b0;
						state <= WAIT;
				end 
				else begin
						state <= next_state;
						unique case(state)
						WAIT: begin
								temp_seed <= seed;
								if(Run == 1'b1)
										current_key <= initial_subkey;
								cycle <= 3'b0;
								map_counter <= 4'b0;
						end 
						DECIDE_MAP: begin
								cycle <= cycle + 1'b1;
								case(cycle)
								3'b000: map_counter <= temp_seed[11:9] + 4'd4;
								3'b001: map_counter <= temp_seed[8:6] + 4'd4;
								3'b010: map_counter <= temp_seed[5:3] + 4'd4;
								3'b011: map_counter <= temp_seed[2:0] + 4'd4;
								default: map_counter <= 4'd5;
								endcase
						end 
						LOGISTIC: begin
								if(log_done == 1'b1)
								begin
										current_key <= log_out;
										map_counter <= map_counter - 1'b1;
								end 
						end 
						TENT: begin
								if(tent_done == 1'b1)
								begin
										current_key <= tent_out;
										map_counter <= map_counter - 1'b1;
								end 
						end 
						QUADRATIC: begin
								if(quad_done == 1'b1)
								begin
										current_key <= quad_out;
										map_counter <= map_counter - 1'b1;
								end 
						end 
						BERNOULLI: begin
								if(bern_done == 1'b1)
								begin
										current_key <= bern_out;
										map_counter <= map_counter - 1'b1;
								end 
						end
						HOLD: begin
						
						end 
						endcase
				end 
		end 
			
		// State Transition Decision Block	
		always_comb
		begin
				done = 1'b0;
				subkey = current_key;
				next_state = state;
		
				log_run = 1'b0;
				tent_run = 1'b0;
				quad_run = 1'b0;
				bern_run = 1'b0;
				
				unique case(state)
				WAIT: begin
						if(Run == 1'b1)
								next_state = DECIDE_MAP;
				end 
				DECIDE_MAP: begin
						if(cycle == 3'd4)
						begin
								next_state = HOLD;
						end 
						else begin
								case(cycle)
								3'b000: begin
										if(temp_seed[11:9] < 3'd3)
												next_state = LOGISTIC;
										else if(temp_seed[11:9] > 3'd4)
												next_state = QUADRATIC;
										else 
												next_state = TENT;
								end 
								3'b001: begin
										if(temp_seed[8:6] < 3'd3)
												next_state = QUADRATIC;
										else if(temp_seed[8:6] > 3'd5)
												next_state = TENT;
										else
												next_state = BERNOULLI;
								end 
								3'b010: begin
										if(temp_seed[4:3] == 2'b00)
												next_state = TENT;
										else if(temp_seed[5:4] == 2'b0)
												next_state = LOGISTIC;
										else if({temp_seed[5],temp_seed[3]} == 2'b0)
												next_state = BERNOULLI;
										else
												next_state = QUADRATIC;
								end 
								3'b011: begin
										if(temp_seed[4:3] == 2'b00)
												next_state = LOGISTIC;
										else if(temp_seed[5:4] == 2'b0)
												next_state = BERNOULLI;
										else if({temp_seed[5],temp_seed[3]} == 2'b0)
												next_state = TENT;
										else
												next_state = QUADRATIC;
								end 
								default: next_state = LOGISTIC;
								endcase
						end 
				end 
				LOGISTIC: begin
						if(log_done == 1'b1)
						begin
								log_run = 1'b0;
								if(map_counter == 4'b1)
										next_state = DECIDE_MAP;
								else
										next_state = LOGISTIC;
						end 
						else 
								log_run = 1'b1;
				end
				TENT: begin
						if(tent_done == 1'b1)
						begin
								tent_run = 1'b0;
								if(map_counter == 4'b1)
										next_state = DECIDE_MAP;
								else
										next_state = TENT;
						end 
						else 
								tent_run = 1'b1;
				end
				QUADRATIC: begin
						if(quad_done == 1'b1)
						begin
								quad_run = 1'b0;
								if(map_counter == 4'b1)
										next_state = DECIDE_MAP;
								else
										next_state = QUADRATIC;
						end 
						else 
								quad_run = 1'b1;
				end
				BERNOULLI: begin
						if(bern_done == 1'b1)
						begin
								bern_run = 1'b0;
								if(map_counter == 4'b1)
										next_state = DECIDE_MAP;
								else
										next_state = BERNOULLI;
						end 
						else 
								bern_run = 1'b1;
				end
				HOLD: begin
						done = 1'b1;
						next_state = HOLD;
				end 
				endcase
		end 
			
endmodule 