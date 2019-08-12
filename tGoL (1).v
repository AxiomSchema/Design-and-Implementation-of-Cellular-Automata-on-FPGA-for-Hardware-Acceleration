`include "Board.v"
`include "VGADecoder.v"
`include "StateCounter.v"
`include "HexDecoder.v"
`include "RateDivider.v"
`include "SaveManager.v"
`include "Mouse.v"

/*This is the top level module for theGameOfLife simuation*/
module tGoL(CLOCK_50,
				KEY,
				SW,
				HEX0,
				HEX1,
				HEX2,
				HEX3,
				HEX4,
				HEX5,
				// These two are for the mouse
				PS2_CLK,
		 	   PS2_DAT,

				// The ports below are for the VGA output.  Do not change.
				VGA_CLK,   						//	VGA Clock
				VGA_HS,							//	VGA H_SYNC
				VGA_VS,							//	VGA V_SYNC
				VGA_BLANK_N,					//	VGA BLANK
				VGA_SYNC_N,						//	VGA SYNC
				VGA_R,   						//	VGA Red[9:0]
				VGA_G,	 						//	VGA Green[9:0]
				VGA_B   							//	VGA Blue[9:0]
			  );

	/*Declare inputs and outputs*/
	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;

	//These two are for the mouse. Don't touch them.
	inout PS2_CLK;
	inout PS2_DAT;

	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	// The following outputsare for the VGA and were given, do not change.
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]

	/*Declare parameters*/
	// Change these to change the number of cells throughout the project
	// You will also need to change the loadVals in SaveManager
	// TODO: eventually want to change max size to 39x27 and leave space around the top and left edge of the screen
	// NOTE max BOARD_HEIGHT = 28, max BOARD_LENGTH = 40;
	// min for both is 3. Boad size affects compilation time
	localparam  BOARD_HEIGHT = 5;
	localparam  BOARD_LENGTH = 5;

	/*By default,the top left corner of cell 0, prints at pixel (0,0) of the screen.
	This shifts the board so that top left corner of cell 0, prints at pixel
	(0+SCREEN_X_OFFSET,0+SCREEN_Y_OFFSET)*/
	localparam  SCREEN_X_OFFSET = 1;
	localparam  SCREEN_Y_OFFSET = 2;

	// WARNING: Only changing CELL_SIZE here will only change it at the top level
	// To fully change, you'd also have to change several things in VGADecoder
	localparam  CELL_SIZE = 4;


	/*Declare wires*/
	wire leftClick, rightClick;

	wire resetn;
	assign resetn = KEY[3];

	wire load;
	assign load = KEY[2];

	wire save;
	assign save = ~KEY[1]; //inverted because save should be active high

	wire timeStep;
	assign timeStep = ~KEY[0] || leftClick; //inverted because time step should be active high

	wire clockToggle;
	assign clockToggle = SW[9];

	wire mouseToggle;
	assign mouseToggle = SW[8];

	wire colourToggle;
	assign colourToggle = SW[4];

	wire key_or_mouse;
	assign key_or_mouse = (mouseToggle) ? ~(rightClick) : load;

	wire dividedClock;

	// /*WARNING: This code might have caused a race condition*/
	// wire simClock;
	// assign simClock = (clockToggle) ? dividedClock : timeStep;

	// /*This is a proposed solution to the hypothesized race condition.*/
	// reg simClock;
	// always@(dividedClock)
	// begin
	// 	if (clockToggle) simClock <= dividedClock;
	// 	else simClock <= timeStep;
	// end
	
	wire safetyClock;	
	
	reg simClock;
	
	wire selectedCock;
	SafetyMux2to1 SM0(.clock(CLOCK_50),
							.data0(timeStep),
							.data1(dividedClock),
							.sel(clockToggle),
							.result(selectedClock)
						  );
						  
	always @ (posedge safetyClock)
	begin
		simClock <= selectedClock;
	end
	
	wire [3:0] saveState;
	assign saveState = SW[3:0];

	wire [BOARD_HEIGHT*BOARD_LENGTH -1:0] boardOut;

	//glider on 5x5 board is 50'b0101010101_0101100101_0101011001_0110101001_0101010101
	wire [2*BOARD_HEIGHT*BOARD_LENGTH -1:0] savedLoadVals;
	wire [2*BOARD_HEIGHT*BOARD_LENGTH -1:0] loadVals;
	wire [2*BOARD_HEIGHT*BOARD_LENGTH -1:0] mouseOutput;
	assign loadVals = (mouseToggle) ? mouseOutput : savedLoadVals;

	wire [15:0] state;

	wire [10:0] mouseCell;


	/*Declare modules*/
	SaveManager sm0(.save(save),
						 .clock(CLOCK_50),
						 .boardOut(boardOut),
						 .saveState(saveState),
						 .loadVals(savedLoadVals)
						);
	defparam sm0.BOARD_HEIGHT = BOARD_HEIGHT;
	defparam sm0.BOARD_LENGTH = BOARD_LENGTH;


	RateDivider RateDivider0(.inputClock(CLOCK_50),
													 .resetn(resetn),
													 .select(SW[6:5]),
													 .safetyClock(safetyClock),
													 .outputClock(dividedClock)
									);


	Board board(.clock(CLOCK_50),
					.simClock(simClock),
					.load(key_or_mouse),
					.reset(resetn),
					.enTimeStep(1'b1),
					.loadVals(loadVals),
					.boardOut(boardOut)
				  );
	//This sets the number of s in Board
	defparam board.LENGTH = BOARD_LENGTH;
	defparam board.HEIGHT = BOARD_HEIGHT;


	VGADecoder VGADecoder0(
									.mouseToggle(mouseToggle),
									.mouseCell(mouseCell),
									.bw_board(colourToggle),
									.clock(CLOCK_50),
								  .resetn(resetn),
								  .boardOut(boardOut),
								  // The ports below are for the VGA output.  Do not change.
								  .VGA_CLK(VGA_CLK),   					//	VGA Clock
								  .VGA_HS(VGA_HS),							//	VGA H_SYNC
								  .VGA_VS(VGA_VS),							//	VGA V_SYNC
								  .VGA_BLANK_N(VGA_BLANK_N),			//	VGA BLANK
								  .VGA_SYNC_N(VGA_SYNC_N),				//	VGA SYNC
								  .VGA_R(VGA_R),   						//	VGA Red[9:0]
								  .VGA_G(VGA_G),	 						//	VGA Green[9:0]
								  .VGA_B(VGA_B)   							//	VGA Blue[9:0]
								 );
	defparam VGADecoder0.BOARD_HEIGHT = BOARD_HEIGHT;
	defparam VGADecoder0.BOARD_LENGTH = BOARD_LENGTH;
	defparam VGADecoder0.SCREEN_X_OFFSET = SCREEN_X_OFFSET;
	defparam VGADecoder0.SCREEN_Y_OFFSET = SCREEN_Y_OFFSET;


	Mouse mouse(
		// inputs
		.clock(CLOCK_50), .resetn(resetn), .mouseToggle(mouseToggle),
		// inouts
		.PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT),
		//outputs
		.leftClick(leftClick), .rightClick(rightClick),
		.mouseOutput(mouseOutput), .mouseCell(mouseCell));
	defparam mouse.SCREEN_X_OFFSET = SCREEN_X_OFFSET;
	defparam mouse.SCREEN_Y_OFFSET = SCREEN_Y_OFFSET;
	defparam mouse.BOARD_HEIGHT = BOARD_HEIGHT;
	defparam mouse.BOARD_LENGTH = BOARD_LENGTH;
	defparam mouse.CELL_SIZE = CELL_SIZE;


	StateCounter sc(.simClock(simClock),
						 .reset(resetn),
						 .load(load),
						 .Out(state)
						);


	/*HEX displays*/
	// Display StateNumber on HEX3 to HEX0
	HexDecoder hd0(.hex_digit(state[3:0]),.segments(HEX0));
	HexDecoder hd1(.hex_digit(state[7:4]),.segments(HEX1));
	HexDecoder hd2(.hex_digit(state[11:8]),.segments(HEX2));
	HexDecoder hd3(.hex_digit(state[15:12]),.segments(HEX3));
	//Turn off HEX4
	assign HEX4 = 7'h7F;
	// Show the selected saveState
	HexDecoder hd5(.hex_digit(saveState),.segments(HEX5));

endmodule
