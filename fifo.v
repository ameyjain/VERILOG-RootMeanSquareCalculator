//==========================================FIFO==========================================
`timescale 1ns / 1ps
module fifo(
  input clk,
  input rst,
  input [31:0] data_in,
  input rd_en,
  input wr_en,
  output reg [31:0] data_out,
  output full,
  output empty);


  reg [4:0] rd_ptr,wr_ptr;
  reg [5:0] status_cnt;
  reg [31:0] mem [0:31];


  assign full = (status_cnt == 6'd32);
  assign empty = (status_cnt == 6'd0);

//========================================wr_ptr updation============================================
  always @(posedge clk or posedge rst)
    begin 
      if (rst)
	wr_ptr <= #1 5'd0;
      else if (wr_en)
	wr_ptr <= #1 wr_ptr+5'd1;
    end

//===========================================rd_ptr updation==========================================

  always @(posedge clk or posedge rst)
    begin 
      if (rst)
	rd_ptr <= #1 5'd0;
      else if (rd_en)
	rd_ptr <= #1 rd_ptr+5'd1;
    end

//==============================================read_data=============================================

  always @(*)
    begin 
      data_out <= #1 mem[rd_ptr];
    end

//===========================================write_data===============================================

  always @(posedge clk or posedge rst)
    begin 
      if (rst)
	begin
	  mem[0] <= 32'd0;mem[8] <= 32'd0;mem[16] <= 32'd0;mem[24] <= 32'd0;
	  mem[1] <= 32'd0;mem[9] <= 32'd0;mem[17] <= 32'd0;mem[25] <= 32'd0;
	  mem[2] <= 32'd0;mem[10] <= 32'd0;mem[18] <= 32'd0;mem[26] <= 32'd0;
	  mem[3] <= 32'd0;mem[11] <= 32'd0;mem[19] <= 32'd0;mem[27] <= 32'd0;
	  mem[4] <= 32'd0;mem[12] <= 32'd0;mem[20] <= 32'd0;mem[28] <= 32'd0;
	  mem[5] <= 32'd0;mem[13] <= 32'd0;mem[21] <= 32'd0;mem[29] <= 32'd0;
	  mem[6] <= 32'd0;mem[14] <= 32'd0;mem[22] <= 32'd0;mem[30] <= 32'd0;
	  mem[7] <= 32'd0;mem[15] <= 32'd0;mem[23] <= 32'd0;mem[31] <= 32'd0;
	end
      else if (wr_en)
	mem[wr_ptr] <= #1 data_in;
    end

  always @(posedge clk or posedge rst)
    begin 
      if (rst)
	status_cnt <= #1 6'd0;
      else if (!rd_en && !wr_en) status_cnt <= #1 status_cnt;
      else if (!rd_en &&  wr_en) status_cnt <= #1 status_cnt+6'd1;
      else if (rd_en && !wr_en) status_cnt <= #1 status_cnt-6'd1;
      else status_cnt <= #1 status_cnt;
    end

endmodule
