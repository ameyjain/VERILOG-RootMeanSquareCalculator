//========================================RMS Block===========================================
`timescale 1ns / 1ps
module rms(input clk, input rst, input pushin, input [1:0] cmdin, input signed [31:0] Xin, input pullout, output stopout, output [31:0] Xout);


//-----------------------Reg Declaration----------------
  reg [1:0] cmd_q;
  reg pushin_q,pullout_q;
  reg signed [31:0] Xin_q;
  reg [9:0] n_d,n_q;
  reg [71:0] sum_d,sum_q;
  reg div_en_d,div_en_q;
  reg [1:0] cmd_q1,cmd_q2;
  reg pushin_q1,pushin_q2;
  reg [9:0] n_d1,n_q1;
  reg [71:0] sum_d1,sum_q1;
  
//---------------Wire Declaration-------------------------
  wire fifo_full,fifo_empty;
  wire fifo_wr_en,fifo_rd_en;
  wire div_en;
  wire [71:0] dividend;
  wire [9:0] divisor;
  wire mux_sel;
  wire [71:0] div_res;
  wire [31:0] rms_value;

  reg signed [63:0] temp_d,temp_q;



//=======================================Resetting the signals========================================
  always @(posedge clk or posedge rst)
    begin 
      if (rst)
	begin
	  cmd_q <= #1 2'b00;
	  pushin_q <= #1 0;
	  pullout_q <= #1 0;
	  Xin_q <= #1 32'd0;
	end
      else
	begin
	  cmd_q <= #1 cmdin;
	  pushin_q <= #1 pushin;
	  pullout_q <= #1 pullout;
	  Xin_q <= #1 Xin;
	end
    end

//-------------------------------------------------------
  always @(posedge clk or posedge rst)
    begin 
      if (rst)
	begin
	  cmd_q1 <= #1 2'b00;
	  cmd_q2 <= #1 2'b00;
	  div_en_q <= #1 0;
	  sum_q <= #1 72'd0;
	  n_q <= #1 10'd0;
	  sum_q1 <= #1 72'd0;
	  n_q1 <= #1 10'd0;
	  pushin_q1 <= #1 0;
	  pushin_q2 <= #1 0;
	  temp_q <= #1 0;
	end
      else 
        begin
	  cmd_q1 <= #1 cmd_q;
	  cmd_q2 <= #1 cmd_q1;
	  div_en_q <= #1 div_en_d;
	  sum_q <= #1 sum_d;
	  n_q <= #1 n_d;
	  sum_q1 <= #1 sum_d1;
	  n_q1 <= #1 n_d1;
	  pushin_q1 <= #1 pushin_q;
	  pushin_q2 <= #1 pushin_q1;
	  temp_q <= #1 temp_d;
        end
    end

  always @(*)
    begin
//==============================initialise signals here to avoid latch==================================
      sum_d = sum_q;
      n_d = n_q;
      div_en_d = div_en_q;
      sum_d1 = sum_q1;
      n_d1 = n_q1;
      temp_d = temp_q;

      if(pushin_q)
	  temp_d = Xin_q * Xin_q;   

      if(pushin_q1 && cmd_q1 == 2'b00)  //Square of the data and Increment Counter
	  begin
	    sum_d = sum_q + temp_q;
	    n_d = n_q + 10'd1;
	    div_en_d = 0;
	  end

      else if(pushin_q1 && cmd_q1 == 2'b01) //Substract squared data and decrement counter
	begin
	  sum_d = sum_q - temp_q;
	  n_d = n_q - 10'd1;
	  div_en_d = 0;
	end


      else if(pushin_q1 && cmd_q1 == 2'b10) //Push out the result of RMS and Continue
	begin
	  sum_d = sum_q + temp_q;
	  n_d = n_q + 10'd1;
	  div_en_d = 1;
	end

      else if(pushin_q1 && cmd_q1 == 2'b11) //Push out the data and Reset the RMS Calculations
	begin
	  sum_d1 = sum_q + temp_q;
	  n_d1 = n_q + 10'd1;
	  div_en_d = 1;
	  sum_d = 72'd0;
	  n_d= 10'd0;
	end
    end


//=========================Mux to check if the CMD 11 for reset condition=============================
  assign mux_sel = cmd_q2[1] & cmd_q2[0]; 
  assign dividend = mux_sel ? sum_q1 : sum_q;
  assign divisor = mux_sel ? n_q1 : n_q;

//======================================pipelined D flip flop================================================

  wire [69:0] datain;
  assign datain[0] = div_en;
  genvar j;
  generate
    for(j=1; j<70; j=j+1) begin : test1
      dff u2_dff (.clk(clk),.rst(rst),.d(datain[j-1]),.q(datain[j]));
    end
  endgenerate

//============================Instances of Divider, Square root and FIFO===================================

  DW_div_pipe #(72,10,0,1,37,1,1,0) u1_DW_div_pipe (.clk(clk),.rst_n(~rst),.en(1'b1),.a(dividend),.b(divisor),.quotient(div_res),.remainder(),.divide_by_0());
  DW_sqrt_pipe #(64,0,33,1,1,0) u1_DW_sqrt_pipe (.clk(clk),.rst_n(~rst),.en(1'b1),.a(div_res[63:0]),.root(rms_value));
  fifo u1_fifo(.clk(clk),.rst(rst),.data_in(rms_value),.rd_en(fifo_rd_en),.wr_en(fifo_wr_en),.data_out(Xout),.full(fifo_full),.empty(fifo_empty));

//=======================================================

  assign fifo_wr_en = (datain[68] && (!fifo_full));
  assign fifo_rd_en = ((pullout == 1'b1 && (!fifo_empty)));
  assign div_en = ((cmd_q2 == 2'b10 || cmd_q2 == 2'b11) && pushin_q2);
  assign stopout = fifo_empty;


endmodule
