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

module location(clk, BTNU, BTND, reset, position);
	input clk; //the 100MHz clk from the board
	input reset; // clears, pos, vel, acc;
	
	input BTNU, BTND;
	
	integer vel, acc, pos;
	reg [3:0] state;

	// output [3:0] position;
	output [3:0] position;
	parameter div = 100000000;
	wire [31:0] cnt;
	
	
	// from module counter(clk, cnt, div);
	counter dino_counter(
	   .clk(clk),
	   .cnt(cnt), 
	   .div(div));
	   
	
	assign position = pos / 100000;

	initial begin
		state <= 0;

		pos <= 0;
		vel <= 0;
		acc <= 0;
	end
	
	always@(posedge clk) begin
	    if (reset) begin
        	state <= 0;
            pos <= 0;
            vel <= 0;
            acc <= 0;
        end
        else begin
        
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
        end // else
     end
     
     always@(posedge clk) begin
     if (cnt%100000==0) $display("dino position: %d, dino velocity: %d", pos, vel);
     if (cnt==0) $display("1 sec");
     end
endmodule