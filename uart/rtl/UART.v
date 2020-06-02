`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HFUTWDZ
// Engineer: Nie Yanshuo
// 
// Create Date:    13:40:21 05/16/2020 
// Design Name: {{{}}}
// Module Name:    UART
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
module UART(
    input			clk,
	input			rst,
	//TX
	input	[7:0]	tx_data_i,
	input 			tx_en_i,
	output			tx_rdy_o,
	input			cts_i,		//cts低电平有效，表示对方可以接收将要发送的数据
	output			tx_o,
	//RX
	input			rx_i,
	output			rts_o,		//低电平有效，通知发送方，本模块可以接收数据
	output	[7:0]	rx_data_o,
	output			rx_vld_o,
	input			rx_rdy_i
	);


TX_UART #(
		.FREQUENCY(100),	//MHz
		.BAUDRATE(115200)		//bautrate
	)
	u_TX_UART(
		.clk(clk), 
		.rst(rst), 
		.tx_data_i(tx_data_i), 
		.tx_en_i(tx_en_i), 
		.tx_rdy_o(tx_rdy_o), 
		.cts_i(cts_i),
		.tx_o(tx_o)
	);
RX_UART #(
		.FREQUENCY(100),	//MHz
		.BAUDRATE(115200)		//bautrate
	)
	u_RX_UART(
		.clk(clk), 
		.rst(rst), 
		.rx_i(rx_i), 
		.rx_frame_error_o(),//debug,without correct stop-bit
		.rts_o(rts_o),
		.rx_data_o(rx_data_o), 
		.rx_vld_o(rx_vld_o), 
		.rx_rdy_i(rx_rdy_i)
	);














endmodule
