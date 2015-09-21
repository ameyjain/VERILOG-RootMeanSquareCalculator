//==========================D flip-flop between summation and dividor block======================== 
`timescale 1ns / 1ps
module dff(clk,rst,d,q);
  input clk;
  input rst;
  input  d;
 
  output reg q;

  always @(posedge clk or posedge rst) 
    begin
      if(rst) 
	q <= 0;
      else
	q <= d;
    end
  endmodule