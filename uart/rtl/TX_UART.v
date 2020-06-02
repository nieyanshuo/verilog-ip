`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HFUTWDZ
// Engineer: Nie Yanshuo
// 
// Create Date:    13:41:21 05/16/2020 
// Design Name: 
// Module Name:    TX_UART 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module TX_UART#
	(
	parameter	FREQUENCY = 130,	//MHz
	parameter	BAUDRATE  = 9600	//波特率
	)
	(
	input 			clk,
	input		 	rst,
	input	[7:0]	tx_data_i,
	input 			tx_en_i,
	output			tx_rdy_o,
	input			cts_i,		//cts低电平有效，表示对方可以接收将要发送的数据
	output  		tx_o
    );
parameter	TX_IDLE 	= 2'd0,
			TX_START	= 2'd1,
			TX_BIT		= 2'd2,
			TX_STOP		= 2'd3;

wire	[31:0]		Period_num; 
wire	[31:0]		Period_num_half;
reg 	[31:0] 		cnt_baudrate;
reg		[2:0]		index;

reg		[7:0]		tx_data;
wire				tx_sof;
wire				tx_eof;
reg 				tx_send_ing;
wire 				tx_period_full;			
reg					tx;
reg		[1:0]		state_c;
reg		[1:0]		state_n;


assign	Period_num 		= (FREQUENCY*1000000)/BAUDRATE;
assign	Period_num_half = Period_num/2;
assign 	tx_period_full = (cnt_baudrate==Period_num);

assign	tx_sof = tx_rdy_o & tx_en_i;	//检测发送上升沿
assign	tx_eof = (state_c == TX_STOP)&tx_period_full;

//寄存待发送数据
always@(posedge clk)
	begin
		if(rst)
			tx_data <= 'd0;
		else if(tx_sof)
			tx_data <= tx_data_i;
	end

//开始发送
always@(posedge clk)
	begin
		if(rst) 
			tx_send_ing <= 1'b0;
		else if(tx_eof) 
			tx_send_ing <= 1'b0;
		else if(tx_sof) 
			tx_send_ing <= 1'b1;
	end
assign	tx_rdy_o = cts_i&!tx_send_ing;  //cts低电平有效，表示对方可以接收将要发送的数据 

//波特率设置
always@(posedge clk)
	begin
		if(rst) 
			cnt_baudrate<='d0;
		else if(tx_send_ing)
			begin
				if(tx_period_full) 
					cnt_baudrate<='d0;
				else 
					cnt_baudrate<=cnt_baudrate+'d1;
			end
		else 
			cnt_baudrate<='d0;
	end


//发送数据
always@(posedge clk)
	begin
		if(rst)
			state_c <= TX_IDLE;
		else
			state_c <= state_n;
	end
always@(*)
	begin
		case(state_c)
			TX_IDLE	: 	begin
							if(tx_sof)
								state_n = TX_START;
							else
								state_n = TX_IDLE;
						end
				
			TX_START: 	begin	
							if(tx_period_full)
								state_n = TX_BIT;
							else
								state_n = TX_START;
						end
						
			TX_BIT	: 	begin 
							if(index=='d7 && tx_period_full)
								state_n = TX_STOP;
							else
								state_n = TX_BIT;
						end
						
			TX_STOP	: 	begin	
							if(tx_period_full)
								state_n = TX_IDLE;
							else
								state_n = TX_STOP;	
						end		

			default	: 			state_n = TX_IDLE;
		endcase
	end
 
always@(posedge clk)
	begin
		if(rst)
			index <= 'd0;
		else if(tx_sof)
			index <= 'd0;
		else if(state_c == TX_BIT && tx_period_full)
			index <= index + 'd1;
	end

always@(*)
	begin
			case(state_c)
				TX_IDLE	:	tx = 1'b1;
			
				TX_START:	tx = 1'b0;

				TX_BIT  :	tx = tx_data[index];

				TX_STOP	:	tx = 1'b1;
	
				default	:	tx = 1'b1;
			endcase
	end
	
assign	tx_o = tx;

endmodule
