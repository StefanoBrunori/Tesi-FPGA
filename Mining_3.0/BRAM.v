`timescale 1ns / 1ps


module Memoria(
    input clock, 
    input [15:0] addr,
    input [8:0] addr_width,     
    input cs_n,
    input wr_n, 
    input rd_n,    
    input [31:0] bram_data_in,
    
    output reg [511:0] bram_data_out
    );
    
    parameter BRAM_ADDR_WIDTH = 500;
    parameter BRAM_DATA_WIDTH = 512;

    reg [BRAM_DATA_WIDTH-1:0] mem [0:BRAM_ADDR_WIDTH-1];

    always @(posedge clock) begin        
                       
        if (cs_n == 1'b0) begin
            begin
                if (wr_n == 1'b0) mem[addr][addr_width-:32] <= bram_data_in; 
                                 
                if (rd_n == 1'b0) bram_data_out <= mem[addr];               
            end
        end 
    end
                                             
endmodule
