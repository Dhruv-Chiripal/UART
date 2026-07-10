`timescale 1ns / 1ps

module top_module(
    input wire clk,
    input wire reset,
    input wire [7:0] tx_data,
    input wire start_tx,
    input wire rx_pin,
    output wire tx_busy,
    output wire tx_pin,
    output wire [7:0] rx_data,
    output wire rx_done,
    input loopen
    );
    wire baud_x16_tick;
   
    wire rx_in_wire;
    
    assign rx_in_wire = loopen ? tx_pin : rx_pin;
    
    
    baud_gen dut1(.clk(clk),.reset(reset),.baud_x16_tick(baud_x16_tick));
    
    uart_tx dut2(.clk(clk), .reset(reset),.baud_x16_tick(baud_x16_tick), .tx_data(tx_data),.start_tx(start_tx),.tx_busy(tx_busy),.tx(tx_pin));
    
    uart_rx dut3(.clk(clk),.reset(reset),.baud_x16_tick(baud_x16_tick), .rx(rx_in_wire), .rx_data(rx_data), .rx_done(rx_done));
    
    
endmodule
