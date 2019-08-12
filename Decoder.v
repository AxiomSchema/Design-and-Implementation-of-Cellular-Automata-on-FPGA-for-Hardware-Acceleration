//Takes in the total number of adjacent living cells, and returns a signal as follows
//|--------------------------------|
//|adj cells | signal |  behavior  |
//|--------------------------------|
//|   0-1    |   01   |  set low   |
//|    2     |   00   |  unchanged |
//|    3     |   10   |  set high  |
//|   4-8    |   01   |  set low   |
//|--------------------------------|

module Decoder(sum, signal);
	input[3:0] sum;
	output reg [1:0] signal;

	always @(*)
		begin
			case(sum)
				4'd0: signal = 2'b01;
				4'd1: signal = 2'b01;
				4'd2: signal = 2'b00;
				4'd3: signal = 2'b10;
				4'd4: signal = 2'b01;
				4'd5: signal = 2'b01;
				4'd6: signal = 2'b01;
				4'd7: signal = 2'b01;
				4'd8: signal = 2'b01;
				default: signal = 2'b01;
			endcase
		end
endmodule
