`include "PS2MouseKeyboard/PS2_Mouse_Controller.v"

/*notes:
  Currently leftClick appears to be working as desired, it time steps regardless
  of mouseToggle.

  Right Click seems not to be doing anything currently?

  Modified the always @ block that sets mouseOutput, should be setting correctly
  now (had to multiply mouseCell by 2 because this is a double sized bus), maybe
  we should change the <= 0 statement at the beginning?

  Biggest problem currently is that while mouse motion is being captured on the
  LEDs, we're not getting any visual output on the screen, not sure why that is,
  once this is fixed, fixing right click will be a lot easier

  The mouse movement captured on the LEDs seems very fast, like it's moving
  to a new cell every pixel, I'm not sure why that is, but ultimately it
  shouldn't really matter because as long as the motion is happening, the other
  behavior should follow

  I added new output wires for the current x, and y positions, but they are
  currently unconnected in the top evel module, decided they aren't actually
  needed right now

  another thing fixed is in the top level we were feeding PS2_CLK into PST_DAT,
  this was the fix that got the mouse actually connected up!
 */

module Mouse(clock, resetn, mouseToggle, PS2_CLK, PS2_DAT,
  leftClick, rightClick, mouseOutput, mouseCell, x_pos, y_pos);
  parameter BOARD_HEIGHT = 5;
  parameter BOARD_LENGTH = 5;
  parameter  CELL_SIZE = 4;
  parameter SCREEN_X_OFFSET = 2;
  parameter SCREEN_Y_OFFSET = 2;


  input clock, resetn, mouseToggle;

  inout PS2_CLK;
  inout PS2_DAT;

  output leftClick, rightClick;
  output [8:0] x_pos, y_pos;
  output [2*BOARD_HEIGHT*BOARD_LENGTH -1:0] mouseOutput; // 2 consecutive 1's and rest 0

  //Note this bus is big enough to capture cell on max size board
  output [10:0] mouseCell; // which cell is selected
  

	wire [8:0] x_coord;
	wire [8:0] y_coord;

	PS2_Mouse_Controller mouseController(
		//inputs
			.clock(clock),
			.reset(resetn),
			.enable_tracking(mouseToggle),
		//inouts
			.PS2_CLK(PS2_CLK),
			.PS2_DAT(PS2_DAT),
		//outputs
			.x_pos(x_coord),
			.y_pos(y_coord),
			.left_click(leftClick),
			.right_click(rightClick)
		 );
	defparam mouseController.YMAX = (BOARD_HEIGHT * 4 - 1 + SCREEN_Y_OFFSET);
	defparam mouseController.XMAX = (BOARD_LENGTH * 4 - 1 + SCREEN_X_OFFSET);
	defparam mouseController.XMIN = SCREEN_X_OFFSET;
	defparam mouseController.YMIN = SCREEN_Y_OFFSET;
	defparam mouseController.XSTART = SCREEN_X_OFFSET;
	defparam mouseController.YSTART = SCREEN_Y_OFFSET;

	assign x_pos = x_coord;
	assign y_pos = y_coord;

	reg [2*BOARD_HEIGHT*BOARD_LENGTH -1:0] mouseOutput;

	assign mouseCell = ((x_coord - SCREEN_X_OFFSET)/CELL_SIZE) +
													(((y_coord - SCREEN_Y_OFFSET)/CELL_SIZE)*BOARD_LENGTH);
	// if mouse on a cell, set mouseOutput to toggle cell, else set to do nothing
	always@(mouseCell) begin
		mouseOutput <= 0;
		mouseOutput[2*mouseCell] <= 1;
		mouseOutput[(2*mouseCell)+1] <= 1;
	end
endmodule
