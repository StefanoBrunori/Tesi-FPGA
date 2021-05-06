`timescale 1ns / 1ps

//SHA-256 output for "": e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

module Adder(
    input wire [7:0] in,
    
    input clk,
    input reset,
    
    input[1:0] state,    
    
    output reg fine,
    output reg [12:0] out
    );
       
    
    //Inizio della Funzione: "Somma dei bit del messaggio"
    
    
    //Dichiarazione variabili e registri d'appoggio
    integer i = 0;
    reg [12:0] adder;
         
       
    // Controllo lo stato della FSM: se sta a 01 inizio la somma, se sta a 10 mando in output il risultato
    always@(posedge clk)
        if (reset) begin 
            i = 0;      
            adder <= 8'h0;
            out <= 13'h0;
            fine <= 0;
        end
        
        else begin        
            case(state)
                
                //In questo stato l'adder non esegue operazioni
                2'b00 : begin 
                end
                
                //Libero il registro di appoggio "adder"
                2'b01 : begin
                    adder <= 8'h0;
                end 
                
                //Eseguo la somma degli 8 bit
                2'b10 : begin                     
                    for (i=0;i<=7;i=i+1) begin
                        adder = adder+in[i];                                            
                    end                                                                                                               
                end
                    
                //Mando in output il risultato        
                2'b11 : begin
                   out <= adder;                    
                   fine <= 1;                                    
                end
            endcase
        end
    
endmodule
