/*A high level module for writing output to VGA*/
`include "vga_adapter/vga_adapter.v"
`include "VGADecoderControl.v"
`include "VGADecoderDatapath.v"

module VGADecoder(
				 mouseToggle,
				 mouseCell,
				 bw_board,
				 clock,						//	On Board 50 MHz
				 resetn,
				 boardOut,
				 // The ports below are for the VGA output.  Do not change.
				 VGA_CLK,   						//	VGA Clock
				 VGA_HS,							//	VGA H_SYNC
				 VGA_VS,							//	VGA V_SYNC
				 VGA_BLANK_N,						//	VGA BLANK
				 VGA_SYNC_N,						//	VGA SYNC
				 VGA_R,   						//	VGA Red[9:0]
				 VGA_G,	 						//	VGA Green[9:0]
				 VGA_B   						//	VGA Blue[9:0]
				);
	parameter BOARD_HEIGHT = 3;
	parameter BOARD_LENGTH = 3;
	parameter SCREEN_X_OFFSET = 2;
	parameter SCREEN_Y_OFFSET = 2; 

	input mouseToggle;
	input [10:0] mouseCell;
	input		bw_board, clock, resetn;				//	Clock is 50 MHz
	input   [BOARD_HEIGHT*BOARD_LENGTH-1:0]   boardOut;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]

	// The colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Creates an Instance of a VGA controller - there can be only one!
	// Defines the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(.resetn(resetn),
						 .clock(clock),
						 .colour(colour),
						 .x(x+SCREEN_X_OFFSET),
						 .y(y+SCREEN_Y_OFFSET),
						 .plot(writeEn),
						 /* Signals for the DAC to drive the monitor. */
						 .VGA_R(VGA_R),
						 .VGA_G(VGA_G),
						 .VGA_B(VGA_B),
						 .VGA_HS(VGA_HS),
						 .VGA_VS(VGA_VS),
						 .VGA_BLANK(VGA_BLANK_N),
						 .VGA_SYNC(VGA_SYNC_N),
						 .VGA_CLK(VGA_CLK)
						);

	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "black.mif";

	wire finished_cell, finished_board, finished_wait, save_board, itr_cell,
				itr_pixel, ld_out, reset_wait_counter, waiting;

   // Instansiate datapath
	VGADecoderDatapath d0(
							// inputs
							.bw_board(bw_board),
							.clk(clock),
    		      .resetn(resetn),
							.boardOut(boardOut),
							.save_board(save_board),
    		      .itr_pixel(itr_pixel),
							.itr_cell(itr_cell),
    		      .ld_out(ld_out),
							.reset_wait_counter(reset_wait_counter),
							.mouseToggle(mouseToggle),
							.mouseCell(mouseCell),
							.waiting(waiting),
							// outputs
    		      .out_x(x),
    		      .out_y(y),
							.out_colour(colour),
		   				.finished_cell(finished_cell),
							.finished_board(finished_board),
							.finished_wait(finished_wait)
				  );
	defparam d0.BOARD_HEIGHT = BOARD_HEIGHT;
	defparam d0.BOARD_LENGTH = BOARD_LENGTH;

   // Instansiate FSM control
	VGADecoderControl c0(
					// inputs
					.clk(clock),
				  .resetn(resetn),
				  .finished_cell(finished_cell),
				  .finished_board(finished_board),
				  .finished_wait(finished_wait),
					// outputs
					.save_board(save_board),
				  .itr_pixel(itr_pixel),
				  .itr_cell(itr_cell),
				  .ld_out(ld_out),
				  .plot(writeEn),
				  .reset_wait_counter(reset_wait_counter),
					.waiting(waiting)
				 );

endmodule
