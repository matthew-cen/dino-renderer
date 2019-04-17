`timescale 1ns / 1ps

/*
A counter that counts up to div - 1, at which point it resets itself to 0
*/
module counter(clk, cnt, div);
	input clk; //the 100MHz clk from the board
	input [31:0] div;
	output reg [31:0] cnt; // 32 bits is more than enough to store our max
	
	initial begin
		cnt <= 0;
	end
	
	always @(posedge clk) begin
		if( cnt == div - 1 )	cnt <= 0;
		else cnt <= cnt + 1;
	end
	
endmodule