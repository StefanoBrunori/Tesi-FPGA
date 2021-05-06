`timescale 1ns / 1ps


module FSM(

    input start,
    input clk,
    input reset,
    
    output reg we,
    output reg re,
    
    input fine_scrittura,
    input fine_lettura,
    input fine, 
    
    output reg [8:0] indirizzo_read,
    output reg [8:0] state
    );
    
                   
    always@(posedge clk) begin
        if (fine) begin
            state <= 2'b00;
            we <= 0;
            re <= 0;
        end
        if (reset) begin
            indirizzo_read <= 9'h0;            
            state <= 2'b00;
            we <= 1;
            re <= 0;
        end
        
        else begin        
            if (start) begin
                state <= 2'b01;
                we <= 1;
                re <= 0;                       
            end
            
            if (fine_scrittura) begin
                if (state == 2'b10) begin
                    indirizzo_read <= indirizzo_read + 1;
                end
                else begin
                    state <= 2'b10;
                    we <= 0;
                    re <= 1;
                    indirizzo_read <= 10'h0;
                end
            end           
            
            if (fine_lettura) begin
                state <= 2'b11;
                re <= 0;
            end                
        end                  
    end    
                      
endmodule
