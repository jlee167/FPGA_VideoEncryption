module VGA_controller(input			Clk,
												Reset,
												Cam_vsync,
												Cam_href,
												Cam_pclk,
							 output logic			VGA_Clk,
												sync,
												blank,
												vs,
												hs
												);
												
		
		logic v_clk;
		assign vs = ~Cam_vsync;
		assign blank = Cam_href;
		assign sync = 1'b0;
		assign VGA_Clk = v_clk;
		
		parameter hpixels = 10'd783;
		logic [9:0] hc;
		
		always_ff @ (posedge Reset or posedge Cam_pclk)
		begin
				if(Reset)
						v_clk <= 1'b0;
				else
						v_clk <= ~ v_clk;
		end 
					
		always_ff @ (posedge Reset or posedge v_clk)
		begin
				if(Reset)
						hc <= 10'b0;
				else begin
						if(hc == hpixels)
								hc <= 10'b0;
						else
								hc++;
				end 
		end 

		always_ff @ (posedge Reset or posedge v_clk)
		begin
				if(Reset)
						hs <= 1'b0;
				else begin
						if(((hc + 1'b1) >= 10'd659) & ((hc + 1'b1) < 10'd739))
								hs <= 1'b0;
						else
								hs <= 1'b1;
				end 
		end
		
		endmodule
		