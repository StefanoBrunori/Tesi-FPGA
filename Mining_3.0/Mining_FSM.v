`timescale 1ns / 1ps

module Mining_FSM(
    input clock,
    input reset,   
    input stopw,              
    input wire [255:0] HASH,    
    input [15:0] indirizzo,
    input [15:0] indirizzo_nonce,
    input [8:0] indirizzo_width,
    input [8:0] nonce_width,
    input [31:0] message,
    input [511:0] bram_data_out,
    
    output reg flag,    
    output reg [511:0] chunk,
    output reg [31:0] bram_data_in,
    output reg cs_n,
    output reg wr_n, 
    output reg rd_n,
    output reg [15:0] addr,
    output reg [8:0] addr_width,
    output reg [2:0] state,
    output reg [31:0] NONCE_OUT    
    );
    
    reg [15:0] index;
    reg fine;     
    reg [31:0] nonce_attuale; 
    reg [5:0] indice; 
         
    always@(posedge clock) begin
        if (^state === 1'bx) state <= 3'h0;
        if (^wr_n === 1'bx) wr_n = 1'b0;
        if (^rd_n === 1'bx) rd_n = 1'b1;
        if (^cs_n === 1'bx) cs_n = 1'b0;
        if (^index === 1'bx) index = 1'b0;
        if (^fine === 1'bx) fine = 1'b0;       
        if (^bram_data_in === 1'bx) bram_data_in = 32'h0;
        if (^addr === 1'bx) addr = 16'h0;
        if (^addr_width === 1'bx) addr_width = 9'h0;   
        if (^flag === 1'bx) flag = 1'b0;                 
        
        //reset
        if (~reset) begin
            state <= 3'h0;           
        end              
        else begin               
        
        case (state)                    
                                
            3'h0: begin
                    if (stopw) begin
                        if (~flag) begin                                            
                            wr_n = 1'b1;
                            rd_n = 1'b0;                           
                            addr = indirizzo_nonce;
                            addr_width = nonce_width;
                            flag = 1;
                        end
                        else begin
                            state <= 3'h1;
                            flag = 0;
                        end                                             
                    end
                    else begin  
                        addr = indirizzo;
                        addr_width = indirizzo_width;
                        bram_data_in = message;                     
                        cs_n = 1'b0;
                        wr_n = 1'b0;                  
                    end
                     
                  end 
                                                         
            3'h1: begin
                    if (~flag) begin
                        addr = indirizzo_nonce;
                        addr_width = nonce_width;
                        bram_data_in = bram_data_out[nonce_width-:32] + 1;                                              
                        flag = 1; 
                        rd_n = 1'b1;
                        wr_n = 1'b0;                                            
                    end
                    else begin                                               
                        state <= 3'h2;
                        flag = 0;
                        rd_n = 1'b1;                       
                        addr = index;                                              
                    end        
                  end
                                                                 
            3'h2: begin 
                    addr = index;                                     
                    chunk = bram_data_out;                                                                                                                  
                    index = index + 1;
                    state <= 3'h3;
                    
                    if (index == indirizzo) begin                                                                                            
                        fine = 1'b1;
                        index = 16'h0;
                    end
                    rd_n = 1'b1;
                    wr_n = 1'b1;
                  end
            
            3'h3: begin                   
                    if (~flag) begin
                        indice = 6'd16;
                        flag = 1;
                    end                    
                    else begin
                        if (indice == 6'h0) begin
                            state <= 3'h4;
                            flag = 1'b0;                          
                        end
                        else begin
                            indice = indice + 1;                           
                        end                                                    
                    end
                  end
                     
            3'h4: begin
                    if (flag) begin
                        if (indice == 6'h0) begin                  
                            addr = index;
                            rd_n = 1'b0;
                            if (fine) begin
                                state <= 3'h5;
                                fine = 1'b0;
                                flag = 1'b0;
                            end
                            else state <= 3'h2;
                        end
                        else indice = indice + 1;
                     end
                     else begin
                        flag = 1'b1;
                        indice = indice + 1;
                     end           
                  end
                  
            3'h5: state <= 3'h6;
                  
            3'h6: begin
                if (HASH[255-:10] == 10'h0) begin                                      
                    addr = indirizzo_nonce; 
                    rd_n = 1'b0;                                              
                    NONCE_OUT = bram_data_out[nonce_width-:32];                                             
                end
                else begin
                    state <= 3'h1;                                     
                    rd_n = 1'b0; 
                end
            end
            
        endcase
        end
    end
    
endmodule
