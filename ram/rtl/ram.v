`timescale 1ns/100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HFUTWDZ
// Engineer: Nie Yanshuo
// Email: nieyanshuo@163.com 
//
// Create Date: 2020/06/01   --:--:--
// Design Name: ram ip
// Module Name: ram
// Project Name: ram
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
    
module ram#(
    parameter   ADDR_WDT = 10,
    parameter   DATA_WDT = 8,
    parameter   DOUT_REG =1'b1
)
(/*AUTOARG*/
   // Outputs
   douta, doutb,
   // Inputs
   clk, rst, addra, dina, wea, addrb, dinb, web
   );

/*AUTOINPUT*/
    input                       clk;
    input                       rst;
    input   [ADDR_WDT-1 : 0]    addra;
    input   [DATA_WDT-1 : 0]    dina;
    input                       wea;
    input   [ADDR_WDT-1 : 0]    addrb;
    input   [DATA_WDT-1 : 0]    dinb;
    input                       web;
/*AUTOOUTPUT*/
    output  [DATA_WDT-1 : 0]    douta;    
    output  [DATA_WDT-1 : 0]    doutb;    


/*AUTOREG*/

/*AUTOWIRE*/

reg     [DATA_WDT-1 : 0]    regs    [0 : 2**ADDR_WDT-1];  //寄存器组
reg     [DATA_WDT-1 : 0]    douta_r;
wire    [DATA_WDT-1 : 0]    douta_w;
reg     [DATA_WDT-1 : 0]    doutb_r;
wire    [DATA_WDT-1 : 0]    doutb_w;


always@(posedge clk)
    begin
        if(wea)
            regs[addra] <= dina;
    end

always@(posedge clk)
    begin
        if(web&(addra != addrb))
            regs[addrb] <= dinb;
    end


//ram端口a输出{{{ 
always@(posedge clk)
    begin
        if(rst)
            douta_r <= 'd0;
        else if(!wea)
            begin
                douta_r <= regs[addra];
            end
    end

assign  douta_w = regs[addra];

assign  douta = (DOUT_REG==1'b1) ? douta_r : douta_w;/*}}}*/

//ram端口b输出{{{
always@(posedge clk)
    begin
        if(rst)
            doutb_r <= 'd0;
        else if(!web)
            begin
                doutb_r <= regs[addrb];
            end
    end

assign  doutb_w = regs[addrb];

assign  doutb = (DOUT_REG==1'b1) ? doutb_r : doutb_w;/*}}}*/







endmodule

// Local Variables:
// verilog-library-directories:("." "INST_PATH1" "INST_PATH2")
// End:

