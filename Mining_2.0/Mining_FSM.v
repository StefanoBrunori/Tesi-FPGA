`timescale 1ns / 1ps

module Mining_FSM(
    input clock,
    input reset,
    input start,
    input stopw,    
    input fine,
        
    output reg [2:0] state
    );
    
    always@(posedge clock) begin
        if (^state === 1'bx) begin
            state <= 3'b000;
        end
        
        //reset
        if (reset) begin
            state <= 3'b000;
        end
        
        case (state) 
            3'b000: if (start) begin
                        state <= 3'b001;
                    end
                    
            3'b001: if (stopw) begin
                        state <= 3'b010;
                    end
                    
            3'b010: state <= 3'b011;
            
            3'b011: begin                                                                 
                        if (fine) begin
                            state <= 3'b111;
                        end
                        else state <= 3'b100;                                              
                    end
                    
            3'b100: state <= 3'b101;
            
            3'b101: state <= 3'b110;
            
            3'b110: state <= 3'b011;
                                       
            3'b111: begin
                    end 
        endcase
    end
    
endmodule
