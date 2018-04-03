/*
Author: Jihoon Lee, Zachary Splingaire
Date: 5/8/2016
Module: SCCB_MAster
Function :	Sets the internal register values of the internal SCCB of OV7670 Camera
				Controlls output format, color conversion, photoelectric reception,
				and various other DSP features
*/


module SCCB_master(	input logic	Clk,
											Reset,
											Run,
											SCCB_Run,
											read_rq,
											write2_rq,
											write3_rq,
						 input logic [7:0] 	data_in,
											addr_in,
						 output logic 			sdioc,
											complete,
						 output logic [7:0]	data_from_slave,
						 inout			sdiod,
						 output LEDR1, LEDR2,LEDR3,LEDR4
						 );
						 
	assign data_from_slave[7:0] = SCCB_COUNTER[7:0];
	logic [7:0] garbage2;
	logic [15:0] garbage;
	logic [7:0]IP_address_Read, IP_address_Write, Sub_address, Read_data, Write_data, COM15; 				 
	logic prep_sig1, prep_sig2;					
	logic curr_data;
	logic Sccb_run, prep_complete, cam_clk; 
	logic [4:0] state_counter;
	enum logic [4:0] {HALT, STOP, PREP, Phase1, Phase2, INPUT, BREAK, Phase3, Phase4, FIN} state, next_state;
	logic [7:0] SCCB_COUNTER;
	
	
	/*
			Following Register Settings are purely experimental except for image
			format. Color Conversion and Gamma Reception Curve still needs massive adjusting
			for image enhancement
	*/
	
	// Input settings
	// No PCLK scaling, RGB 565 Format
	parameter COM1_ADDR = 8'h04;		parameter COM1_DATA = 8'h00;
	parameter RESET_ADDR = 8'h12; 	parameter RESET_DATA = 8'h80;
	parameter COM7_ADDR = 8'h12; 		parameter COM7_DATA = 8'h04;
	parameter COM15_ADDR = 8'h40;		parameter COM15_DATA = 8'hd0;
	parameter CLKRC_ADDR = 8'h11;		parameter CLKRC_DATA = 8'h00;
	parameter TSLB_ADDR = 8'h3a;		parameter TSLB_DATA = 8'h04;
	parameter COM13_ADDR = 8'h3d;		parameter COM13_DATA = 8'hc0;
	parameter COM14_ADDR = 8'h3e;		parameter COM14_DATA = 8'h1a;
	parameter COM6_ADDR = 8'h0f;		parameter COM6_DATA = 8'h4b;
	parameter COM5_ADDR = 8'h0e;		parameter COM5_DATA = 8'h61;
	parameter COM3_ADDR = 8'h0c;		parameter COM3_DATA = 8'h04;
	
	// Experimental datas
	parameter SLOP_ADDR = 8'h7a;		parameter SLOP_DATA = 8'h20;
	parameter HSTART_ADDR = 8'h17;	parameter HSTART_DATA = 8'h14;//8'h16;//
	parameter HSTOP_ADDR = 8'h18;		parameter HSTOP_DATA = 8'h02;//8'h04;//
	parameter HREF_ADDR = 8'h32;		parameter HREF_DATA = 8'hA4;//8'h24;//
	parameter VSTART_ADDR = 8'h19;	parameter VSTART_DATA = 8'h03;//8'h02;//
	parameter VSTOP_ADDR = 8'h1A;		parameter VSTOP_DATA = 8'h7B;//8'h7a;//
	parameter VREF_ADDR = 8'h03;		parameter VREF_DATA = 8'h8A;//8'h0a;//
	parameter COM9_ADDR = 8'h14;		parameter COM9_DATA = 8'h38;
	
	// Color Conversion Matrix
	parameter MTX1_ADDR = 8'h4f ;		parameter MTX1_DATA = 8'h40;//b3 ;	
	parameter MTX2_ADDR = 8'h50 ;		parameter MTX2_DATA = 8'h34;//b3 ;
	parameter MTX3_ADDR = 8'h51 ;		parameter MTX3_DATA = 8'h0c ;
	parameter MTX4_ADDR = 8'h52 ;		parameter MTX4_DATA = 8'h17;//3d ;
	parameter MTX5_ADDR = 8'h53 ;		parameter MTX5_DATA = 8'h29;//a7 ;
	parameter MTX6_ADDR = 8'h54 ;		parameter MTX6_DATA = 8'h40;//e4 ;	
	parameter MATRIX_ADDR = 8'h58 ;	parameter MATRIX_DATA = 8'h9e ;
	
	// Pixel Clock Divider: set to use input clock as it is
	parameter PCLK_DIV_ADDR = 8'h73;	parameter PCLK_DIV_DATA = 8'hf0;
	
	//Gamma Curve values: Experimental, still needs adjusting
	parameter GAM1_ADDR = 8'h7b; 	parameter GAM1_DATA = 8'h10;
	parameter GAM2_ADDR = 8'h7c;	parameter GAM2_DATA = 8'h1e;
	parameter GAM3_ADDR = 8'h7d;	parameter GAM3_DATA = 8'h35;
	parameter GAM4_ADDR = 8'h7e;	parameter GAM4_DATA = 8'h5a;
	parameter GAM5_ADDR = 8'h7f;	parameter GAM5_DATA = 8'h69;
	parameter GAM6_ADDR = 8'h80;	parameter GAM6_DATA = 8'h76;
	parameter GAM7_ADDR = 8'h81;	parameter GAM7_DATA = 8'h80;
	parameter GAM8_ADDR = 8'h82;	parameter GAM8_DATA = 8'h88;
	parameter GAM9_ADDR = 8'h83;	parameter GAM9_DATA = 8'h8f;
	parameter GAM10_ADDR = 8'h84;	parameter GAM10_DATA = 8'h96;
	parameter GAM11_ADDR = 8'h85;	parameter GAM11_DATA = 8'ha3;
	parameter GAM12_ADDR = 8'h86;	parameter GAM12_DATA = 8'haf;
	parameter GAM13_ADDR = 8'h87;	parameter GAM13_DATA = 8'hc4;
	parameter GAM14_ADDR = 8'h88;	parameter GAM14_DATA = 8'hd7;
	parameter GAM15_ADDR = 8'h89;	parameter GAM15_DATA = 8'he8;
	
	//QVGA
	
	
	// Test block that examine state transition through LED output
	always_ff @ (posedge Clk)
	begin
		if (state == HALT)
						begin
				LEDR1 <= 1;
				LEDR2 <= 0;

						end
		else if (state == FIN)
									begin
				LEDR1 <= 0;
				LEDR2 <= 1;
							end

	end
	
	// State Transition Execution block
	always_ff @ (posedge Clk)
	begin
		if (Reset)
		begin
			state <= HALT;
		end
		else
			state = next_state;
	end
	
	// State Routine Execution Block
	always_ff @ (posedge Clk)
	begin
	

		// For OV7670, IP address for writing is 0x42, and reading is 0x43
		if (state == HALT)
		begin
					Sub_address <= RESET_ADDR;
					Write_data <= RESET_DATA;
					IP_address_Write <= 8'h42; 
					IP_address_Read <= 8'h43; 
					sdioc <= 1'b1;
					sdiod <= 1'bz;
					SCCB_COUNTER <= 8'b0;
		end
		
		/*
		Initializes counter  and output/bidirectional port to camera
		Bidirectional Data port will always remain at highZ when  there is no operation 
		or at hiatus
		*/
		else if (state == STOP)
		begin
			SCCB_COUNTER++;
			state_counter <= 5'b0;
			prep_complete <= 1'b0;
			sdioc <= 1'b1;
			sdiod <= 1'bz;
			cam_clk <= 1'b0;
			prep_sig1 <= 1'b0;
			prep_sig2 <= 1'b0;
			garbage <= 16'b0;
			garbage2 <= 8'b0;
		end
		
		// transion to high and back to 0 signals the beginning of the transition
		else if (state == PREP)
		begin
			if (prep_sig1 == 1'b0)
				begin
				sdioc = 1'b1;
				sdiod = 1'b1;
				prep_sig1 = 1'b1;
				end
			else 
				begin
				sdioc = 1'b1;
				sdiod = 1'b0;
				prep_sig2 = 1'b1;
				end
			
		end
		
		// Phase 1 of the transmission consist of sending IP address to the SCCB
		// which is 0x42 for the writing operation
		else if (state == Phase1)
		begin
			cam_clk <= ~cam_clk; 
			
			if (cam_clk == 1'b0)
				begin
					if (state_counter < 5'd8)
						begin
						sdiod = IP_address_Write[5'd7 - state_counter];
						curr_data = IP_address_Write[5'd7 - state_counter];;
						end
				sdioc = 1'b0;
				state_counter++; 
				end
			else
				begin
				sdioc = 1'b1;
				if (state_counter != 5'd9)
					sdiod = curr_data;

				if (state_counter == 5'd9)
					state_counter = 5'b0;
				end
		end
		
		// Phase 2 of the Transmission is Writing Subaddress of the individual
		// registers to the SCCB
		
		else if (state == Phase2)
		begin
			cam_clk <= ~cam_clk; 
			
			if (cam_clk == 1'b0)
				begin
				sdioc = 1'b0;
					if (state_counter < 5'd8)
						begin
						sdiod = Sub_address[5'd7 - state_counter];
						curr_data = Sub_address[5'd7 - state_counter];
						end
					state_counter++; 
				end
			else
				begin
					sdioc = 1'b1;
				if (state_counter != 5'd9)
					sdiod = curr_data;

				if (state_counter == 5'd9)
					state_counter = 5'b0;
				end
		end
		
		// Input phas sends the 8 bit data to be written to the registers
		// The last bit of the transmission is 0, which is specified by 
		// Omnivision SCCB specification
		
		else if (state == INPUT)
		begin
			cam_clk <= ~cam_clk; 
			
			if (cam_clk == 1'b0)
				begin
				sdioc = 1'b0;
					if (state_counter < 5'd8)
						begin
						sdiod = Write_data[5'd7 - state_counter];
						curr_data = Write_data[5'd7 - state_counter];
						end

					else if (state_counter == 5'd9)
						begin
						sdiod = 1'b0;
						curr_data = 1'b0;
						end
					state_counter++; 
				end
			else
				begin
					sdioc = 1'b1;
				if (state_counter != 5'd9)
					sdiod = curr_data;

				if (state_counter == 5'd10)
					state_counter = 5'b0;
				end
		end
		
		// There is a break time between Input phase and phase 3
		// make 0-1-0 transition to end Input phase transmission and begin Phase 3 transmissiohn
		
		else if (state == BREAK)
		begin
			sdioc = 1'b1;
			if ((garbage2 > 8'd6) && (garbage2 < 8'd12) )
				sdiod = 1'b1;
			else
				sdiod = 1'b0;
			garbage2++;
		end
		
		// Phase 3 transmission is sending IP address to the SCCB
		// This time, IP address is for reading, which is 0x43
		
		else if (state == Phase3)
		begin
			cam_clk <= ~cam_clk; 
			
			if (cam_clk == 1'b0)
				begin
					if (state_counter < 5'd8)
						begin
						sdiod = IP_address_Read[5'd7 - state_counter];
						curr_data = IP_address_Read[5'd7 - state_counter];
						end

				sdioc = 1'b0;
				state_counter++; 
				end
			else
				begin
				sdioc = 1'b1;
				if (state_counter != 5'd9)
					sdiod = curr_data;

				if (state_counter == 5'd9)
					state_counter = 5'b0;
				end
		end
		
		// Phase 4 is reading data from the Sub-address specified in Phase 2
		// No need to write Sub-address again. (And you should not)
		
		else if (state == Phase4)
		begin
			cam_clk <= ~cam_clk; 
			
			if (cam_clk == 1'b0)
			begin
				if (state_counter < 5'd8)
					begin
					//Read_data [5'd7 - state_counter] <= sdiod;
					//sdiod <= 1'bz;
					end
				else if (state_counter == 5'd8)
					begin
					curr_data = 1'b1;
					sdiod = 1'b1;
					end
				else if (state_counter == 5'd9)
					begin
					sdiod = 1'b0;
					curr_data = 1'b0;
					end
					
				sdioc = 1'b0;
				state_counter++; 
			end
			
			else
				begin
				sdioc = 1'b1;
				Read_data [5'd7 - state_counter + 5'd1] <= sdiod;
				if ( (state_counter == 5'd9) || (state_counter == 5'd10) )
					sdiod = curr_data;
				if (state_counter == 5'd10)
					state_counter = 5'b0;
				end
		end
		
		
		/* Changes register address and data port value for the next writing
		 operation. The state machine will reach infinite histus when the
		 last register is written */ 
		else if (state == FIN)
		begin
			sdioc = 1'b1;
			sdiod = 1'b0;
			
			case (SCCB_COUNTER)	  
			 8'h00: begin Sub_address <= 8'h12; Write_data <= 8'h80; end  // COM7   Reset
          8'h01: begin Sub_address <= 8'h12; Write_data <= 8'h80; end // COM7   Reset
          8'h02: begin Sub_address <= 8'h12; Write_data <= 8'h04; end // COM7   Size & RGB output
          8'h03: begin Sub_address <= 8'h11; Write_data <= 8'h00; end // CLKRC  Prescaler - Fin/(1+1)
          8'h04: begin Sub_address <= 8'h0C; Write_data <= 8'h00; end // COM3   Lots of stuff, enable scaling, all others off
          8'h05: begin Sub_address <= 8'h3E; Write_data <= 8'h00; end // COM14  PCLK scaling off
          8'h06: begin Sub_address <= 8'h8C; Write_data <= 8'h00; end // RGB444 Set RGB format
          8'h07: begin Sub_address <= 8'h04; Write_data <= 8'h00; end // COM1   no CCIR601
          8'h08: begin Sub_address <= 8'h40; Write_data <= 8'h10; end // COM15  Full 0-255 output, RGB 565
          8'h09: begin Sub_address <= 8'h3a; Write_data <= 8'h04; end // TSLB   Set UV ordering,  do not auto-reset window
          8'h0A: begin Sub_address <= 8'h14; Write_data <= 8'h38; end // COM9  - AGC Celling
          8'h0B: begin Sub_address <= 8'h4f; Write_data <= 8'h40; end // MTX1  - colour conversion matrix
          8'h0C: begin Sub_address <= 8'h50; Write_data <= 8'h34; end // MTX2  - colour conversion matrix
          8'h0D: begin Sub_address <= 8'h51; Write_data <= 8'h0C; end // MTX3  - colour conversion matrix
          8'h0E: begin Sub_address <= 8'h52; Write_data <= 8'h17; end // MTX4  - colour conversion matrix
          8'h0F: begin Sub_address <= 8'h53; Write_data <= 8'h29; end //  MTX5  - colour conversion matrix
          8'h10: begin Sub_address <= 8'h54; Write_data <= 8'h40; end //  MTX6  - colour conversion matrix
          8'h11: begin Sub_address <= 8'h58; Write_data <= 8'h1e; end //  MTXS  - Matrix sign and auto contrast
          8'h12: begin Sub_address <= 8'h3d; Write_data <= 8'hc0; end // COM13 - Turn on GAMMA and UV Auto adjust
          8'h13: begin Sub_address <= 8'h11; Write_data <= 8'h00; end // CLKRC  Prescaler - Fin/(1+1)
          8'h14: begin Sub_address <= 8'h17; Write_data <= 8'h11; end // HSTART HREF start (high 8 bits)
          8'h15: begin Sub_address <= 8'h18; Write_data <= 8'h61; end // HSTOP  HREF stop (high 8 bits)
          8'h16: begin Sub_address <= 8'h32; Write_data <= 8'hA4; end // HREF   Edge offset and low 3 bits of HSTART and HSTOP
          8'h17: begin Sub_address <= 8'h19; Write_data <= 8'h03; end // VSTART VSYNC start (high 8 bits)
          8'h18: begin Sub_address <= 8'h1A; Write_data <= 8'h7b; end // VSTOP  VSYNC stop (high 8 bits) 
          8'h19: begin Sub_address <= 8'h03; Write_data <= 8'h0a; end // VREF   VSYNC low two bits
          8'h1A: begin Sub_address <= 8'h0e; Write_data <= 8'h61; end // COM5(0x0E) 0x61
          8'h1B: begin Sub_address <= 8'h0f; Write_data <= 8'h4b; end // COM6(0x0F) 0x4B 
          8'h1C: begin Sub_address <= 8'h16; Write_data <= 8'h02; end //
          8'h1D: begin Sub_address <= 8'h1e; Write_data <= 8'h37; end // MVFP (0x1E) 0x07  -- FLIP AND MIRROR IMAGE 0x3x
          8'h1E: begin Sub_address <= 8'h21; Write_data <= 8'h02; end
          8'h1F: begin Sub_address <= 8'h22; Write_data <= 8'h91; end
          8'h20: begin Sub_address <= 8'h29; Write_data <= 8'h07; end
          8'h21: begin Sub_address <= 8'h33; Write_data <= 8'h0b; end              
          8'h22: begin Sub_address <= 8'h35; Write_data <= 8'h0b; end
          8'h23: begin Sub_address <= 8'h37; Write_data <= 8'h1d; end       
          8'h24: begin Sub_address <= 8'h38; Write_data <= 8'h71; end
          8'h25: begin Sub_address <= 8'h39; Write_data <= 8'h2a; end                        
          8'h26: begin Sub_address <= 8'h3c; Write_data <= 8'h78; end // COM12 (0x3C) 0x78
          8'h27: begin Sub_address <= 8'h4d; Write_data <= 8'h40; end                  
          8'h28: begin Sub_address <= 8'h4e; Write_data <= 8'h20; end
          8'h29: begin Sub_address <= 8'h69; Write_data <= 8'h00; end // GFIX (0x69) 0x00                             
          8'h2A: begin Sub_address <= 8'h6b; Write_data <= 8'h4a; end
          8'h2B: begin Sub_address <= 8'h74; Write_data <= 8'h10; end                           
          8'h2C: begin Sub_address <= 8'h8d; Write_data <= 8'h4f; end
          8'h2D: begin Sub_address <= 8'h8e; Write_data <= 8'h00; end                            
          8'h2E: begin Sub_address <= 8'h8f; Write_data <= 8'h00; end
          8'h2F: begin Sub_address <= 8'h90; Write_data <= 8'h00; end                           
          8'h30: begin Sub_address <= 8'h91; Write_data <= 8'h00; end
          8'h31: begin Sub_address <= 8'h96; Write_data <= 8'h00; end                          
          8'h32: begin Sub_address <= 8'h9a; Write_data <= 8'h00; end
          8'h33: begin Sub_address <= 8'hb0; Write_data <= 8'h84; end                          
          8'h34: begin Sub_address <= 8'hb1; Write_data <= 8'h0c; end
          8'h35: begin Sub_address <= 8'hb2; Write_data <= 8'h0e; end                             
          8'h36: begin Sub_address <= 8'hb3; Write_data <= 8'h82; end
          8'h37: begin Sub_address <= 8'hb8; Write_data <= 8'h0a; end
			 
          8'h38: begin Sub_address <= 8'h72; Write_data <= 8'h11; end
			 8'h39: begin Sub_address <= 8'h73; Write_data <= 8'hf1; end 
			 8'h3a: begin Sub_address <= 8'h3e; Write_data <= 8'h19; end 
			 8'h3b: begin Sub_address <= 8'h12; Write_data <= 8'h14; end
			/*
			8'd1: begin	Sub_address <= COM7_ADDR;     	Write_data <= COM7_DATA; end
			8'd2: begin	Sub_address <= COM15_ADDR; 		Write_data <= COM15_DATA; end
			9'd3: begin Sub_address <= CLKRC_ADDR;    	Write_data <= 8'h81; end //8'h84; end
			9'd4: begin Sub_address <= TSLB_ADDR;     	Write_data <= TSLB_DATA; end
			8'd5: begin Sub_address <= MTX1_ADDR;     	Write_data <= MTX1_DATA; end
			8'd6: begin Sub_address <= MTX2_ADDR;     	Write_data <= MTX2_DATA; end
			8'd7: begin Sub_address <= MTX3_ADDR;     	Write_data <= MTX3_DATA; end
			8'd8: begin Sub_address <= MTX4_ADDR;     	Write_data <= MTX4_DATA; end
			8'd9: begin Sub_address <= MTX5_ADDR;     	Write_data <= MTX5_DATA; end
			8'd10: begin Sub_address <= MTX6_ADDR;    	Write_data <= MTX6_DATA; end
			8'd11: begin Sub_address <= MATRIX_ADDR;     Write_data <= MATRIX_DATA; end
			8'd12: begin Sub_address <= HSTART_ADDR;     Write_data <= HSTART_DATA; end
			8'd13: begin Sub_address <= HSTOP_ADDR;     	Write_data <= HSTOP_DATA; end
			8'd14: begin Sub_address <= HREF_ADDR;     	Write_data <= HREF_DATA; end
			8'd15: begin Sub_address <= VSTART_ADDR;     Write_data <= VSTART_DATA; end
			8'd16: begin Sub_address <= VSTOP_ADDR;     	Write_data <= VSTOP_DATA; end
			8'd17: begin Sub_address <= VREF_ADDR;     	Write_data <= VREF_DATA; end
			8'd18: begin Sub_address <= COM9_ADDR;     	Write_data <= COM9_DATA; end
			8'd19: begin Sub_address <= COM13_ADDR;     	Write_data <= COM13_DATA; end
			8'd20: begin Sub_address <= SLOP_ADDR;     	Write_data <= SLOP_DATA; end
			8'd20: begin Sub_address <= COM1_ADDR;     	Write_data <= COM1_DATA; end
			8'd21: begin Sub_address <= COM3_ADDR;     	Write_data <= COM3_DATA; end
			*/
			/*
			9'd21: begin Sub_address <= GAM1_ADDR;     	Write_data <= GAM1_DATA; end
			9'd22: begin Sub_address <= GAM2_ADDR;     	Write_data <= GAM2_DATA; end
			9'd23: begin Sub_address <= GAM3_ADDR;     	Write_data <= GAM3_DATA; end
			9'd24: begin Sub_address <= GAM4_ADDR;     	Write_data <= GAM4_DATA; end
			9'd25: begin Sub_address <= GAM5_ADDR;     	Write_data <= GAM5_DATA; end
			9'd26: begin Sub_address <= GAM6_ADDR;     	Write_data <= GAM6_DATA; end
			9'd27: begin Sub_address <= GAM7_ADDR;     	Write_data <= GAM7_DATA; end
			9'd28: begin Sub_address <= GAM8_ADDR;     	Write_data <= GAM8_DATA; end
			9'd29: begin Sub_address <= GAM9_ADDR;     	Write_data <= GAM9_DATA; end
			9'd30: begin Sub_address <= GAM10_ADDR;     	Write_data <= GAM10_DATA; end
			9'd31: begin Sub_address <= GAM11_ADDR;     	Write_data <= GAM11_DATA; end
			9'd32: begin Sub_address <= GAM12_ADDR;     	Write_data <= GAM12_DATA; end
			9'd33: begin Sub_address <= GAM13_ADDR;     	Write_data <= GAM13_DATA; end
			9'd34: begin Sub_address <= COM5_ADDR;     	Write_data <= COM5_DATA; end
			9'd35: begin Sub_address <= COM6_ADDR;     	Write_data <= COM6_DATA; end
	/*
	These values did not make final cut
	There may be changes in future revision
	
			9'd34: begin Sub_address <= 8'h56;     	Write_data <= 8'h40; end
			9'd35: begin Sub_address <= 8'h59; 			Write_data <= 8'h88; end
			9'd36: begin Sub_address <= 8'h5a; 			Write_data <= 8'h88; end
			9'd37: begin Sub_address <= 8'h5b; 			Write_data <= 8'h44; end
			9'd38: begin Sub_address <= 8'h5c; 			Write_data <= 8'h67; end
			9'd39: begin Sub_address <= 8'h5d; 			Write_data <= 8'h49; end
			9'd40: begin Sub_address <= 8'h5e; 			Write_data <= 8'h0e; end
			9'd41: begin Sub_address <= 8'h69; 			Write_data <= 8'h00; end
			9'd42: begin Sub_address <= 8'h6a; 			Write_data <= 8'h40; end
			9'd43: begin Sub_address <= 8'h6b; 			Write_data <= 8'h0a; end
			9'd44: begin Sub_address <= 8'h6c; 			Write_data <= 8'h0a; end
			9'd45: begin Sub_address <= 8'h6d; 			Write_data <= 8'h55; end
			9'd46: begin Sub_address <= 8'h6e; 			Write_data <= 8'h11; end
			9'd47: begin Sub_address <= 8'h6f; 			Write_data <= 8'h9f; end
			
			9'd48: begin Sub_address <= 8'h70; 			Write_data <= 8'hba; end
			9'd49: begin Sub_address <= 8'h71; 			Write_data <= 8'hb5; end

			
			9'd34: begin Sub_address <= COM14_ADDR;   Write_data <= COM14_DATA; end
			9'd35: begin Sub_address <= 8'h72;     	Write_data <= 8'h22; end
			9'd36: begin Sub_address <= 8'h73;     	Write_data <= 8'hf2; end
			*/
			endcase
				
				
			// Despite SCCB counter counting up to 34th Register write,
			// We are only using first 20 of them for now
			// In state machine Decision block, counter (garbage) counts only up to 20,
			// not 34
			
			if (SCCB_COUNTER != 8'h3b)
				garbage++;		
				
				
		end
				
	end
	
	
	// State Trancision Decision block
	always_comb
	begin
			unique case (state)
			HALT:
				if (SCCB_Run)
					next_state = STOP;
				else
					next_state = HALT;
					
			STOP:
					next_state = PREP;
			PREP:
				if (prep_sig2 == 1'b1)
					next_state = Phase1;
				else
					next_state = PREP;
			Phase1:
				if (  (state_counter == 5'd9) )
					next_state = Phase2;
				else
					next_state = Phase1;
			Phase2:
				if ( (state_counter == 5'd9) )
					next_state = INPUT;
				else
					next_state = Phase2;
			INPUT:
				if ((state_counter == 5'd10))
					next_state = BREAK;
				else
					next_state = INPUT;
				BREAK:
				if (garbage2 == 8'd20)
					next_state = Phase3;
				else
					next_state = BREAK;
			Phase3:
				if ( (state_counter == 5'd9) )
					next_state = Phase4;
				else
					next_state = Phase3;
			Phase4:
				if ( (state_counter == 5'd10) )
					next_state = FIN;
				else
					next_state = Phase4;
			FIN:
			if (garbage == 16'd20)
				next_state = STOP;
			else
				next_state = FIN;
			endcase
	end
	


	
endmodule