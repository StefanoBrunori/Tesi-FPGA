`timescale 1ns / 1ps


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
         
       
    // Controllo lo stato della FSM: se sta a 10 inizio la somma, se sta a 11 mando in output il risultato
    always@(posedge clk)
        if (reset) begin 
            i = 0;      
            adder <= 8'h0;
            out <= 13'h0;
            fine <= 0;
        end
        
        else begin        
            case(state)
                
                //Sommo gli 8 bit presi in input
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
