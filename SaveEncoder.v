module SaveEncoder(boardOut, saveVals);
	parameter BOARD_LENGTH = 5;
	parameter BOARD_HEIGHT = 5;
	
	input [(BOARD_LENGTH*BOARD_HEIGHT)-1:0] boardOut;
	
	output [(BOARD_LENGTH*BOARD_HEIGHT*2)-1:0] saveVals;
	
	//if this isn't working, we might want to use an actual mux module here.
	generate
		genvar i;
			for (i=0; i<(BOARD_LENGTH*BOARD_HEIGHT); i=i+1) 
			begin: bitEncoder
				assign saveVals[(2*i)+1] = boardOut[i];
				assign saveVals[(2*i)] = ~boardOut[i];
			end
	endgenerate
endmodule
