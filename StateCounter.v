module StateCounter(simClock, reset, load, Out);
  input simClock, reset, load;
  output reg [15:0] Out;
  // Note: in practice, we expect to reset before Out ever becomes 16'hFFFF
  // If we don't, it's not a big deal
  // We also want to reset, when we load a new state
  always@(posedge simClock, negedge reset, negedge load)
    begin
      if ((!reset)||(!load)) Out <= 0;
      else Out <= Out + 1;
    end
endmodule
