`timescale 1ns / 1ps

module Mining_FSM(
    input clock,
    input reset,
    input start,
    input stopw,    
    input fine,
    input fine_mining,
        
    output reg [2:0] state,
    output reg [63:0] OUT,
    output reg reset_fsm,
    output reg [31:0] NONCE,
    output reg nonce_flag 
    );
    
    always@(posedge clock) begin
        if (^state === 1'bx) state <= 3'b000;       
        
        //reset
        if (reset) begin
            state <= 3'b000;
            NONCE <= 32'h0;
            nonce_flag <= 1'b0;
        end
        
        case (state) 
            3'b000: if (start) begin
                        OUT <= "Niente!";
                        state <= 3'b001;
                        NONCE <= 32'h0;
                        nonce_flag <= 1'b0;
                    end
                    
            3'b001: if (stopw) begin
                        state <= 3'b010;
                    end
                    
            3'b010: begin
                        if (fine_mining) begin
                            OUT <= "Trovato!";
                            state <= 3'b111;                               
                        end
                        state <= 3'b011;
                        reset_fsm <= 1'b0;
                    end
                    
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
                        if (fine_mining) begin
                            OUT <= "Trovato!";                               
                        end
                        else begin
                            OUT <= "Niente!";
                            state <= 3'b010;
                            NONCE <= NONCE + 1;
                            nonce_flag <= 1'b1;
                            reset_fsm <= 1'b0;                           
                        end                        
                    end 
        endcase
    end
    
endmodule
