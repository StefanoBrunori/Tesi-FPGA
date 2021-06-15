`timescale 1ns / 1ps

module Testbench;
    
    parameter LENGHT = 1024;
    
    reg clock = 0;
    reg resetn = 1;
    reg stopw = 0;
      
    wire flag;       
    wire [511:0] chunk;
    wire [255:0] HASH;
    wire cs_n;
    wire wr_n;
    wire rd_n;
    wire [15:0] addr;
    wire [8:0] addr_width;
    wire [511:0] bram_data_out;
    wire [31:0] bram_data_in;
    wire [31:0] preproc_out;
    wire [1:0] counter;
    
    reg [31:0] message;
    reg [15:0] indirizzo = 0;
    reg [8:0] nonce_width = 9'd63;
    reg [15:0] indirizzo_nonce = 16'h0;
    reg [8:0] indirizzo_width = 9'd511;
    wire [2:0] state;
    wire OUT;
    
    reg [LENGHT-1:0] messaggio;
    
    integer i, j = 0;
    integer k = LENGHT-1;
    initial begin
        for (i=0;i<LENGHT;i=i+1) messaggio[i] = {$random}%2;
    end             
    
    always@(posedge clock) begin
       if (state == 3'h1) begin
           if (~stopw) begin                                                       
               message = messaggio[k-:32];
               #1 j = j + 1;
               #1 k = k - 32;
               #1 indirizzo_width = indirizzo_width - 32;
               //Dopo 16 iterazioni ho riempito un blocco da 512-bit
               if (j == 16) indirizzo = indirizzo + 1;
               if (j > 16) begin
                   k = k + 32; 
                   //indirizzo = indirizzo + 1;
                   indirizzo_width = 9'd511;
                   j = 0;
               end
               if (k < 0) stopw = 1'b1;
                                          
           end            
       end 
    end
                        
    Mining_FSM fsm1(
        .clock(clock),
        .reset(resetn),      
        .stopw(stopw),              
        .flag(flag),
        .HASH(HASH),
        .indirizzo(indirizzo),
        .indirizzo_nonce(indirizzo_nonce),
        .indirizzo_width(indirizzo_width),
        .nonce_width(nonce_width),
        .message(message),
        .preproc_out(preproc_out),
        
        .counter(counter), 
        .bram_data_in(bram_data_in), 
        .cs_n(cs_n),
        .wr_n(wr_n), 
        .rd_n(rd_n),
        .addr(addr),
        .addr_width(addr_width),                       
        .state(state),
        .OUT(OUT)       
        );
    
    Memoria m1(
        .clock(clock), 
        .addr(addr),
        .addr_width(addr_width),         
        .cs_n(cs_n),
        .wr_n(wr_n), 
        .rd_n(rd_n),    
        .bram_data_in(bram_data_in),
        
        .bram_data_out(bram_data_out)
        );
    
    Preprocessing p1(
        .clock(clock),
        .reset(resetn),            
        .state(state),
        .nonce_width(nonce_width),         
        .memoria_in(bram_data_out),
        .counter(counter),            
        
        .preproc_out(preproc_out),       
        .flag(flag),
        .chunk(chunk)                           
        );
    
    Chunks c1(
        .clock(clock),
        .reset(resetn),    
        .state(state),
        .chunk(chunk),
                                          
        .HASH(HASH)
        );
        
    always #5 clock = ~clock;
   
endmodule
