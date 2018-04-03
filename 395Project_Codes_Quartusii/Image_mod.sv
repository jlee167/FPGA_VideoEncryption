/*
Author: Jihoon Lee, Zachary Splingaire
Date: 5/8/2016
Module: Image_Input
Function :	Processes the input signals from OV7670 Camera to produce 640 * 480
				pixels of VGA image array
				
				Because encryption is done in hardware, Encryption/Decryption makes
				access to SRAM, which makes it share the same logic block with VGA
				output function
				
				Input: Camera Data, Camera sync, Push button inputs				
				Output: VGA signal
*/

module Image_Input (input			Clk,	
											Reset,
											Cam_vsync,
											Cam_href,
											Cam_pclk,
											Run,
											SCCB_Run,
											
						input [7:0]		Cam_data,
						input [79:0]	KEY_INPUT,		// 80 bit input from keyboard
						input [11:0]	SEED,				// seed for key encryption
						
						// Sliding switch input
						input SW1, SW2, SW14, SW15,SW16, SW17,
					
					//VGA OUTPUT	
					output logic [7:0] Red, Green,Blue,
					output logic			VGA_Clk,
												sync,
												blank,
												vs,
												hs,
					// TEST out put LED LIGHT and HEX LED							
					output logic LED1, LED2, LED3, LED4,
				   output [3:0] HEX1, HEX2, HEX3, HEX4, 	
						
					// SRAM INTERFACE	
					output [19:0] SRAM_ADDR,
					inout [15:0] SRAM_DQ,
					output SRAM_OE_N, SRAM_WE_N, SRAM_CE_N, SRAM_LB_N, SRAM_UB_N
											);
		
		// Virtual Image of SRAM
		// Used to drive SRAM from 2 different clocks, which is not possible
		// on normal method
		logic [19:0] LOCAL_SRAM_ADDR;
		logic [15:0] LOCAL_SRAM_DQ;
		logic LOCAL_SRAM_OE_N, LOCAL_SRAM_WE_N, LOCAL_SRAM_CE_N, LOCAL_SRAM_LB_N, LOCAL_SRAM_UB_N;									
											
											
		// Image size parameter   640*480 VGA image			
		parameter horizontal_size = 10'd639;
		parameter vertical_size = 10'd479;
		logic [20:0] counter;


		
		assign HEX1 = counter[3:0];
		assign HEX2 = counter[7:4];
		assign HEX3 = counter[11:8];
		assign HEX4 = counter[15:12];
		
		// States for various phases of 
		// Input reception, Image formation, Encryption/Decryption,
		// and VGA display
		enum logic [4:0]{SLEEP, PREP, PREP2, 	// Inactive states and initial value setting
								RUN 						// Input signal reception state	
								} state, next_state;
								
								
								
		logic byte_num;
		logic [19:0] horizontal_counter, vertical_counter;
		logic [9:0] hc, vc;
		logic [7:0] temp;
		
		
		subkeyGenerator module1(.Clk(Clk), .Reset(Subkey_Reset), .Run(Subkey_Run), .seed(SEED),
										.initial_subkey(Subkey_Input), .done(Subkey_Done), .subkey(Subkey_Output),
										.HEX1(), .HEX2(), .HEX3(), .HEX4());

		
		
		
