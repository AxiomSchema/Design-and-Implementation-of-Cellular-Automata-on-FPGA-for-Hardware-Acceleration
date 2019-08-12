//takes in the output of the eight adjacent cells and returns their sum

module Adder(adjSignals, clock,sum);
	input [7:0] adjSignals;
	input clock;
	output reg [3:0] sum;
	
	reg [7:0] adjSignalsSynced;
	
	always @ (posedge clock)
	begin
		adjSignalsSynced <= adjSignals;
	end
	
	wire [3:0] sumUnsynced;
	
	assign sumUnsynced = adjSignalsSynced[0] + adjSignalsSynced[1] + adjSignalsSynced[2] + adjSignalsSynced[3] + adjSignalsSynced[4] + adjSignalsSynced[5] + adjSignalsSynced[6] + adjSignalsSynced[7];
	
	always @ (posedge clock)
	begin
		sum <= sumUnsynced;
	end
	
endmodule


/*Old version of the code, trying new design*/
//	input[7:0] adjSignals;
//	input clock;
//	output reg [3:0] sum;
//
//	// //might be causing a race condition? might need to put in timing?
//	// assign sum = adjSignals[0] + adjSignals[1] + adjSignals[2] + adjSignals[3] + adjSignals[4] + adjSignals[5] + adjSignals[6] + adjSignals[7];
//
//	always@(clock)
//	begin
//		sum <= adjSignals[0] + adjSignals[1] + adjSignals[2] + adjSignals[3] + adjSignals[4] + adjSignals[5] + adjSignals[6] + adjSignals[7];
//	end