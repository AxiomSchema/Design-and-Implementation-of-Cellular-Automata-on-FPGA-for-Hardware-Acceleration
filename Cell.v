`include "Adder.v"
`include "Decoder.v"
`include "CellOut.v"

module Cell(adjSignals, clock, dividedClock, load, reset, enTimeStep, loadVal, out);
	input clock, dividedClock, load, reset, enTimeStep;
	input[1:0] loadVal;
	input[7:0] adjSignals;
	output reg out;

	wire[3:0] sum;

	Adder adder(.adjSignals(adjSignals), .clock(clock), .sum(sum));

	wire[1:0] decoderOut;

	Decoder decoder(.sum(sum), .signal(decoderOut));

	wire[1:0] signal;
	assign signal = load ? decoderOut : loadVal;
	// wire gatedClock; // This was meant to go into clock of cellOut
	// assign gatedClock = dividedClock && load && enTimeStep;
	wire unsyncedOut;
	// note gatedClock could just be the dividedClock
	CellOut cellOut(.signal(signal), .clock(dividedClock), .reset(reset), .out(unsyncedOut));

	always @(posedge clock)
		out <= unsyncedOut;
endmodule
