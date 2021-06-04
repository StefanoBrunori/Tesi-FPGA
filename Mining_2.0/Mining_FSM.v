`timescale 1ns / 1ps

module Mining_FSM(
    input clock,
    input reset,
    input start,
    input stopw,    
    input fine,    
    input wire [255:0] HASH,
        
    output reg [2:0] state,
    output reg [63:0] OUT     
    );
    
    always@(posedge clock) begin
        if (^state === 1'bx) state <= 3'h0;       
        
        //reset
        if (reset) begin
            state <= 3'h0;           
        end
        
        case (state) 
            3'h0: begin
                    OUT <= "Niente!";
                    state <= 3'h1;                                              
                  end        
                    
            3'h1: if (stopw) begin
                     state <= 3'h2;
                  end
                    
            3'h2: begin                  
                    state <= 3'h3;                  
                  end
            
            3'h3: state <= 3'h4;
            
            3'h4: state <= 3'h5;
            
            3'h5: if (fine) state <= 3'h6;
                  else state <= 3'h3;
                    
            3'h6: state <= 3'h7;
                  
            3'h7: begin
                if (HASH[255-:10] == 10'h0) begin
                     OUT <= "Trovato!";     
                end
                else begin
                    state <= 3'h2;
                end  
            end
            
        endcase
    end
    
endmodule
