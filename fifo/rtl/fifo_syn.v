`timescale 1ns/100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HFUTWDZ
// Engineer: Nie Yanshuo
// Email: nieyanshuo@163.com 
//
// Create Date: 2020/06/02   --:--:--
// Design Name: fifo_syn
// Module Name: fifo_syn
// Project Name: fifo
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
module fifo_syn#(
    parameter   FIFO_DEPTH = 10,    //Actual depth is 2**FIFO_DEPTH
    parameter   FIFO_DWTH = 8,
    parameter   PROG_FULL_NEG_VALUE = 0,
    parameter   PROG_EMPTY_POS_VALUE = 0
)
(/*AUTOARG*/
   // Outputs
   dout, valid, full, empty, almost_full, almost_empty, prog_full,
   prog_empty,
   // Inputs
   clk, rst, din, wren, rden
   );
input                       clk;
input                       rst;
input   [FIFO_DWTH-1 : 0]   din;
input                       wren;
input                       rden;
output  [FIFO_DWTH-1 : 0]   dout;
output                      valid;
output                      full;
output                      empty;
output                      almost_full;
output                      almost_empty;
output                      prog_full;
output                      prog_empty;

/*AUTOREG*/
// Beginning of automatic regs (for this module's undeclared outputs)
reg                     valid;
// End of automatics


/*variab le define by myself*/   /*{{{*/
reg     [FIFO_DEPTH-1 : 0]  ram_addra;
wire                        ram_wea;
wire    [FIFO_DWTH-1 : 0]   ram_dina;
reg     [FIFO_DEPTH-1 : 0]  ram_addrb;
wire                        ram_web;
wire    [FIFO_DWTH-1 : 0]   ram_dinb;
wire    [FIFO_DWTH-1 : 0]   ram_doutb;

wire                        wren_fifo;
wire                        rden_fifo;
reg     [FIFO_DEPTH : 0]   cnt_fifo;/*}}}*/

/*logic circuit*/
assign  wren_fifo   = wren & !full;
assign  rden_fifo   = rden & !empty;

//ram端口a使用来写{{{
always@(posedge clk)
    begin
        if(rst)
            ram_addra <= 'd0;
        else if(wren_fifo)
            begin
                if(ram_addra == 2**FIFO_DEPTH)
                    ram_addra <= 'd0;
                else
                    ram_addra <= ram_addra + 'd1;
            end
    end/*}}}*/


//ram端口b使用来读{{{ 
always@(posedge clk)
    begin
        if(rst)
            ram_addrb <= 'd0;
        else if(rden_fifo)
            begin
                if(ram_addrb == 2**FIFO_DEPTH)
                    ram_addrb <= 'd0;
                else
                    ram_addrb <= ram_addrb + 'd1;
            end
    end/*}}}*/

//读写计数,FIFO状态 {{{
always@(posedge clk)
    begin
        if(rst)
            cnt_fifo <= 'd0;
        else if(wren_fifo & !rden_fifo)
            begin
                cnt_fifo <= cnt_fifo + 'd1;
            end
        else if(!wren_fifo & rden_fifo)
            begin
                cnt_fifo <= cnt_fifo - 'd1;
            end 
    end

assign  full        = (cnt_fifo >= 2**FIFO_DEPTH);
assign  almost_full = (cnt_fifo >= 2**FIFO_DEPTH-1);
assign  prog_full   = (cnt_fifo >= 2**FIFO_DEPTH-PROG_FULL_NEG_VALUE);


assign  empty       = (cnt_fifo <= 'd0);
assign  almost_empty= (cnt_fifo <= 'd1);
assign  prog_empty   = (cnt_fifo <= PROG_EMPTY_POS_VALUE);

assign  dout        = ram_doutb;
always@(posedge clk)
    begin
        if(rst)
            valid <= 1'b0;
        else if(rden_fifo)
            begin
                valid <= 1'b1;
            end
        else
            begin
                valid <= 1'b0;
            end 
    end

assign  ram_wea     = wren_fifo;
assign  ram_dina    = din;
assign  ram_web     = 1'b0;
assign  ram_dinb    = 'd0;  //端口b用来读}}}

//例化的ram ip    {{{
ram#(
     // Parameters
     .ADDR_WDT                          (FIFO_DEPTH),
     .DATA_WDT                          (FIFO_DWTH),
     .DOUT_REG                          (1'b1)) 
    u_ram(
          // Outputs
          .douta                        (),
          .doutb                        (ram_doutb),
          // Inputs
          .clka                         (clk),
          .clkb                         (clk),
          .rst                          (rst),
          .addra                        (ram_addra),
          .dina                         (ram_dina),
          .wea                          (ram_wea),
          .addrb                        (ram_addrb),
          .dinb                         (ram_dinb),
          .web                          (ram_web));/*}}}*/



endmodule

// Local Variables:
// verilog-library-directories:("." "./lib" "INST_PATH2")
// End:

