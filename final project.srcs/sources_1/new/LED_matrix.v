`timescale 1ns / 1ps

/*
Implementation of LED matrix protocol. It takes care of the output values once given a sequence and sequence length. A portion
of this is the solution to Lab03 GQ_03. After sending the sequences stored inside the 2D array (or 1D if you consider it by 
values), it sends whatever value is stored inside wr_seq every second. wr_seq_nbits contains how many bits to send. For us, 
it will always be 394.
A state machine design is used to send the bits with the first state being IDLE (used to set the sequence to send and wait for 
the 1 second when needed). The next state is SEQ_STR, then SEND_BIT, BIT_SENT, SEQ_END, and finally SET_FLAGS.
Note the use of "$display" function for debugging. It has been commented out, but you can still use them if needed.
*/
module LED_matrix(clk, cnt_100M, wr_seq, wr_seq_nbits, cs, write, data, debug);
    
    input clk;
    input [31:0] cnt_100M;
	input [393:0] wr_seq;
	input [31:0] wr_seq_nbits;
	output reg cs;
	output reg write;
	output reg data;
	output reg debug;
	reg [19:0] sequences [19:0];
	reg [19:0] sequences_nbits [19:0];
	reg [4:0] curr_seq_idx;
	
	reg setup_complete;
	
	reg [393:0] seq_to_board;
	reg [31:0] nbits_to_board;
	
	
	parameter HT1632_SYS_DIS = 8'H00;
	parameter HT1632_SYS_EN = 8'H01;
	parameter HT1632_LED_OFF = 8'H02;
	parameter HT1632_LED_ON = 8'H03;
	parameter HT1632_BLINK_OFF = 8'H08;
	parameter HT1632_BLINK_ON = 8'H09;
	parameter HT1632_SLAVE_MODE = 8'H10;
	parameter HT1632_MASTER_MODE = 8'H14;
	parameter HT1632_INT_RC = 8'H18;
	parameter HT1632_EXT_CLK = 8'H1C;
	parameter HT1632_PWM_CONTROL = 8'HA0;
	parameter HT1632_COMMON_16NMOS = 8'H24;

	integer state;
	
	initial begin
	   
	    debug <= 1;
		cs <= 1;
		write <= 1;
		curr_seq_idx <= 0;
		state <= 0; //IDLE
		
		setup_complete <= 0;
				
		sequences[0] <= (( 4 << 8 ) | HT1632_SYS_EN) << 1;
		sequences_nbits[0] <= 12;
		sequences[1] <= (( 4 << 8 ) | HT1632_LED_ON) << 1;
		sequences_nbits[1] <= 12;
		sequences[2] <= (( 4 << 8 ) | HT1632_BLINK_OFF) << 1;
		sequences_nbits[2] <= 12;
		sequences[3] <= (( 4 << 8 ) | HT1632_MASTER_MODE) << 1;
		sequences_nbits[3] <= 12;
		sequences[4] <= (( 4 << 8 ) | HT1632_INT_RC) << 1;
		sequences_nbits[4] <= 12;
		sequences[5] <= (( 4 << 8 ) | HT1632_COMMON_16NMOS) << 1;
		sequences_nbits[5] <= 12;
		sequences[6] <= (( 4 << 8 ) | (HT1632_PWM_CONTROL | 15)) << 1;
		sequences_nbits[6] <= 12;
		
		//to test, as needed
		sequences[7] <= (( 5 << 15 ) | 8'b11110000);
		sequences_nbits[7] <= 18;
		
		sequences[8] <= 0;
		sequences_nbits[8] <= 0;
		
	end
		
	always @(posedge clk) begin
		case(state)
			0: //IDLE
				begin
				   if(!setup_complete)  begin
                       //$display("in IDLE, not setup");
                       seq_to_board <= sequences[curr_seq_idx];
                       nbits_to_board <= sequences_nbits[curr_seq_idx];
					   state <= 1; //SEQ_STR
                   end
                   else begin 
					   if(cnt_100M == 0) begin
						   //$display("in IDLE, setup");
						   seq_to_board <= wr_seq;
						   nbits_to_board <= wr_seq_nbits; 
						   state <= 1; //SEQ_STR
					   end
                   end
//                   $display("state: %d, curr_seq_idx: %d, setup_complete: %b, seq_to_board: %h, \n\tnbits_to_board: %d, wr_seq: %h, \n\twr_seq_nbits: %d",
//                           state, curr_seq_idx, setup_complete, seq_to_board, nbits_to_board, wr_seq, wr_seq_nbits);
                end
			1: //SEQ_STR
				begin
					cs <= 0;
					state <= 2; //SEND_BIT
//					$display("state: %d, curr_seq_idx: %d, setup_complete: %b, seq_to_board: %b, \n\tnbits_to_board: %d, wr_seq: %b, \n\twr_seq_nbits: %d",
//					           state, curr_seq_idx, setup_complete, seq_to_board, nbits_to_board, wr_seq, wr_seq_nbits);
				end
			2: //SEND_BIT
				begin
					nbits_to_board = nbits_to_board - 1;
					if( (seq_to_board >> nbits_to_board) & 1 )		
						data <= 1;
					else	
						data <= 0;
					write <= 0;
					state <= 3; //BIT_SENT
//					$display("state: %d, curr_seq_idx: %d, setup_complete: %b, seq_to_board: %b, \n\tnbits_to_board: %d, wr_seq: %b, \n\twr_seq_nbits: %d",
//					           state, curr_seq_idx, setup_complete, seq_to_board, nbits_to_board, wr_seq, wr_seq_nbits);
				end
			3: //BIT_SENT
				begin
					write <= 1;
					if(nbits_to_board == 0)	state <= 4; //SEQ_END, adding 1 because of overflow
					else	state <= 2; //SEND_BIT
//					$display("state: %d, curr_seq_idx: %d, setup_complete: %b, seq_to_board: %b, \n\tnbits_to_board: %d, wr_seq: %b, \n\twr_seq_nbits: %d",
//					           state, curr_seq_idx, setup_complete, seq_to_board, nbits_to_board, wr_seq, wr_seq_nbits);
				end
			4: //SEQ_END
				begin
					cs <= 1;
					state <= 5; //SET_FLAGS
					curr_seq_idx <= curr_seq_idx + 1;
//					$display("state: %d, curr_seq_idx: %d, setup_complete: %b, seq_to_board: %b, \n\tnbits_to_board: %d, wr_seq: %b, \n\twr_seq_nbits: %d",
//					           state, curr_seq_idx, setup_complete, seq_to_board, nbits_to_board, wr_seq, wr_seq_nbits);
				end		
				
		    5: //SET_FLAGS
		        begin
                    if( curr_seq_idx >= 7 ) setup_complete <= 1;
                    state <= 0;	//IDLE	
	            end
	   endcase
	   
	   
	end
		

endmodule
