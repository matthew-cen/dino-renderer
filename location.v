`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2019 03:14:49 PM
// Design Name: 
// Module Name: location
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

module physics(clk, BTNU, BTND, pos);
	input clk; //the 100MHz clk from the board
	
	input BTNU, BTND;
	
	integer vel, acc;
	reg [3:0] state;

	output integer pos;
	
	parameter div = 100000000;
	wire [31:0] cnt;
	
	
	// from module counter(clk, cnt, div);
	counter dino_counter(
	   .clk(clk),
	   .cnt(cnt), 
	   .div(div));

	initial begin
		state <= 0;

		pos <= 0;
		vel <= 0;
		acc <= 0;
	end
	
	always@(posedge clk) begin
		case (state)
            0 : if (BTNU) state <= 1;
			1 : begin 
			     acc <= -1;
			     vel <= 1200;
			     state <= 2;
			     pos <= 0;
			     $display("start jump");
			end
			2 : begin
			     if (pos <= 0 & vel<=0) begin
			         state <= 0;
			         pos <= 0;
		             vel <= 0;
		             acc <= 0;
			     end else if (cnt%100000==0) begin
			         if (BTND) acc <= -2;
			         vel <= vel + acc;
			         pos <= pos + vel;
			     end
			end
        endcase
     end
     
     always@(posedge clk) begin
     if (cnt%100000==0) $display("dino position: %d, dino velocity: %d", pos, vel);
     if (cnt==0) $display("1 sec");
     end
endmodule