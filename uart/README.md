用户端发送接口信号包括：tx_data_i,tx_en_i,tx_rdy_i,当tx_rdy_i为高电平时可以发送一个8bit的数据，tx_en_i为标志的有效数据信号

用户端接收接口信号包括：rx_data_o,rx_vld_o,rx_rdy_i,当用户端需要接收数据时，将rx_rdy_i拉高，否则拉低

该UART接口 1个开始位、8个数据位、一个停止位、无校验位