// Testing state transition by outputting state to LED 
/*
		always_ff @ (posedge Cam_pclk)
		begin
						
				if (state == SLEEP)
				begin
				LED1 <= 1;
				LED2 <= 0;
				LED3 <= 0;
				LED4 <= 0; end

				else if (state == PREP) begin
				LED1 <= 0;
				LED2 <= 1;
				LED3 <= 0;
				LED4 <= 0; end
				else if (state == RUN) begin
				LED1 <= 0;
				LED2 <= 0;
				LED3 <= 1;
				LED4 <= 0; end
				else if (state == DISPLAY) begin
				LED1 <= 0;
				LED2 <= 0;
				LED3 <= 0;
				LED4 <= 1; end
		end
	*/
		VRAM VideoMemory  (
								.rdclock(VGA_Clk), 
								.wrclock(Cam_pclk), 
								.rdaddress(VRAM_rdaddress), 
								.q(VRAM_out1), 
								.data(VRAM_in), 
								.wren(VRAM_wren && (VRAM_wraddress[17:16] == 2'b00)), 
								.wraddress(VRAM_wraddress[15:0])
								);
								
		VRAM VideoMemory2 (
								 .rdclock(VGA_Clk), 
								 .wrclock(Cam_pclk), 
								 .rdaddress(VRAM_rdaddress[15:0]), 
								 .q(VRAM_out2), 
								 .data(VRAM_in), 
								 .wren(VRAM_wren && (VRAM_wraddress[17:16] == 2'b01)), 
								 .wraddress(VRAM_wraddress[15:0])
								 );
		VRAM VideoMemory3 (
								 .rdclock(VGA_Clk), 
								 .wrclock(Cam_pclk), 
								 .rdaddress(VRAM_rdaddress[15:0]), 
								 .q(VRAM_out3), 
								 .data(VRAM_in), 
								 .wren(VRAM_wren && (VRAM_wraddress[17:16] == 2'b10)), 
								 .wraddress(VRAM_wraddress[15:0])
								 );
					 
		wire VRAM_wren; 
		wire [15:0] VRAM_out1, VRAM_out2,VRAM_out3, VRAM_MUXOUT, VRAM_in;
		wire [17:0] VRAM_wraddress, VRAM_rdaddress;
		
		assign VRAM_rdaddress = (640 * vc) + hc;
		
		always_comb
		begin
		
			if (vc >= 10'd240)
			begin
				Red <= 8'd0;
				Blue <= 8'd0;
				Green <= 8'd0;		
			end
		
			else if(VRAM_rdaddress[17:16] == 2'b00)
			begin
				Red <= {VRAM_out1[15:11], VRAM_out1[15:13]};
				Green <= {VRAM_out1[10:5], VRAM_out1[10:9]};
				Blue <= {VRAM_out1[4:0], VRAM_out1[4:2]};		
				end
			else if(VRAM_rdaddress[17:16] == 2'b01) begin
				Red <= {VRAM_out2[15:11], VRAM_out2[15:13]};
				Green <= {VRAM_out2[10:5], VRAM_out2[10:9]};
				Blue <= {VRAM_out2[4:0], VRAM_out2[4:2]};	
				end
			else if(VRAM_rdaddress[17:16] == 2'b10) begin
				Red <= {VRAM_out3[15:11], VRAM_out3[15:13]};
				Green <= {VRAM_out3[10:5], VRAM_out3[10:9]};
				Blue <= {VRAM_out3[4:0], VRAM_out3[4:2]};		
				end
			else begin
				Red <= 8'd0;
				Blue <= 8'd0;
				Green <= 8'd0;		
				end

		end
		
		wire [7:0] R_IN,G_IN,B_IN;
		wire [7:0] R_OUT,G_OUT,B_OUT;
		wire encryption_trigger;
		encryptor encryption_module1(	.clk(VGA_Clk), .wren(encryption_trigger), 
												//.R(R_IN), 
												//.G(G_IN), 
												//.B(B_IN), 
												.R_OUT(R_OUT), 
												.G_OUT(G_OUT), 
												.B_OUT(B_OUT)   ); 
		
		
// State transition Execution module.
		always_ff @ (posedge Reset or posedge Cam_pclk)
		begin
				if(Reset)
					state <= SLEEP;
				
				else
					state <= next_state;	
								
		end

// State Transition Decision Module		
		always_comb
		begin
				unique case (state)
				SLEEP:
					if (Run)
						next_state = PREP;
					else
						next_state = SLEEP;
				
				PREP: 
					if (Cam_vsync == 1'b1)
						next_state = PREP2;
					else
						next_state = PREP;
				PREP2:
					if (Cam_vsync == 1'b0)
						next_state = RUN;
					else
						next_state = PREP2;				
				RUN:
					if (Cam_vsync == 1'b1)
						next_state = PREP;
					else
						next_state = RUN;

				endcase
		end

		
/* This Block produces a virtual image of SRAM input from OV7670 input.
 The actual manipulation of SRAM signals is done in next module driven by
 divided system clock. This block is driven by the pixel clock from OV7670 Camera*/
 		
		always_ff @ (posedge Cam_pclk)
		begin

				if (state == SLEEP)
				begin
					// Nothing for Inactive State
				end
				
				else if (state == PREP)
				begin	
					counter <= 21'b0;
					byte_num <= 1'b0;
					horizontal_counter <= 20'd0;
					vertical_counter <= 20'd0;
					temp <= 8'b0;
					VRAM_wren <= 1'b0;
					encryption_trigger <= 1'b0; 
				end
				
				else if (state == RUN)
				begin
						if(Cam_href == 1'b1)
						begin
							if(byte_num == 1'b0)
								begin
								VRAM_wren <= 1'b0;
								encryption_trigger <= 1'b1;
								temp <= Cam_data[7:0]; 
								end 
							else 
							begin	
									encryption_trigger <= 1'b0;
									if ( (vertical_counter < 20'd 240 ) ) 
										begin 
											VRAM_wren <= 1'b1; 
											VRAM_wraddress <= (horizontal_counter + vertical_counter * 20'd640);
											if (horizontal_counter < 20'd320)
												VRAM_in <= {temp, Cam_data};
											else
												VRAM_in <= {temp, Cam_data} ^ {R_OUT[4:0], G_OUT[5:0], B_OUT[4:0]};
												
										end
									else
										begin 
											VRAM_wren <= 1'b1;
											VRAM_in <= 16'd0;
										end

									if (horizontal_counter == 20'd639)
								begin
									horizontal_counter <= 20'd0;
									vertical_counter++;
								end
								
								else
								begin
									horizontal_counter++;
								end
									counter++;
							end
							byte_num <= ~byte_num;
						end 
						
						else 
						begin 
							VRAM_wren <= 1'b0;

						end
					

				end		
				
		
		end 
		
		
		
		
		// VGA-relevant code

		always_ff @ (posedge Clk)
		begin
			
				VGA_Clk = ~VGA_Clk;
		end
		
	
	/*
	Below is the VGA block that governs every VGA signal except for Data output,
	Which is carried out by the Encryption & Display block above.
	Data output is at the Display state of the above block.
	VGA block only sends sync pulses, VGA system clock, and runs pixel counter (which
	above block uses to send appropriate data for right pixel number
	*/
	
	
		always_ff @ (posedge VGA_Clk or posedge Reset)
		begin
			if(Reset)
			begin
				hc <= 10'b0;
				vc <= 10'b0;
			end 
			
			else 
			begin
				if(hc == 10'd799)
				begin
					hc <= 10'b0;
					if(vc == 10'd524)
						vc <= 10'b0;
					else
						vc++;
				end 
				
				else
					hc++;
			end 
		end
		
		always_ff @ (posedge Reset or posedge VGA_Clk )
		begin
			if(Reset) 
            hs <= 1'b0;
        else
            if ((((hc + 1) >= 10'd656) & ((hc + 1) < 10'd752))) 
                hs <= 1'b0;
            else 
				    hs <= 1'b1;
		end
	 
		always_ff @ (posedge Reset or posedge VGA_Clk )
		begin
        if(Reset) 
           vs <= 1'b0;
        else
            if (((vc + 1) == 9'd490) | ((vc + 1) == 9'd491) ) 
			       vs <= 1'b0;
            else 
			       vs <= 1'b1;
		end

		always_comb
		begin 
			if ( (hc >= 10'b1010000000) | (vc >= 10'b0111100000) ) 
					blank = 1'b0;
			else 
					blank = 1'b1;
		end 		
			
		assign sync = 1'b1;
		
		endmodule 
		
		
