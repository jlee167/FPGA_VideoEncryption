/*
Author: Jihoon Lee, Zachary Splingaire
Date: 5/8/2016
Module: Key_Receiver
Function :	Takes 10 Keyboard Input from NIOS II processor
				Altera does not provide HDL interface for Keyboard Input,
				so a NIOS II processor is needed.
*/


module Key_Receiver (input Clk,
							input [7:0] to_hw_sig, to_hw_port,
							output [7:0] to_sw_sig,
							output [63:0] row_shift,
							output [79:0] column_shift,
							output [23:0] diagonal_shift,
							output [23:0] SEED,
							output Command
							);
logic [4:0]	counter;			//counter for the loop

always @ (posedge Clk)
begin
			if (to_hw_sig == 8'd0)
			begin
				to_sw_sig = 8'd0;
				counter = 10'd0;
			end
			
			else if (to_hw_sig == 8'd1)
				to_sw_sig = 8'd1;
			
			// Row_shift input key is not used at the current revision
			else if (to_hw_sig == 8'd2)
			begin
					case (counter)
					5'd0: begin row_shift [7:0]   <= to_hw_port[7:0]; end
					5'd1: begin row_shift [15:8]  <= to_hw_port[7:0]; end
					5'd2: begin row_shift [23:16] <= to_hw_port[7:0]; end
					5'd3: begin row_shift [31:24] <= to_hw_port[7:0]; end
					5'd4: begin row_shift [39:32] <= to_hw_port[7:0]; end
					5'd5: begin row_shift [47:40] <= to_hw_port[7:0]; end
					5'd6: begin row_shift [55:48] <= to_hw_port[7:0]; end
					5'd7: begin row_shift [63:56] <= to_hw_port[7:0]; end
					endcase
					to_sw_sig = 8'd2;
			end
			
			else if (to_hw_sig == 8'd3)
			begin
					if (to_sw_sig != 8'd3)
						counter++;
					to_sw_sig = 8'd3;
			end
			
			else if (to_hw_sig == 8'd4)
			begin
					counter <= 10'd0;
					to_sw_sig <= 8'd4;
			end
			
			
		// Colum Shift is the only Key being used at the current revision
		// The other Inputs may be used in further updates
			else if (to_hw_sig == 8'd5)
			begin
					case (counter)
					5'd0: begin column_shift [7:0]   <= to_hw_port[7:0]; end
					5'd1: begin column_shift [15:8]  <= to_hw_port[7:0]; end
					5'd2: begin column_shift [23:16] <= to_hw_port[7:0]; end
					5'd3: begin column_shift [31:24] <= to_hw_port[7:0]; end
					5'd4: begin column_shift [39:32] <= to_hw_port[7:0]; end
					5'd5: begin column_shift [47:40] <= to_hw_port[7:0]; end
					5'd6: begin column_shift [55:48] <= to_hw_port[7:0]; end
					5'd7: begin column_shift [63:56] <= to_hw_port[7:0]; end
					5'd8: begin column_shift [71:64] <= to_hw_port[7:0]; end
					5'd9: begin column_shift [79:72] <= to_hw_port[7:0]; end
					endcase
					to_sw_sig <= 8'd5;
			end
			
			else if (to_hw_sig == 8'd6)
			begin
					if (to_sw_sig != 8'd6)
						counter++;
					to_sw_sig = 8'd6;
			end
			
			else if (to_hw_sig == 8'd7)
			begin
					counter <= 10'd0;
					to_sw_sig <= 8'd7;
			end
			
			// Diagonal Input is not used at the current revision
			else if (to_hw_sig == 8'd8)
			begin
					case (counter)
					5'd0: begin diagonal_shift [7:0]   <= to_hw_port[7:0]; end
					5'd1: begin diagonal_shift [15:8]  <= to_hw_port[7:0]; end
					5'd2: begin diagonal_shift [23:16]  <= to_hw_port[7:0]; end
					endcase
					to_sw_sig <= 8'd8;
			end
			
			else if (to_hw_sig == 8'd9)
			begin
					if (to_sw_sig != 8'd9)
						counter = counter + 8;
					to_sw_sig = 8'd9;
			end
			
			// Command Input is not used at the current revision
			else if (to_hw_sig == 8'd10)
			begin
					Command <= to_hw_port[0];
					to_sw_sig <= 8'd10;
			end
			
			
			
			
end
							
							
							
endmodule