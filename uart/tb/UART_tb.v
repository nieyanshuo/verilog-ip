`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:45:40 05/16/2020
// Design Name:   UART_tb
// Module Name:   
// Project Name:  UART
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top_uart
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module UART_tb;

	// Inputs 
	reg 	    	clk; 
	reg 		    rst;
	//RX
	reg      		rx_i;
	wire	    	rts_o;
	wire	[7:0]	rx_data_o;
	wire		    rx_vld_o;
	reg		        rx_rdy_i;
	wire 		    rx_error_o;
	
	// TX
	reg	        	cts_i;
	wire 		    tx_o;
	reg	    [7:0]	tx_data_i;
	reg		        tx_en_i;
    wire            tx_rdy_o;

	// Instantiate the Unit Under Test (UUT)
	UART u_UART (
		.clk        (clk), 
		.rst        (rst), 
		//TX
        .tx_data_i  (tx_data_i),
        .tx_en_i    (tx_en_i),
        .tx_rdy_o   (tx_rdy_o),
		.cts_i		(cts_i),
		.tx_o       (tx_o),
		//RX
		.rx_data_o  (rx_data_o),
        .rx_vld_o   (rx_vld_o),
        .rx_rdy_i   (rx_rdy_i),
        .rts_o		(rts_o),
		.rx_i       (rx_i)
	);

    initial begin
        clk = 0;
        rst = 1;
    	cts_i = 1;
	    rx_i = 1;
	    rx_rdy_i = 1;
	    tx_en_i=0;
        #100;
        rst = 0;
        #100;
	    uart_rx_tk(8'h87);
	    uart_rx_tk(8'hFF);
    	uart_rx_tk(8'hF0);
	    
        #100;
	    uart_tx_tk(8'h11);
	    uart_tx_tk(8'hF1);
	    uart_tx_tk(8'hFF);
	
	    wait(tx_rdy_o&rts_o);
    	#50000;
	    $finish;

    end

initial begin
        $fsdbDumpfile("UART_tb.fsdb");
        $fsdbDumpSVA;
        $fsdbDumpvars(0,UART_tb,"+all");
end



initial begin
	monitor_rx;
end


task uart_rx_tk;
	input	[7:0]	data;
	
	wait(rts_o);
	rx_i=0;
	repeat(868) begin
		@(posedge clk);
	end
	rx_i=data[0];
	repeat(868) begin
		@(posedge clk);
	end
	rx_i=data[1];
	repeat(868) begin
		@(posedge clk);
	end
	rx_i=data[2];
	repeat(868) begin
		@(posedge clk);
	end
	rx_i=data[3];
	repeat(868) begin
		@(posedge clk);
	end
	rx_i=data[4];
	repeat(868) begin
		@(posedge clk);
	end
	rx_i=data[5];
	repeat(868) begin
		@(posedge clk);
	end
	rx_i=data[6];
	repeat(868) begin
		@(posedge clk);
	end
	rx_i=data[7];
	
	repeat(868) begin
		@(posedge clk);
	end
	rx_i=1;
	repeat(868) begin
		@(posedge clk);
	end

endtask


task uart_tx_tk;
	input	[7:0]	tx_data_tk;
	wait(tx_rdy_o)	
	@(posedge clk)
	tx_data_i = tx_data_tk;
	tx_en_i   = 1'b1;
	@(posedge clk)
	tx_en_i   = 1'b0;
	@(posedge clk);
endtask





task monitor_rx;
	forever begin
		@(posedge clk)
		if(rx_vld_o)
			begin
				$display("###########################################################");
				$display("################recieve data is %x#########################",rx_data_o);
				$display("###########################################################");
			end
	
	end
endtask







always #5 clk = !clk;

endmodule
