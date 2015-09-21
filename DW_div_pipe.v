//=======================================37 stage pipelined divison=============================================
`timescale 1ns / 1ps
module DW_div_pipe (clk,rst_n,en,a,b,quotient,remainder,divide_by_0);
   
   parameter a_width = 8;
   parameter b_width = 8;
   parameter tc_mode = 0;
   parameter rem_mode = 1;
   parameter num_stages = 8;
   parameter stall_mode = 1;
   parameter rst_mode = 1;
   parameter op_iso_mode = 0;

   
   input clk;
   input rst_n;
   input [a_width-1 : 0] a;
   input [b_width-1 : 0] b;
   input en;
   
   output [a_width-1 : 0] quotient;
   output [b_width-1 : 0] remainder;
   output 		divide_by_0;
   

   wire   a_rst_n;
   reg [a_width-1 : 0] a_reg[0 : num_stages-1];
   reg [b_width-1 : 0] b_reg[0 : num_stages-1];
   //==================================== synopsys translate_off=========================================
   
  //====================================== Behavioral model==============================================
  
   assign a_rst_n = (rst_mode == 1)? rst_n : 1'b1;
   
   //======================================Pipelining=====================================================
   
   always @(posedge clk or negedge a_rst_n)
      begin: pipe_reg_PROC
	 integer i,j;
	 reg [a_width-1 : 0] a_var[0 : num_stages-1];
	 reg [b_width-1 : 0] b_var[0 : num_stages-1];

	 a_var[0]  = a;
	 b_var[0]  = b;
	 
	 if (rst_mode != 0 & rst_n === 1'b0) begin
	    for (i= 1; i < num_stages; i=i+1) begin
	       a_var[i]  = {a_width{1'b0}};
	       b_var[i]  = {b_width{1'b0}};
	    end // for (i= 1; i < num_stages-1; i++)
	 end // if (rst_mode != 0 & rst_n === 1'b0)
	 else if  (rst_mode == 0 || rst_n === 1'b1) begin
	    // pipeline disbled
	    if (stall_mode != 0 && en === 1'b0) begin
	       for (i= 1; i < num_stages; i=i+1) begin
		  a_var[num_stages-i]  = a_var[num_stages-i];
		  b_var[num_stages-i]  = b_var[num_stages-i];
	       end // for (i= 1; i < num_stages-1; i++)	       
	    end // if (stall_mode /= 0 || en === 1'b0)
	    else if (stall_mode == 0 || en === 1'b1) begin
	       // pipeline enabled
	       for (i= 1; i < num_stages; i=i+1) begin
		  a_var[num_stages-i]  = a_var[num_stages-i-1];
		  b_var[num_stages-i]  = b_var[num_stages-i-1];
	       end // for (i= 1; i < num_stages-1; i++)
	    end // if (stall_mode == 0 || en === 1'b1)
	    else begin // X processing on en
	       for (i= 1; i < num_stages; i=i+1) begin
		  a_var[i]  = {a_width{1'bx}};
		  b_var[i]  = {b_width{1'bx}};
	       end // for (i= 1; i < num_stages-1; i++)
	    end // else: !if(stall_mode == 0 || en === 1'b1)
	 end // if (rst_mode == 0 || rst_n === 1'b1)
	 else begin
	    for (i= 1; i < num_stages; i=i+1) begin
	       a_var[i]  = {a_width{1'bx}};
	       b_var[i]  = {b_width{1'bx}};
	    end // for (i= 1; i < num_stages-1; i++)
	 end // else: !if(rst_n === 1'b1)
	 
	 for(i= 1; i < num_stages; i=i+1) begin 
	    a_reg[i]  <= a_var[i];
	    b_reg[i]  <= b_var[i];
	 end	 
      end // block: pipe_reg_PROC
      
   //====================================Divider Instantiation==========================================   
   
   DW_div #(a_width, b_width, tc_mode, rem_mode)
      U1 (.a(a_reg[num_stages-1]),
	  .b(b_reg[num_stages-1]),
	  .quotient(quotient),
	  .remainder(remainder),
	  .divide_by_0(divide_by_0));
 
  //========================== Parameter legality check and initializations==============================
 
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (a_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter a_width (lower bound: 1)",
	a_width );
    end
    
    if (b_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter b_width (lower bound: 1)",
	b_width );
    end
    
    if ( (tc_mode < 0) || (tc_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tc_mode (legal range: 0 to 1)",
	tc_mode );
    end
    
    if ( (rem_mode < 0) || (rem_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rem_mode (legal range: 0 to 1)",
	rem_mode );
    end            
    
    if (num_stages < 2) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter num_stages (lower bound: 2)",
	num_stages );
    end   
    
    if ( (stall_mode < 0) || (stall_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter stall_mode (legal range: 0 to 1)",
	stall_mode );
    end   
    
    if ( (rst_mode < 0) || (rst_mode > 2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 2)",
	rst_mode );
    end
    
    if ( (op_iso_mode < 0) || (op_iso_mode > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter op_iso_mode (legal range: 0 to 4)",
	op_iso_mode );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

 
  
  //================================= Report unknown clock inputs====================================
  
  
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 
    
// synopsys translate_on   
endmodule 

//=========================================Divider Module=============================================

module DW_div (a, b, quotient, remainder, divide_by_0);

  parameter a_width  = 8;
  parameter b_width  = 8;
  parameter tc_mode  = 0;
  parameter rem_mode = 1;

  input  [a_width-1 : 0] a;
  input  [b_width-1 : 0] b;
  output [a_width-1 : 0] quotient;
  output [b_width-1 : 0] remainder;
  output 		 divide_by_0;
  
  wire [a_width-1 : 0] a;
  wire [b_width-1 : 0] b;
  reg  [a_width-1 : 0] quotient;
  reg  [b_width-1 : 0] remainder;
  reg		       divide_by_0;
  reg 		       b_x;

  //==================================include modeling functions=====================================
 `include "DW_div_function.inc"

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (a_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter a_width (lower bound: 1)",
	a_width );
    end
    
    if (b_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter b_width (lower bound: 1)",
	b_width );
    end
    
    if ( (tc_mode < 0) || (tc_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tc_mode (legal range: 0 to 1)",
	tc_mode );
    end
    
    if ( (rem_mode < 0) || (rem_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rem_mode (legal range: 0 to 1)",
	rem_mode );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



  always @(a or b)
  begin
    if (tc_mode == 0) begin
      quotient = DWF_div_uns (a, b);
      if (rem_mode == 1)
	remainder = DWF_rem_uns (a, b);
      else
	remainder = DWF_mod_uns (a, b);
    end
    else begin
      quotient = DWF_div_tc (a, b);
      if (rem_mode == 1)
	remainder = DWF_rem_tc (a, b);
      else
	remainder = DWF_mod_tc (a, b);
    end
    b_x = ^b;
    if (b_x === 1'bx)
      divide_by_0 = 1'bx;
    else if (b == {b_width{1'b0}})
      divide_by_0 = 1'b1;
    else
      divide_by_0 = 1'b0;
  end 

endmodule







