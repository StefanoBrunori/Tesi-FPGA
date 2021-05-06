`timescale 1ns / 1ps

module Memoria(
    input clk,
    input reset,
    input we,
    input re,
    input wire [8:0] indirizzo_write,
    input wire [8:0] indirizzo_read,
    input wire [7:0] dati, 
    input wire [1:0] state,
    output reg fine_scrittura,
    output reg fine_lettura,   
    output reg [7:0] out_mem
    );
    
    //La lunghezzza media di un blocco della blockchain è di ~1MB = 8388608 bit
    //Per questa struttura iniziale useremo un messaggio di 4096 bit
    parameter DATA_WIDTH = 8;
    parameter DATA_DEPTH = 512;
    //La mia memoria consisterà in 4 blocchi da 8 bit ciascuno
    reg [DATA_WIDTH-1:0] ram [0:DATA_DEPTH-1];       
    
              
    //Quando read_write = 0 viene eseguita una scrittura in memoria
    //Quando read_write = 1 viene eseguita una lettura in memoria    
    always@(posedge clk) begin        
        if (reset) begin
            fine_lettura <= 0;
            fine_scrittura <= 0;
            out_mem <= 8'h0;            
        end
        if (we) begin                                               
            ram[indirizzo_write] <= dati;            
        end    
         
        if (indirizzo_write == DATA_DEPTH-1 && we)
            fine_scrittura <= 1;
                    
        if (indirizzo_read == DATA_DEPTH-1 && re)
                fine_lettura <= 1;
                       
        if (re) begin                 
            out_mem <= ram[indirizzo_read];                               
        end                                                                                                   
    end
              
endmodule
