`timescale 1ns / 1ps

module baud_gen(
    input wire clk,
    input wire reset,
    output reg baud_x16_tick
);
    reg [9:0] count;
    always @(posedge clk or posedge reset)begin
        if(reset)begin
            baud_x16_tick <= 0;
            count <= 10'd0;
        end
        else begin
            if(count == 10'd650)begin
                count <= 10'd0;
                baud_x16_tick <= 1;
             end 
             else begin
                count <= count + 10'd1;
                baud_x16_tick <= 0;
             end
        end
    end
        
endmodule
