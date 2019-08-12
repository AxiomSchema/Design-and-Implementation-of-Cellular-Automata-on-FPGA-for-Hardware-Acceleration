 //takes in a signal and returns the output of the cell, basically just a posedge JK-flip-flop, behavior as follows
//|---------------------|
//| signal |  behavior  |
//|---------------------|
//|   00   |  unchanged |
//|   01   |  set low   |
//|   10   |  set high  |
//|   11   |  toggle    |
//|---------------------|
// Note Clock will be divided
module CellOut(signal, clock, reset, out);
	input[1:0] signal;
	input clock, reset;
	output reg out;

	always @(posedge clock, negedge reset)// TODO: or maybe this load doesn't need to be here?
		begin
			if (reset == 0)
				out <= 1'b0;
			else
				begin
					case(signal)
						2'd0: out <= out;
						2'd1: out <= 1'b0;
						2'd2: out <= 1'b1;
						2'd3: out <= ~out;
					endcase
				end
		end
endmodule
