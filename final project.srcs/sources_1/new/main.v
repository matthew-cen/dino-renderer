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
    reg [15:0] i, j, k 
    reg [10:0] obstacle_pos [3] // 2D array, [10] is active bit, [9:5] is y position, [4:0] is x position
    integer game_matrix [15:0][23:0];
	integer matrix_to_send [15:0][23:0];
	reg [393:0] seq;
	reg [31:0] seq_nbits;
    
    parameter ROWS = 16;
	parameter COLS = 24;
	parameter MATRIX_TOTAL = ROWS * COLS; //384

    LED_matrix mat(
    .clk(clk),
    .cnt_100M(cnt_100M),
    .wr_seq(seq),
    .wr_seq_nbits(seq_nbits),
    .cs(cs),
    .write(write),
    .data(data),
    .debug(debug));
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

    
    end
    // 15ms frame time
    // 1s jump up/down unless down button is pressed
    always@(posedge clk) begin
        for( i=0; i<ROWS; i = i + 1 ) begin
            for( j=0; j<COLS; j = j + 1 ) begin
                game_matrix[i][j] = !game_matrix[i][j];
            end
        end	
    end
endmodule
