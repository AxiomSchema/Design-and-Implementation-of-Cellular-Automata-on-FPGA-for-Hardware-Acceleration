`include "RateDividerComponent.v"
module RateDivider(inputClock, resetn, select, safetyClock, outputClock);
  input inputClock, resetn;
  input [1:0] select;
  output safetyClock;
  output reg outputClock;
  reg [23:0] counter;
  parameter  BASE = 24'd12_499_999;
  wire c0;
  reg c1, c2, c3;
  
//  //defaults to slowest speed. faster with select higher
//  assign outputClock = select[1] ? (select[0] ? (c0) : (c1)) : (select[0] ? (c2) : (c3));

  RateDividerComponent rdc0(
    .inputClock(inputClock), .resetn(resetn), .outputClock(safetyClock));
  defparam rdc0.MAX_VAL = BASE / 16;

  wire selectedClock;
  
  SafetyMux4to1 SM0(.clock(inputClock),
						  .data0(c3),
						  .data1(c2),
						  .data2(c1),
						  .data3(c0),
						  .sel(select),
						  .result(selectedClock)
						);
						
  always @ (posedge safetyClock)
  begin
		outputClock <= selectedClock;
  end

  RateDividerComponent rdc1(
    .inputClock(inputClock), .resetn(resetn), .outputClock(c0));
  defparam rdc0.MAX_VAL = BASE;

  always @(posedge c0)
    begin
      if (!resetn) begin
        c1 <= 0;
      end
      else begin
        c1 <= ~c1;
      end
    end

  always @(posedge c1)
    begin
      if (!resetn) begin
        c2 <= 0;
      end
      else begin
        c2 <= ~c2;
      end
    end

  always @(posedge c2)
    begin
      if (!resetn) begin
        c3 <= 0;
      end
      else begin
        c3 <= ~c3;
      end
    end

endmodule
