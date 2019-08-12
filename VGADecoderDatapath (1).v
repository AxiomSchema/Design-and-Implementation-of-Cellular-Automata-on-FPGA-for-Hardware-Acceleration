module VGADecoderDatapath(
						// inputs
						bw_board,
						clk,
						resetn,
					  reset_wait_counter,
					  boardOut,
					  save_board,
					  itr_pixel,
					  itr_cell,
					  ld_out,
						mouseToggle,
						mouseCell,
						waiting,
					 // outputs
					 	out_x,
					  out_y,
					  out_colour,
					  finished_cell,
					  finished_board,
					 	finished_wait
					);

		parameter BOARD_HEIGHT = 3;
		parameter BOARD_LENGTH = 3;

		localparam  CELL_SIZE = 4;
		input mouseToggle;
		input [10:0] mouseCell;
		input waiting;
		input bw_board;
		input clk;
		input resetn;
		input reset_wait_counter;
		input [BOARD_HEIGHT*BOARD_LENGTH-1:0] boardOut;
		input save_board;
		input itr_pixel;
		input itr_cell;
		input ld_out;

		output reg [7:0] out_x;
		output reg [6:0] out_y;
		output reg [2:0] out_colour;
		output finished_cell;
		output finished_board;
		output finished_wait;

    // register - snapshot of boardOut
	 reg [BOARD_HEIGHT*BOARD_LENGTH-1:0] saved_board;

    // register - pixel counter
    reg [3:0] pixel_count;

	 assign finished_cell = & pixel_count;

	 // register - cell counter
    reg [10:0] curr_cell;

	 assign finished_board = curr_cell >= BOARD_HEIGHT*BOARD_LENGTH-1;

	 // register - wait counter
	 reg [19:0] wait_counter;
// NOTE: I changed the cutoff for finished_wait just to test, but I think the change is actually reasonable
	 assign finished_wait = wait_counter >= 20'd5;//20'd833_333;

	 //save the current state of boardOut to saved_board
	 always @ (posedge clk) begin
		  if (!resetn) begin
				saved_board <= 0;
		  end
		  else begin
				if (save_board)
                saved_board <= boardOut;
		  end
	 end
	 wire [2:0] backround_colour;
	 wire [2:0] populated_cell_colour;
	 wire black_white_board;
	 assign black_white_board = bw_board;
	 //background_colour is black or red
	 assign backround_colour = (black_white_board) ? 0 : 3'b100;
	 assign populated_cell_colour = (black_white_board) ? 3'b111 : 3'b010;

    // Output x, y, and color
    always @ (posedge clk) begin
      if (!resetn) begin
          out_x      <= 0;
					out_y      <= 0;
					out_colour <= 0;
      end
      else
          if(ld_out) begin
             out_x      <= ((curr_cell % BOARD_LENGTH) * CELL_SIZE) + pixel_count[1:0];
						 out_y      <= ((curr_cell / BOARD_LENGTH) * CELL_SIZE) + pixel_count[3:2];
						 out_colour <= ((& pixel_count[1:0]) | (& pixel_count[3:2]) | ~boardOut[curr_cell]) ?
						 (( (curr_cell==mouseCell) & mouseToggle & ((& pixel_count[1:0]) | (& pixel_count[3:2]))) ? 
							 3'b001 : backround_colour) :
						 populated_cell_colour;
    		 end
    end

    // iterate pixel_count
    always @(posedge clk)
    begin
        if ((!resetn) || itr_cell) begin
            pixel_count <= 0;
        end
        else begin
            if (itr_pixel)
                pixel_count <= pixel_count + 1;
        end
    end

	 // iterate curr_cell
    always @(posedge clk)
    begin
        if (!resetn) begin
            curr_cell <= 0;
        end
        else begin
            if (itr_cell) begin
							if (curr_cell == BOARD_HEIGHT*BOARD_LENGTH - 1) curr_cell <= 0;
							else curr_cell <= curr_cell + 1;
						end
        end
    end

	 // iterate wait_counter
    always @(posedge clk)
    begin
        if ((!resetn) || reset_wait_counter) begin
            wait_counter <= 0;
        end
        else begin
            if (waiting) begin
                wait_counter <= wait_counter + 1;
						end
        end
    end

endmodule
