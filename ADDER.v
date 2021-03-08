`timescale 1ns / 1ps

module ADDER(
    input CLK,
    input [7:0] A,
    input [7:0] B,
    output reg [8:0] S
    );
    
    always@ (posedge CLK) begin
        S = A+B;
    end
    
endmodule
