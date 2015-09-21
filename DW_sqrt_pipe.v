//====================================33 stage pipelined square root===================================
`timescale 1ns / 1ps
module DW_sqrt_pipe (clk,rst_n,en,a,root);
   
   parameter width = 8;//2
   parameter tc_mode = 0;
   parameter num_stages = 2;//2
   parameter stall_mode = 1;
   parameter rst_mode = 1;
   parameter op_iso_mode = 0;

   
   input clk;
   input rst_n;
  // input [7:0] a;
   input [width-1 : 0] a;
   input en;
   //output [3:0] root;
   output [((width+1)/2)-1 : 0] root;
   

   wire   a_rst_n;
   reg [width-1 : 0] a_reg[0 : num_stages-1];
   //==================================synopsys translate_off=========================================
  
  //========================================Behavioral model==========================================
  
   assign a_rst_n = (rst_mode == 1)? rst_n : 1'b1;
   
   
   always @(posedge clk or negedge a_rst_n)
      begin: pipe_reg_PROC
	 integer i,j;
	 reg [width-1 : 0] a_var[0 : num_stages-1];

	 a_var[0]  = a;
	 
	 if (rst_mode != 0 & rst_n === 1'b0) begin
	    for (i= 1; i < num_stages; i=i+1) begin
	       a_var[i]  = {width{1'b0}};
	    end // for (i= 1; i < num_stages-1; i++)
	 end // if (rst_mode != 0 & rst_n === 1'b0)
	 else if  (rst_mode == 0 || rst_n === 1'b1) begin
	    // pipeline disbled
	    if (stall_mode != 0 && en === 1'b0) begin
	       for (i= 1; i < num_stages; i=i+1) begin
		  a_var[num_stages-i]  = a_var[num_stages-i];
	       end // for (i= 1; i < num_stages-1; i++)	       
	    end // if (stall_mode /= 0 || en === 1'b0)
	    else if (stall_mode == 0 || en === 1'b1) begin
	       // pipeline enabled
	       for (i= 1; i < num_stages; i=i+1) begin
		  a_var[num_stages-i]  = a_var[num_stages-i-1];
	       end // for (i= 1; i < num_stages-1; i++)
	    end // if (stall_mode == 0 || en === 1'b1)
	    else begin // X processing on en
	       for (i= 1; i < num_stages; i=i+1) begin
		  a_var[i]  = {width{1'bx}};
	       end // for (i= 1; i < num_stages-1; i++)
	    end // else: !if(stall_mode == 0 || en === 1'b1)
	 end // if (rst_mode == 0 || rst_n === 1'b1)
	 else begin
	    for (i= 1; i < num_stages; i=i+1) begin
	       a_var[i]  = {width{1'bx}};
	    end // for (i= 1; i < num_stages-1; i++)
	 end // else: !if(rst_n === 1'b1)
	 
	 for(i= 1; i < num_stages; i=i+1) begin 
	    a_reg[i]  <= a_var[i];
	 end	 
      end // block: pipe_reg_PROC
   
   
 
  //===========================Parameter legality check and initializations===============================
  
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 1)",
	width );
    end
    
    if ( (tc_mode < 0) || (tc_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tc_mode (legal range: 0 to 1)",
	tc_mode );
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
//=====================================Square Root Instantiation=======================================
    
    DW_sqrt #(width,0) U1 (.a(a_reg[num_stages-1]),.root(root));

 //==================================Report unknown clock inputs=======================================
    
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 
    
//======================================synopsys translate_on==============================================
endmodule 

//=========================================Square Root Module==============================================

module DW_sqrt (a, root);

  parameter width   = 8;
  parameter tc_mode = 0;

 input  [width-1 : 0]       a;
  output [(width+1)/2-1 : 0] root;
  
 //input [7:0] a;
 //output [3:0] root;
  // include modeling functions
`include "DW_sqrt_function.inc"

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (width < 2) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 2)",
	width );
    end
    
    if ( (tc_mode < 0) || (tc_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tc_mode (legal range: 0 to 1)",
	tc_mode );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  //assign root = DWF_sqrt_uns(a);
  assign root = (tc_mode == 0)? 
		  DWF_sqrt_uns (a) 
                :
		  DWF_sqrt_tc (a);

endmodule



