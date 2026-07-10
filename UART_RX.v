`timescale 1ns / 1ps

module uart_rx(
    input wire clk,
    input wire reset,
    input wire baud_x16_tick,
    input wire rx,
    output reg [7:0] rx_data,
    output reg rx_done
    );
    
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
    reg [1:0] PS,NS;
    reg [2:0] bit_counter;
    reg [3:0] tick_counter;
    reg [7:0] rx_shift_reg;
    
    always @(posedge clk or posedge reset)begin
        if(reset)begin
            PS <= IDLE;
        end
        else begin 
            PS <= NS;
        end
    end
    
    always @(*) begin
        NS = PS;
        case(PS)
            IDLE : if(rx==1'b0) NS = START;
            START : if(baud_x16_tick && tick_counter == 4'd7) NS =DATA;
            DATA :  if (baud_x16_tick && tick_counter == 4'd15 && bit_counter == 3'd7) NS = STOP;
            STOP : if(baud_x16_tick && tick_counter == 4'd15) NS =IDLE;
        endcase
    end
    always @(posedge clk or posedge reset)begin
        if(reset)begin
            rx_data <= 8'd0; rx_done <= 0;bit_counter <= 3'd0; tick_counter <= 4'd0; rx_shift_reg <= 8'd0;
        end
        else begin 
            rx_done <= 1'b0;
            case(PS)
                IDLE : begin
                    tick_counter <= 4'd0;
                    bit_counter <= 3'd0;
                    end
                START : begin
                    if(baud_x16_tick)begin
                        if(tick_counter == 4'd7)begin
                            tick_counter <=0;
                        end
                        else begin 
                            tick_counter <= tick_counter + 4'd1;
                         end
                    end
                   
                end
                DATA : begin
                    if(baud_x16_tick)begin
                        if(tick_counter == 4'd15)begin
                            tick_counter <= 4'd0 ;
                            rx_shift_reg <= {rx,rx_shift_reg[7:1]};
                            if(bit_counter == 3'd7)begin
                                bit_counter <= 3'd0;
                            end
                            else begin
                                bit_counter <= bit_counter+ 3'd1;
                             end
                        end
                        else begin 
                             tick_counter <= tick_counter + 4'd1;
                        end
                    end 
                end
                STOP : begin
                    if(baud_x16_tick)begin
                        if(tick_counter == 4'd15)begin
                            tick_counter <= 4'd0;
                            rx_data <= rx_shift_reg;
                            rx_done <=1;
                        end
                        else begin 
                            tick_counter <= tick_counter + 4'd1;
                        end
                    end
                end
            endcase
        end
    end

endmodule
