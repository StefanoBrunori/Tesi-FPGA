`timescale 1ns / 1ps

module Memoria(
    input clk,
    input reset,
    input we,    
    input wire [8:0] indirizzo_write,
    input wire [8:0] indirizzo_read,
    input wire [7:0] dati, 
    input wire [1:0] state,
    output reg fine_scrittura,
    output reg fine_lettura,   
    output reg [7:0] out_mem
    );
    
    //La lunghezzza media di un blocco della blockchain è di ~1MB = 8388608 bit
    parameter DATA_WIDTH = 8;
    parameter DATA_DEPTH = 512;
    //La mia memoria consisterà in 4 blocchi da 8 bit ciascuno
    reg [DATA_WIDTH-1:0] ram [0:DATA_DEPTH-1];       
    
                 
    always@(posedge clk) begin
        
        //Reset dei segnali di controllo e dei registri di appoggio        
        if (reset) begin
            fine_lettura <= 0;
            fine_scrittura <= 0;
            out_mem <= 8'h0;            
        end
        
        //Quando we (write enable) = 1 viene eseguita una lettura in memoria
        if (we) begin                                               
            ram[indirizzo_write] <= dati;            
        end    
         
        if (indirizzo_write == DATA_DEPTH-1 && we)
            fine_scrittura <= 1;
                    
        if (indirizzo_read == DATA_DEPTH-1 && ~we)
                fine_lettura <= 1;
        
        //In output viene costantemente mandato il contenuto della memoria all'indirizzo "indirizzo_read"                                        
        out_mem <= ram[indirizzo_read];                               
                                                                                                           
    end
              
endmodule
