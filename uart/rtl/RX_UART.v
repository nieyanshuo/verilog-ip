`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HFUTWDZ
// Engineer: Nie Yanshuo
// 
// Create Date:    13:41:37 05/16/2020 
// Design Name: 
// Module Name:    RX_UART 
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
module RX_UART#
	(
	parameter	FREQUENCY = 130,	//MHz
	parameter	BAUDRATE  = 9600	//波特率
	)
	(
	input 			clk,
	input		 	rst,
	input			rx_i,
	output			rx_frame_error_o,
	output			rts_o,		//低电平有效，通知发送方，本模块可以接收数据
	output	[7:0]	rx_data_o,
	output			rx_vld_o,
	input			rx_rdy_i
    );

parameter	RX_IDLE 	= 3'd0,
			RX_START	= 3'd1,
			RX_BIT		= 3'd2,
			RX_STOP		= 3'd3,
			RX_DONE		= 3'd4;

wire	[31:0]		Period_num; 
wire	[31:0]		Period_num_half;
reg 	[31:0] 		cnt_baudrate;
reg		[3:0]		index;

reg		[7:0]		rx_data;
reg					rx_left;
reg					rx_right;
wire				rx_sof;
wire				rx_eof;
reg					rx_recive_ing;


wire 				rx_period_full;	
wire				rx_period_middle;		

reg		[2:0]		state_c;
reg		[2:0]		state_n;
assign	Period_num 		= (FREQUENCY*1000000)/BAUDRATE;
assign	Period_num_half = Period_num/2;
assign 	rx_period_full = (cnt_baudrate==Period_num);
assign 	rx_period_middle = (cnt_baudrate==Period_num_half);

//检测开始边沿，两级寄存防止异步信号的亚稳态
always@(posedge clk)
    begin
		if(rst)
			rx_right <= 1'b1;
		else
			rx_right <= rx_i;
	end
always@(posedge clk)
	begin
		if(rst)
			rx_left <= 1'b1;
		else
			rx_left <= rx_right;
	end
assign	rx_sof = rx_recive_ing ? 1'b0 : rx_left&!rx_right;		//rx下降沿

assign	rx_eof = (state_c == RX_DONE & rx_rdy_i);

//开始接收数据
always@(posedge clk)
	begin
		if(rst) 
			rx_recive_ing=1'b0;
		else if(rx_eof) 
			rx_recive_ing=1'b0;
		else if(rx_sof) 
			rx_recive_ing=1'b1;
	end

//波特率设置
always@(posedge clk)
	begin
		if(rst) 
			cnt_baudrate<='d0;
		else if(rx_recive_ing)
			begin
				if(rx_period_full) 
					cnt_baudrate<='d0;
				else 
					cnt_baudrate<=cnt_baudrate+'d1;
			end
		else 
			cnt_baudrate<='d0;
	end

//接收数据
always@(posedge clk)
	begin
		if(rst)
			state_c <= RX_IDLE;
		else
			state_c <= state_n;
	end
always@(*)
	begin
		case(state_c)
			RX_IDLE	: 	begin
							if(rx_sof)
								state_n = RX_START;
							else
								state_n = RX_IDLE;
						end
				
			RX_START: 	begin	
							if(rx_period_full)
								state_n = RX_BIT;
							else
								state_n = RX_START;
						end
						
			RX_BIT	: 	begin 
							if(index=='d8 && rx_period_full)
								state_n = RX_STOP;
							else
								state_n = RX_BIT;
						end
						
			RX_STOP	: 	begin	
							if(rx_period_middle)	//停止位为1
								begin
									if(rx_i)
										state_n = RX_DONE;
									else
										state_n = RX_IDLE;
								end	
							else
								state_n = RX_STOP;	
						end		
			
			RX_DONE	:	if(rx_rdy_i)	
							state_n = RX_IDLE;
						else
							state_n = RX_DONE;
			
			default	: 			state_n = RX_IDLE;
		endcase
	end
assign rts_o = state_c == RX_IDLE;


//////////////////////////////////////////////////////////////////////
reg					rx_error;
always@(posedge clk)
	begin
		if(rst)
			rx_error <= 1'b0;
		else if(state_c == RX_STOP && rx_period_middle && !rx_i)
			rx_error <= 1'b1;
	end
assign rx_frame_error_o = rx_error;
//////////////////////////////////////////////////////////////////////


always@(posedge clk)
	begin
		if(rst)
			index <= 'd0;
		else if(rx_sof)
			index <= 'd0;
		else if(state_c == RX_BIT && rx_period_middle)
			index <= index + 'd1;
	end
always@(posedge clk)
	begin
		if(rst)
			rx_data <= 8'd0;
		else if(rx_sof)
			rx_data <= 8'd0;
		else if(state_c == RX_BIT && rx_period_middle)
			rx_data[index] <= rx_i;
	end
assign	rx_data_o = rx_data;
assign	rx_vld_o = (state_c == RX_DONE);
endmodule
