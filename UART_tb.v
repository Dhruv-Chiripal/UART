`timescale 1ns / 1ps


module uart_tb();
    reg clk;
    reg reset;
    reg [7:0] tx_data;
    reg start_tx;
    reg rx_pin;
    reg loopen;
    
    wire tx_busy;
    wire tx_pin;
    wire rx_done;
    wire [7:0] rx_data;
    
  
    top_module uut (clk,reset, tx_data,start_tx,rx_pin,tx_busy, tx_pin, rx_data, rx_done,loopen);

    // 100MHz Clock Generation
    always #5 clk = ~clk;
  
    initial begin
        $monitor("Time = %0t ns | Reset = %b | TX_busy = %b | RX_Done = %b | RX_Data = 0x%h", 
                 $time, reset, tx_busy, rx_done, rx_data);
    end
    
    initial begin
        // Initial setup
        clk = 0; 
        reset = 1; 
        tx_data = 8'b0; 
        start_tx = 0; 
        rx_pin = 1; 
        loopen = 1; 
        
        #100;
        reset = 0; 
        #50;
        
        // --- First Data: 'A' (0x41) ---
        tx_data = 8'h41; 
        start_tx = 1;
        #10;             
        start_tx = 0;
        
        #1100000;        // 1.1 ms delay in nanoseconds format!
        
        // --- Second Data: 'Z' (0x5A) ---
        tx_data = 8'h5A; 
        start_tx = 1;
        #10;
        start_tx = 0;
        
        #1100000;        //1.1 ms delay
        
        #5000;
        $display("DONE");
        $finish;
    end
        
endmodule
