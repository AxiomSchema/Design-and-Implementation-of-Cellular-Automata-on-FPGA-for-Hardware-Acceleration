`include "ram16x2240.v"
`include "ram16x50.v"
`include "SaveEncoder.v"

module SaveManager(save, clock, boardOut, saveState, loadVals);
	parameter BOARD_LENGTH = 5;
	parameter BOARD_HEIGHT = 5;

	input save, clock;
	input [3:0] saveState;
	input [(BOARD_LENGTH*BOARD_HEIGHT)-1:0] boardOut;

	output reg [(BOARD_LENGTH*BOARD_HEIGHT*2)-1:0] loadVals;

	wire [(BOARD_LENGTH*BOARD_HEIGHT*2)-1:0] saveVals;

	SaveEncoder SE0(.boardOut(boardOut),
						 .saveVals(saveVals)
						);
	defparam SE0.BOARD_LENGTH = BOARD_LENGTH;
	defparam SE0.BOARD_HEIGHT = BOARD_HEIGHT;

	wire [(BOARD_LENGTH*BOARD_HEIGHT*2)-1:0] ramOut;

	ram16x2240 ram0(.address(saveState),
						 .clock(clock),
						 .data(saveVals),
						 .wren(save),
						 .q(ramOut)
						);

	always@(*)
	begin
		case(saveState)
			/*These values are for the 5x5 board*/
			4'b0000: loadVals <= 50'b0101010101_0101100101_0101011001_0110101001_0101010101; // glider
			4'b0001: loadVals <= 50'b0101010101_0101010101_0110101001_0101010101_0101010101; //supposed to be horizontal line of 3, getting that across the second line from the bottom plus the top left cell
			4'b0010: loadVals <= 50'b0101010101_0101010101_0101010101_0101010110_0101011010; //3 in the top left corner TODO// only this one and all full are producing what is intended
			4'b0011: loadVals <= 50'b0101010101_0101010101_1010101001_0101010101_0101010101; //supposed to be horizontal line of 4, producing
			4'b0100: loadVals <= 50'b1010101010_1010101010_1010101010_1010101010_1010101010; // full board
			4'b1111: loadVals <= 50'b1111111111_1111111111_1111111111_1111111111_1111111111; // invert board
			default: loadVals <= ramOut;
			/*These values are for the 40x28 board*/
//			4'b0000: loadVals <= {{535{2'b01}},{10{2'b10}},{575{2'b01}}}; // horizontal line of 7
//			4'b0001: loadVals <= {{537{2'b01}},{7{2'b10}},{576{2'b01}}}; // horizontal line of 7
//			4'b0010: loadVals <= {{3{2'b10}},{37{2'b01}},2'b10,{39{2'b01}},4'b0110,{38{2'b01}},{1000{2'b01}}};//glider
//			4'b0011: loadVals <= {{555{2'b01}},{10{2'b10}},{555{2'b01}}};//line of 10, split evenly over 2 rows
//			4'b1111: loadVals <= {1120{2'b11}}; // invert board
//			default: loadVals <= ramOut;
		endcase

	end
endmodule
