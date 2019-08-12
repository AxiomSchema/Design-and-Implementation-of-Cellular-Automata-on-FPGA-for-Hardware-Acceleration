`include "Cell.v"
module Board(clock, simClock, load, reset, enTimeStep, loadVals, boardOut);
  parameter LENGTH = 3;
  parameter  HEIGHT = 3;

  input clock, simClock, load, reset, enTimeStep;
  input [LENGTH*HEIGHT*2 -1:0] loadVals;
  output reg [LENGTH*HEIGHT -1:0] boardOut;



  wire [LENGTH*HEIGHT -1:0] cell_outs ;
  // reg top, bottom, left, right;
  generate // create cells iteratively
    genvar l, h;
    for (l = 0; l < LENGTH; l = l +1)
      begin : columns //cell_x_val
        for (h = 0; h < HEIGHT; h = h +1)
          begin : rows //cell_y_val
            // all
            Cell cell0(
              .adjSignals({
                // top left
                boardOut[((l == 0) ? (LENGTH - 1) : (l - 1)) + (((h == 0) ? (HEIGHT - 1) : (h - 1)) * LENGTH)],
                // top
                boardOut[(l) + (((h == 0) ? (HEIGHT - 1) : (h - 1)) * LENGTH)],
                // top right
                boardOut[((l + 1) % LENGTH) + (((h == 0) ? (HEIGHT - 1) : (h - 1)) * LENGTH)],
                // right
                boardOut[((l + 1) % LENGTH) + ((h) * LENGTH)],
                // left
                boardOut[((l == 0) ? (LENGTH - 1) : (l - 1)) + ((h) * LENGTH)],
                // bottom left
                boardOut[((l == 0) ? (LENGTH - 1) : (l - 1)) + (((h+1) % HEIGHT) * LENGTH)],
                // bottom
                boardOut[(l) + (((h+1) % HEIGHT) * LENGTH)],
                // bottom right
                boardOut[((l+1) % LENGTH) + (((h+1) % HEIGHT) * LENGTH)]
              }),
              .clock(clock),
              .dividedClock(simClock),
              .load(load),
              .reset(reset),
              .enTimeStep(enTimeStep),
              .loadVal(loadVals[(l +(h * LENGTH)) * 2 + 1: (l +(h * LENGTH)) * 2]),
              .out(cell_outs[l +(h * LENGTH)])
              );
          end
      end
  endgenerate

  always@(posedge clock) boardOut <= cell_outs;
  // assign boardOut = cell_outs;
endmodule
