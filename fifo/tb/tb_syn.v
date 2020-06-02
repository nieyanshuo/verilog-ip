`timescale 1ns/100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HFUTWDZ
// Engineer: Nie Yanshuo
// Email: nieyanshuo@163.com 
//
// Create Date: 202-/--/--   --:--:--
// Design Name: fifo_syn
// Module Name: tb_syn
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
    
module tb_syn;
parameter   FIFO_DWTH = 4;
parameter   FIFO_DEPTH = 10;
parameter   PROG_FULL_NEG_VALUE = 4;
parameter   PROG_EMPTY_POS_VALUE = 4;
// Beginning of automatic inputs (from unused autoinst inputs)
reg                   clk;                    // To u_fifo_syn of fifo_syn.v
reg [FIFO_DWTH-1:0]   din;                    // To u_fifo_syn of fifo_syn.v
reg                   rden;                   // To u_fifo_syn of fifo_syn.v
reg                   rst;                    // To u_fifo_syn of fifo_syn.v
reg                   wren;                   // To u_fifo_syn of fifo_syn.v
// End of automatics
// Beginning of automatic outputs (from unused autoinst outputs)
wire                  almost_empty;           // From u_fifo_syn of fifo_syn.v
wire                  almost_full;            // From u_fifo_syn of fifo_syn.v
wire [FIFO_DWTH-1:0]  dout;                   // From u_fifo_syn of fifo_syn.v
wire                  empty;                  // From u_fifo_syn of fifo_syn.v
wire                  full;                   // From u_fifo_syn of fifo_syn.v
wire                  prog_empty;             // From u_fifo_syn of fifo_syn.v
wire                  prog_full;              // From u_fifo_syn of fifo_syn.v
wire                  valid;                  // From u_fifo_syn of fifo_syn.v
// End of automatics

/*AUTOREG*/

/*AUTOWIRE*/


/*varibale defime be myself*/
reg                     wrfifo_sig;
reg                     rdfifo_sig;
reg                     wr_done;
reg                     rd_done;

/*logic circuit*/
always #5 clk = !clk;
initial begin
    clk = 0;
    rst = 1;
    wrfifo_sig=0;
    rdfifo_sig=0;
    wren =0;
    din =0;
    rden = 0;
    wr_done=0;
    rd_done =0;
    
    #105;
    rst = 0;

    //add simulate
    @(posedge clk)
    wrfifo_sig =1;
    @(posedge clk)
    @(posedge clk)
    wrfifo_sig =0;
    $display("########write 1");
    //read
    #100;
    @(posedge clk)
    rdfifo_sig =1;
    @(posedge clk)
    @(posedge clk)
    rdfifo_sig =0;
    $display("########read 1");


    wait(wr_done);
    wait(rd_done);

    //write
    #500;
    @(posedge clk)
    wrfifo_sig =1;
    @(posedge clk)
    @(posedge clk)
    wrfifo_sig =0;
    $display("########write 2");
    //write
    wait(wr_done);
    #500;
    @(posedge clk)
    wrfifo_sig =1;
    @(posedge clk)
    @(posedge clk)
    wrfifo_sig =0;
    $display("########write 3");
    //write
    wait(wr_done);
    #500;
    @(posedge clk)
    wrfifo_sig =1;
    @(posedge clk)
    @(posedge clk)
    wrfifo_sig =0;
    $display("########write 4");
    wait(wr_done);
    
    //read
    #100;
    @(posedge clk)
    rdfifo_sig =1;
    @(posedge clk)
    @(posedge clk)
    rdfifo_sig =0;
    $display("########read 2");
    wait(rd_done);
    #1000;
    $finish;
end

initial begin
    wrdata2fifo_monitor;
end

initial begin
    rddata_from_fifo_monitor;
end


    
task wrdata2fifo_monitor;
    forever begin
        @(posedge wrfifo_sig)
            $display("###########execute task write");
            wrdata2fifo_tk;
    end
endtask

    
task rddata_from_fifo_monitor;
    forever begin
        @(posedge rdfifo_sig)
            $display("###########execute task read");
            rddata_from_fifo_tk;
    end
endtask



//task 
task wrdata2fifo_tk;
begin
    repeat(500) begin 
        @(posedge clk);
        #1 wren = 1'b1;
        din = din +1;
    end
    @(posedge clk);
    #1 wren=0;
    wr_done = 1;
    $display("############write done");
    @(posedge clk);
    @(posedge clk);
    #1 wr_done =0;
end
endtask


//task 
task rddata_from_fifo_tk;
begin
    repeat(500) begin 
        @(posedge clk);
        #1 rden = 1'b1;
end
    @(posedge clk);
    #1 rden=0;
    rd_done = 1;
    $display("############read done");
    @(posedge clk);
    @(posedge clk);
    #1 rd_done =0;
end
endtask



initial begin
    $fsdbDumpfile("tb_syn.fsdb");
    $fsdbDumpSVA;
    $fsdbDumpvars(0,tb_syn,"+all");
end



    
fifo_syn#(
          // Parameters
          .FIFO_DEPTH                   (FIFO_DEPTH),
          .FIFO_DWTH                    (FIFO_DWTH),
          .PROG_FULL_NEG_VALUE          (PROG_FULL_NEG_VALUE),
          .PROG_EMPTY_POS_VALUE         (PROG_EMPTY_POS_VALUE)) 
    u_fifo_syn(
               // Outputs
               .dout                    (dout),
               .valid                   (valid),
               .full                    (full),
               .empty                   (empty),
               .almost_full             (almost_full),
               .almost_empty            (almost_empty),
               .prog_full               (prog_full),
               .prog_empty              (prog_empty),
               // Inputs
               .clk                     (clk),
               .rst                     (rst),
               .din                     (din),
               .wren                    (wren),
               .rden                    (rden));


endmodule

// Local Variables:
// verilog-library-directories:("." "../rtl" "INST_PATH2")
// End:

