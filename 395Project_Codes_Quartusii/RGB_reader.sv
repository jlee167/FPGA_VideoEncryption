module RGB_reader(input				Reset,
											Cam_href,
											Cam_pclk,
						input  [7:0]		Cam_data,
						output logic [7:0]	red,
											green,
											blue
											);
		
		parameter horizontal_size = 10'd640;
		parameter vertical_size = 10'd480;

		logic byte_num;
		
		always_ff @ (posedge Reset or posedge Cam_pclk)
		begin
				if(Reset)
				begin
						byte_num <= 1'b0;
						red <= 8'b0;
						green <= 8'b0;
						blue <= 8'b0;
				end 
				else if(Cam_href == 1'b1)
				begin
						if(byte_num == 1'b0)
						begin
								red <= {Cam_data[6:2], Cam_data[6:4]};
								green[7:6] <= Cam_data[1:0];
								green[2:1] <= Cam_data[1:0];
						end 
						else begin
								blue <= {Cam_data[4:0], Cam_data[4:2]};
								green[5:3] <= Cam_data[7:5];
								green[0] <= Cam_data[7];
						end 
						byte_num <= ~byte_num;
				end 
		end 
		
		endmodule