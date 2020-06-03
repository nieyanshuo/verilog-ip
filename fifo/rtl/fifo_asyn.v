`timescale 1ns/100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HFUTWDZ
// Engineer: Nie Yanshuo
// Email: nieyanshuo@163.com 
//
// Create Date: 2020/06/03   --:--:--
// Design Name: fifo_asyn
// Module Name: fifo_asyn
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
module fifo_asyn#(
    parameter   FIFO_DEPTH = 10,    //Actual depth is 2**FIFO_DEPTH 
    parameter   FIFO_DWTH = 8    
)
(/*AUTOARG*/
   // Outputs
   dout, valid, full, empty,
   // Inputs
   clk_w, clk_r, rst, din, wren, rden
   );
input                           clk_w;
input                           clk_r;
input                           rst;
input       [FIFO_DWTH-1 :0]    din;    
input                           wren;
input                           rden;
output      [FIFO_DWTH-1 :0]    dout;    
output                          valid;
output                          full;
output                          empty;

/*AUTOREG*/
// Beginning of automatic regs (for this module's undeclared outputs)
reg                     valid;
// End of automatics

/*AUTOWIRE*/


/*varibale defime be myself*/
reg      [FIFO_DEPTH:0]         ram_addra;                  // To u_ram of ram.v
wire                            ram_wea;                    // To u_ram of ram.v
wire     [FIFO_DWTH-1:0]        ram_dina;                   // To u_ram of ram.v
reg      [FIFO_DEPTH:0]         ram_addrb;                  // To u_ram of ram.v
wire                            ram_web;                    // To u_ram of ram.v
wire     [FIFO_DWTH-1:0]        ram_dinb;                   // To u_ram of ram.v
wire     [FIFO_DWTH-1:0]        ram_doutb;                  // From u_ram of ram.v

wire                            wren_fifo;
wire                            rden_fifo;

wire     [FIFO_DEPTH:0]       ram_addra_gray;             // To u_ram of ram.v
reg      [FIFO_DEPTH:0]       ram_addra_gray_r1;          // To u_ram of ram.v
reg      [FIFO_DEPTH:0]       ram_addra_gray_r2;          // To u_ram of ram.v
wire     [FIFO_DEPTH:0]       ram_addrb_gray;             // To u_ram of ram.v
reg      [FIFO_DEPTH:0]       ram_addrb_gray_r1;          // To u_ram of ram.v
reg      [FIFO_DEPTH:0]       ram_addrb_gray_r2;          // To u_ram of ram.v
/*logic circuit*/
assign  wren_fifo   = wren & !full;
assign  rden_fifo   = rden & !empty;


//timing logic block,ram a 端口作为写{{{
always@(posedge clk_w)
    begin
        if(rst)
            ram_addra <= 'd0;
        else if(wren_fifo)
            begin
                if(&ram_addra)
                    ram_addra <= 'd0;
                else
                    ram_addra <= ram_addra + 'd1;
            end
    end
assign  ram_addra_gray  =   ({1'b0,ram_addra[FIFO_DEPTH : 1]} ^ ram_addra); /*}}}*/

//timing logic block,ram b 端口作为读{{{
always@(posedge clk_r)
    begin
        if(rst)
            ram_addrb <= 'd0;
        else if(rden_fifo)
            begin
                if(&ram_addrb)
                    ram_addrb <= 'd0;
                else
                    ram_addrb <= ram_addrb + 'd1;
            end
    end
assign  ram_addrb_gray  =   ({1'b0,ram_addrb[FIFO_DEPTH : 1]} ^ ram_addrb); /*}}}*/


//timing logic block,write addr syn to read clock{{{
always@(posedge clk_r)
    begin
        if(rst)
            begin
                ram_addra_gray_r1 <= 'd0;
                ram_addra_gray_r2 <= 'd0;
            end
        else
            begin
                ram_addra_gray_r1 <= ram_addra_gray;
                ram_addra_gray_r2 <= ram_addra_gray_r1;
            end
    end/*}}}*/


//timing logic block,read addr syn to write clock{{{
always@(posedge clk_w)
    begin
        if(rst)
            begin
                ram_addrb_gray_r1 <= 'd0;
                ram_addrb_gray_r2 <= 'd0;
            end
        else
            begin
                ram_addrb_gray_r1 <= ram_addrb_gray;
                ram_addrb_gray_r2 <= ram_addrb_gray_r1;
            end
    end/*}}}*/

/*{{{*/
assign  full    =   (&(ram_addra_gray[FIFO_DEPTH:FIFO_DEPTH-1] ^ ram_addrb_gray_r2[FIFO_DEPTH:FIFO_DEPTH-1]) 
                    && (ram_addra_gray[FIFO_DEPTH-2:0] == ram_addrb_gray_r2[FIFO_DEPTH-2:0]));

assign  empty   =   (ram_addrb_gray == ram_addra_gray_r2);


assign  dout    =   ram_doutb;
//timing logic block,output valid
always@(posedge clk_r)
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


//ram control signal
assign  ram_wea     =   wren_fifo;
assign  ram_dina    =   din;
assign  ram_web     =   1'b0;
assign  ram_dinb    =   'd0;/*}}}*/

//instance{{{
ram#(
     // Parameters
     .ADDR_WDT                          (FIFO_DEPTH),
     .DATA_WDT                          (FIFO_DWTH),
     .DOUT_REG                          (1'b1)) 
_ram(
          // Outputs
          .douta                        (),
          .doutb                        (ram_doutb),
          // Inputs
          .clka                         (clk_w),
          .clkb                         (clk_r),
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
