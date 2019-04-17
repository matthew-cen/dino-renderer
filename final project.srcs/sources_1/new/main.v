`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2019 03:23:30 PM
// Design Name: 
// Module Name: main
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main(
    clk
    );
    input clk;
    reg [15:0] i, j, k;
    reg [14:0] obstacle_pos [3:0]; // 2D array, [10] is active bit, [9:5] is y position, [4:0] is x position, max 4 obstables at once
    reg [1:0] renderer_state;
    reg game_matrix [15:0][23:0];
	reg matrix_to_send [15:0][23:0];
	reg [393:0] seq;
	reg [31:0] seq_nbits;
    reg [3:0] current_sprite; // sprite currently being processed
    reg [4:0] pixel_pos_x;
    reg [4:0] pixel_pos_y;

    parameter ROWS = 16;
	parameter COLS = 24;
	parameter MATRIX_TOTAL = ROWS * COLS; //384
//    parameter test_clk_cnt = 100000000;
    parameter test_clk_cnt = 2;

    LED_matrix mat(
    .clk(clk),
    .cnt_100M(cnt_100M),
    .wr_seq(seq),
    .wr_seq_nbits(seq_nbits),
    .cs(cs),
    .write(write),
    .data(data),
    .debug(debug));
    
    reg [7:0] icon [4:0][7:0];
    reg [7:0] dino [7:0];
    reg [7:0] dino_std [7:0];
    wire one_sec_clock_out;
    counter one_sec_clock(clk, one_sec_clock_out, test_clk_cnt);
    //transfer 8 slots to where they map on board    
    task transfer_line;
        input integer to_row, to_col, from_row, from_col;
        begin
            for( i=0; i<8; i = i + 1 ) begin
                matrix_to_send[to_row][to_col + i] = game_matrix[from_row][from_col + i];
            end        
        end
	endtask

    //how to transfer each line
    task transform_mat_for_board;
        begin
            transfer_line(0,0,0,0);
            transfer_line(0,8,8,0);
            transfer_line(0,16,1,0);
            
            transfer_line(1,0,9,0);
            transfer_line(1,8,2,0);
            transfer_line(1,16,10,0);
            
            transfer_line(2,0,3,0);
            transfer_line(2,8,11,0);
            transfer_line(2,16,4,0);
            
            transfer_line(3,0,12,0);
            transfer_line(3,8,5,0);
            transfer_line(3,16,13,0);
            
            transfer_line(4,0,6,0);
            transfer_line(4,8,14,0);
            transfer_line(4,16,7,0);
            
            transfer_line(5,0,15,0);
            transfer_line(5,8,0,8);
            transfer_line(5,16,8,8);
            
            transfer_line(6,0,1,8);
            transfer_line(6,8,9,8);
            transfer_line(6,16,2,8);
            
            transfer_line(7,0,10,8);
            transfer_line(7,8,3,8);
            transfer_line(7,16,11,8);
            
            transfer_line(8,0,4,8);
            transfer_line(8,8,12,8);
            transfer_line(8,16,5,8);
            
            transfer_line(9,0,13,8);
            transfer_line(9,8,6,8);
            transfer_line(9,16,14,8);
            
            transfer_line(10,0,7,8);
            transfer_line(10,8,15,8);
            transfer_line(10,16,0,16);
                
            transfer_line(11,0,8,16);
            transfer_line(11,8,1,16);
            transfer_line(11,16,9,16);
            
            transfer_line(12,0,2,16);
            transfer_line(12,8,10,16);
            transfer_line(12,16,3,16);
            
            transfer_line(13,0,11,16);
            transfer_line(13,8,4,16);
            transfer_line(13,16,12,16);
            
            transfer_line(14,0,5,16);
            transfer_line(14,8,13,16);
            transfer_line(14,16,6,16);
            
            transfer_line(15,0,14,16);
            transfer_line(15,8,7,16);
            transfer_line(15,16,15,16);
            
        end
    endtask
    
    task gen_seq_to_send;
        begin
            seq = 5 << 7;
            k = 0;
            for( i=0; i<ROWS; i = i + 1 ) begin
                for( j=0; j<COLS; j = j + 1 ) begin
                    if(matrix_to_send[i][j] == 0)	seq = seq << 1;
                    else    seq = (seq << 1) + 1;
                    k = k + 1;
                end
            end
        end
	endtask

    initial begin
        renderer_state <= 0;
        current_sprite <= 0;
        pixel_pos_x <= 0;
        pixel_pos_y <= 0;

        obstacle_pos[0] <= 15'b101000100001111;
        obstacle_pos[1] <= 15'b000000000000000;
        obstacle_pos[2] <= 15'b000000000000000;
        obstacle_pos[3] <= 15'b000000000000000;
    
        icon[0][0] <= 8'b00000000;
        icon[0][1] <= 8'b00000000;
        icon[0][2] <= 8'b00000000;
        icon[0][3] <= 8'b00000000;
        icon[0][4] <= 8'b00000000;
        icon[0][5] <= 8'b00000000;
        icon[0][6] <= 8'b00000000;
        icon[0][7] <= 8'b00000000;
        
        icon[1][0] <= 8'b00000000;
        icon[1][1] <= 8'b00000000;
        icon[1][2] <= 8'b00000000;
        icon[1][3] <= 8'b00000000;
        icon[1][4] <= 8'b00000000;
        icon[1][5] <= 8'b00010000;
        icon[1][6] <= 8'b00111000;
        icon[1][7] <= 8'b00000000;
        
        icon[2][0] <= 8'b00000000;
        icon[2][1] <= 8'b00000000;
        icon[2][2] <= 8'b00000000;
        icon[2][3] <= 8'b00000000;
        icon[2][4] <= 8'b00000000;
        icon[2][5] <= 8'b00111000;
        icon[2][6] <= 8'b00111000;
        icon[2][7] <= 8'b00000000;
        
        icon[3][0] <= 8'b00000000;
        icon[3][1] <= 8'b00000000;
        icon[3][2] <= 8'b00000000;
        icon[3][3] <= 8'b00000000;
        icon[3][4] <= 8'b00111000;
        icon[3][5] <= 8'b00111000;
        icon[3][6] <= 8'b00111000;
        icon[3][7] <= 8'b00000000;
        
        icon[4][0] <= 8'b00000000;
        icon[4][1] <= 8'b00000000;
        icon[4][2] <= 8'b00000000;
        icon[4][3] <= 8'b00000000;
        icon[4][4] <= 8'b00111100;
        icon[4][5] <= 8'b00111100;
        icon[4][6] <= 8'b00111100;
        icon[4][7] <= 8'b00000000;
        
        dino[0] <= 8'b00000000;
        dino[1] <= 8'b00000010;
        dino[2] <= 8'b00000110;
        dino[3] <= 8'b00011110;
        dino[4] <= 8'b00111100;
        dino[5] <= 8'b00110010;
        dino[6] <= 8'b01110010;
        dino[7] <= 8'b00000000;
        
        dino_std[0] <= 8'b00000011;
        dino_std[1] <= 8'b00000010;
        dino_std[2] <= 8'b00000110;
        dino_std[3] <= 8'b00011110;
        dino_std[4] <= 8'b00111100;
        dino_std[5] <= 8'b00110010;
        dino_std[6] <= 8'b01110010;
        dino_std[7] <= 8'b00000000;
        //init matrices
		for( i=0; i<ROWS; i = i + 1 ) begin
			for( j=0; j<COLS; j = j + 1 ) begin
				game_matrix[i][j] = 0;
			end
		end	
        transform_mat_for_board();
		gen_seq_to_send();
    end
    // 15ms frame time
    // 1s jump up/down unless down button is pressed
    always@(posedge one_sec_clock_out) begin
        // for( i=0; i<ROWS; i = i + 1 ) begin
        //     for( j=0; j<COLS; j = j + 1 ) begin
        //         game_matrix[i][j] = !game_matrix[i][j];
        //     end
        // end	
        
        // sprite rendering
        case (renderer_state) 
            0: begin
                // update game matrix
                for (k=0; k < 4; k = k + 1) begin
                    // check if index in obstacle array contains a obstacle
                    if (obstacle_pos[k][14]) begin
                        current_sprite = obstacle_pos[k][14:10];
                          $display("\n Render Sprite #: %d Row #: %d, Col#: %d", current_sprite,obstacle_pos[k][9:5], obstacle_pos[k][4:0]);
                        for( i=0; i<8; i = i + 1 ) begin
                            for( j=0; j<8; j = j + 1 ) begin
//                                $display("\nPixel Row #: %d", obstacle_pos[k][9:5] + i);
//                                $display("\nPixel Col #: %d", obstacle_pos[k][4:0] + j);
//                                $display("\nOn #: %d", icon[k][i][j]);
                                // boundary collision check
                                pixel_pos_y = obstacle_pos[k][9:5] + i;
                                pixel_pos_x = obstacle_pos[k][4:0] + j;
                                if (pixel_pos_y < 15 || pixel_pos_x < 23) begin
                                    game_matrix[pixel_pos_y][pixel_pos_x] = icon[current_sprite][i][j];
                                end
                            end
                        end	
                    end
                end

                renderer_state = 1;
            end
            1: begin
                // update obstacle positions
                for (k=0; k < 3; k = k + 1) begin
                    if (obstacle_pos[k][4:0] == 24) begin
                        obstacle_pos[k][14] = 0;
                    end
                    else begin
                        obstacle_pos[k][4:0] = obstacle_pos[k][4:0] - 1;
                    end
                end
                // remove object from obstacle queue
                renderer_state = 2;
            end
            2: begin
                // update game board
                  transform_mat_for_board();
		          gen_seq_to_send();
                  renderer_state <= 0;
                  $display("\nTo Game matrix: in initial after transform");
                for( i=0; i<ROWS; i = i + 1 ) begin
                    for( j=0; j<COLS; j = j + 1 ) begin
                        $write("%D ", game_matrix[i][j]);
                    end
                    $write("\n");
                end
                renderer_state = 0;

            end
        endcase
    end
endmodule
