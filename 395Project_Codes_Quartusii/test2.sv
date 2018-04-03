/*
Author: Jihoon Lee, Zachary Splingaire
Date: 5/8/2016
Module: test (MAIN MODULE)
Function :	The top module that interfaces with NIOS II interface, SCCB Master,
				VGB, and Encryption/Decryption Module.
				NIOS II interfaces with SDRAM, and VGB/ENCRYPTION/DECRYPTION module
				interfaces with SRAM
				Input Signal Control is done by the Key receiver module
	
input: Camera signals (clock, 8 bit data, SCCB data)
output: Camera Clk, SCCB Clock, SCCB Data, VGA signals
		  LED Light signals, HEX LED, SRAM control signals, SDRAM Control Signals
	
*/

   module test( input		Clk,
									Reset,
									Shutter,
									Run,
									SCCB_Run,

				  // OV 7670 Camera outputs
				  input			Cam_vsync,
									Cam_href,
									Cam_pclk,
				  input [7:0]	Cam_data,
				  // OV 7670 Camera inputs
				  output			Cam_pwdn,
									Cam_reset_N,
									Cam_sdioc,
									Cam_xclk,
				  // OV 7670 Camera Bidirectional Data port
				  inout			Cam_sdiod,
					//	output logic Cam_sdiod,
					
				  // VGA	Interface
				  output [7:0]  VGA_R,
				                VGA_G,
									 VGA_B,
				  output        VGA_CLK,
				                VGA_SYNC_N,
									 VGA_BLANK_N,
									 VGA_VS,				
									 VGA_HS,
								
					// SRAM Interface for Encryption/VGA module
					output [19:0] SRAM_ADDR,
					inout [15:0] SRAM_DQ,
					output SRAM_OE_N, SRAM_WE_N, SRAM_CE_N, SRAM_LB_N, SRAM_UB_N,
					
					
					output LEDR1, LEDR2, LEDR3, LEDR4, LEDR5, LEDR6, LEDR7,
					output [6:0] HEX0,HEX1,HEX2,HEX3, HEX4, HEX5, HEX6, HEX7,
					
					// SDRAM Interface for NIOS II
				  output [12:0] sdram_wire_addr,
				  output  [1:0] sdram_wire_ba,
				  output        sdram_wire_cas_n,
				  output		sdram_wire_cke,
				  output		sdram_wire_cs_n,
				  inout  [31:0] sdram_wire_dq,
				  output  [3:0] sdram_wire_dqm,
				  output		sdram_wire_ras_n,
				  output		sdram_wire_we_n,
				  output		sdram_wire_clk,
				  
				  input SW1, SW2, SW14,SW15,SW16,SW17
				  
				  );
				  
				  // Data recieved from NIOS II interface
				  // Only Column Shift and SEED used in current division
				  			logic [63:0] row_shift;
							logic [79:0] column_shift;
							logic [23:0] diagonal_shift;
							logic [23:0] SEED;
							logic Command;
							
				//Signals from FPGA to NIOS II processor
				  logic  [7:0] to_sw_sig;	
				  logic  [7:0] to_sw_port;		
				//Signals from NIOS II processor to FPGA
				  logic  [7:0] to_hw_sig;
				  logic  [7:0] to_hw_port;
		
		// TEST LED Input	
		assign LEDR6 = Run;
		assign LEDR5 = Reset;
		assign Cam_xclk = VGA_CLK;
		
		// Hexadicimal modules for digital LED number output
		wire [3:0] counter1, counter2, counter3, counter4;  // Connection from 
		wire [7:0] RESULT;											 // modules to HEX LED	
		HexDriver hex0(.In0(counter1),.Out0(HEX0));
		HexDriver hex1(.In0(counter2),.Out0(HEX1));
		HexDriver hex2(.In0(counter3),.Out0(HEX2));
		HexDriver hex3(.In0(counter4),.Out0(HEX3));
		HexDriver hex4(.In0(column_shift[3:0]),.Out0(HEX4));
		HexDriver hex5(.In0(column_shift[7:4]),.Out0(HEX5));
		HexDriver hex6(.In0(column_shift[11:8]),.Out0(HEX6));
		HexDriver hex7(.In0(column_shift[15:12]),.Out0(HEX7));

		

		logic READ,RUN,RESET_PRESS,RESET;
		enum logic [1:0] {WAIT, WRITE, WAIT2} stat, next_stat;
			
		logic [7:0] SCCB_address, SCCB_writedata, SCCB_readdata;			
		logic SCCB_complete, SCCB_read, SCCB_w2, SCCB_w3;
					
		enum logic [1:0] {WRITE_COM7, WRITE_COM15, CONTINUE} state, next_state;
		
		assign Cam_pwdn = 1'b0;
		assign Cam_reset_N = ~Reset;
		logic [10:0] temp1,temp2;
		
		// VGA & Cryptogram Module
		Image_Input Inoutmodule (.Clk(Clk), .Reset(~Reset), .Cam_vsync(Cam_vsync),.Cam_href(Cam_href),
										.Cam_pclk(Cam_pclk), .Run(~Run), .Cam_data(Cam_data),
										.SRAM_ADDR(SRAM_ADDR), .SRAM_DQ(SRAM_DQ), .SRAM_OE_N(SRAM_OE_N), 
										.SRAM_WE_N(SRAM_WE_N), .SRAM_CE_N(SRAM_CE_N), .SRAM_LB_N(SRAM_LB_N), 
										.SRAM_UB_N(SRAM_UB_N),
										.Red(VGA_R), .Green(VGA_G), .Blue(VGA_B),
										.VGA_Clk(VGA_CLK),
										.sync(VGA_SYNC_N),
										.blank(VGA_BLANK_N),
										.vs(VGA_VS),
										.hs(VGA_HS),
										.LED1(LEDR1), .LED2(LEDR2), .LED3(LEDR3), .LED4(LEDR4),
										.HEX1(counter1), .HEX2(counter2), .HEX3(counter3), .HEX4(counter4),
										.SW1(SW1), .SW2(SW2), .KEY_INPUT(column_shift),
										.SEED(SEED[11:0]), .SW14(SW14),.SW15(SW15),.SW16(SW16),.SW17(SW17)
										);
		
		// SCCB configuration Module
			
		SCCB_master sccb(.Clk(SCCB_clk), .Run(~Run),.Reset(~Reset), .read_rq(SCCB_read), .write2_rq(SCCB_w2), .write3_rq(SCCB_w3), .data_in(SCCB_writedata),
							  .addr_in(SCCB_address), .sdioc(Cam_sdioc), .complete(SCCB_complete), .sdiod(Cam_sdiod), .data_from_slave(RESULT), .SCCB_Run(~SCCB_Run),
							  .LEDR1(), .LEDR2(), .LEDR3(), .LEDR4());
		
		// NIOS II interface	(SDRAM for memory)	
						  cam_soc NiosII (.clk_clk(Clk), 
											 .reset_reset_n(Reset),
											 .to_sw_sig_export(to_sw_sig), 
											 .to_hw_sig_export(to_hw_sig),
											 .to_sw_port_export(to_sw_port),
											 .to_hw_port_export(to_hw_port),
											 .sdram_wire_addr(sdram_wire_addr),    
											 .sdram_wire_ba(sdram_wire_ba),      	
											 .sdram_wire_cas_n(sdram_wire_cas_n),   
											 .sdram_wire_cke(sdram_wire_cke),     	
											 .sdram_wire_cs_n(sdram_wire_cs_n),     
											 .sdram_wire_dq(sdram_wire_dq),      	
											 .sdram_wire_dqm(sdram_wire_dqm),     
											 .sdram_wire_ras_n(sdram_wire_ras_n),  
											 .sdram_wire_we_n(sdram_wire_we_n),     
											 .sdram_clk_clk(sdram_wire_clk)
											 );		
							
		
		// Key receiving module that takes ASCII input from NIOS II processor
		
		Key_Receiver IOmodule(.Clk(Clk), .to_hw_sig(to_hw_sig), 
									.to_hw_port(to_hw_port), .to_sw_sig(to_sw_sig),
									.row_shift(row_shift), .column_shift(column_shift),
									.diagonal_shift(diagonal_shift),.SEED(SEED),
									.Command(Command)
									);		
		
		//Clock Diving section for SCCB 
		//SCCB takes no input clock bigger than 400 KHZ frequency
		
		logic [15:0] freq_counter;
		logic SCCB_clk;
		
		always_ff @ (posedge Clk)
		begin
				if (~Reset)
					freq_counter = 0;
				else if (freq_counter < 16'd63)
					freq_counter++;
				else if (freq_counter == 16'd63)
					freq_counter = 0;
		end
		always_ff @ (posedge Clk)
		begin
			if (freq_counter == 16'd63)
					SCCB_clk = ~ SCCB_clk;
		end
	
		endmodule