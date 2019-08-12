module VGADecoderControl(
						// inputs
						clk,
				    resetn,
				    finished_cell,
				    finished_board,
				    finished_wait,
						// outputs
				   	save_board,
					  itr_pixel,
				    itr_cell,
				    ld_out,
				    plot,
				   	reset_wait_counter,
						waiting
				   );
	 input clk;
   input resetn;
   input finished_cell;
   input finished_board;
   input finished_wait;

   output reg save_board;
	 output reg itr_pixel;
   output reg itr_cell;
   output reg ld_out;
   output reg plot;
   output reg reset_wait_counter;
	 output reg waiting;

    reg [2:0] current_state, next_state;

    localparam  S_WAIT             = 3'd0,
					 			S_RESET_WAIT_COUNTER  = 3'd1,
					 			S_SAVE_BOARD		   = 3'd2,
                S_LOAD             = 3'd3,
                S_PLOT             = 3'd4,
                S_ITR_PIXEL        = 3'd5,
                S_ITR_CELL         = 3'd6;

    // Next state logic aka our state table
    always @(*) //should be * because you want the finished signals to change output
    begin: state_table
          case (current_state)
				 		S_WAIT: next_state             		= finished_wait ? S_RESET_WAIT_COUNTER : S_WAIT;
				 		S_RESET_WAIT_COUNTER: next_state  = S_SAVE_BOARD;
				 		S_SAVE_BOARD: next_state		   		= S_LOAD; // load a pixel into the vga_adapter
            S_LOAD: next_state             		= S_PLOT; // write the pixel the vga_adapter buffer
            S_PLOT: next_state             		= S_ITR_PIXEL;
            S_ITR_PIXEL: next_state        		= finished_cell ? S_ITR_CELL : S_LOAD;
				 		S_ITR_CELL:  next_state	       		= finished_board ? S_WAIT : S_LOAD;
          default: next_state 	           		= S_WAIT;
      endcase
    end // state_table


    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
      // By default make all our signals 0
      save_board <= 1'b0;
			itr_pixel <= 1'b0;
			itr_cell <= 1'b0;
			ld_out <= 1'b0;
			plot <= 1'b0;
			reset_wait_counter <= 1'b0;
			waiting <= 1'b0;

		case (current_state)
			S_RESET_WAIT_COUNTER: begin
				 reset_wait_counter <= 1'b1;
			end
			S_SAVE_BOARD: begin
				 save_board <= 1'b1;
			end
			S_LOAD: begin
				 ld_out <= 1'b1;
			end
			S_PLOT: begin
				 plot <= 1'b1;
			end
			S_ITR_PIXEL: begin
				 itr_pixel <= 1'b1;
			end
			S_ITR_CELL: begin
				 itr_cell <= 1'b1;
			end
			S_WAIT: begin
			 		waiting <= 1'b1;
			end
		// default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
		endcase
	end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_WAIT;
        else
            current_state <= next_state;
    end // state_FFS
endmodule
