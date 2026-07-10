`timescale 1ns / 1ps


module uart_tx(
    input wire clk,
    input wire reset,
    input wire baud_x16_tick,
    input wire [7:0] tx_data,
    input wire start_tx,
    output reg tx,
    output reg tx_busy
    );
    
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
    reg [1:0] PS,NS;
    reg [2:0] bit_counter;
    reg [3:0] tick_counter;
    reg [7:0] data_buffer;
    
    always @(posedge clk or posedge reset)begin
        if(reset)begin
            PS <= IDLE;
        end
        else begin 
            PS <= NS;
        end
    end
    
    always @(*)begin
        NS=PS;
        case(PS)
            IDLE : if(start_tx) NS = START;
            START : if(baud_x16_tick && tick_counter == 4'd15) NS = DATA;
            DATA : if (baud_x16_tick && tick_counter == 4'd15 && bit_counter == 3'd7) NS = STOP;
            STOP : if(baud_x16_tick && tick_counter == 4'd15) NS = IDLE;
        endcase
    end
    always @(posedge clk or posedge reset)begin
        if(reset)begin
            tx <= 1'b1; tx_busy <=1'b0; bit_counter <= 3'b0; tick_counter <= 4'd0; data_buffer <=8'd0;
        end
        else begin 
            case(PS)
                IDLE :  begin
                    tx <= 1'b1; tx_busy <=1'b0; bit_counter <= 3'b0; tick_counter <= 4'd0;
                    if(start_tx) begin
                        data_buffer <= tx_data;
                        tx_busy <= 1'b1;
                    end
                end
                START : begin 
                    tx <= 1'b0;
                    if(baud_x16_tick)begin
                        if(tick_counter == 4'd15)begin
                            tick_counter <= 4'd0;
                        end 
                        else begin 
                            tick_counter <= tick_counter+4'd1;
                        end
                    end
                 end
                 DATA : begin
                    tx <= data_buffer[bit_counter];
                    if(baud_x16_tick)begin
                        if(tick_counter == 4'd15)begin
                            tick_counter <= 4'd0;
                            if(bit_counter == 3'd7)begin
                                bit_counter <=3'd0 ;
                            end
                            else begin
                                bit_counter <= bit_counter + 3'd1;
                            end
                        end
                         else begin 
                            tick_counter <= tick_counter +4'd1;
                        end 
                    end
                                      
                 end
                 STOP:  begin
                    tx <= 1'b1;
                    if(baud_x16_tick)begin
                        if(tick_counter == 4'd15)begin
                            tick_counter <= 4'd0;
                            tx_busy <= 1'b0;
                        end 
                        else begin 
                            tick_counter <= tick_counter+4'd1;
                        end
                    end
                 end
            endcase
        end
    end
    
        

endmodule
