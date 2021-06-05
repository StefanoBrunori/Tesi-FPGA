`timescale 1ns / 1ps

module Mining_test;
    
    //Lunghezza del messaggio
    parameter LENGHT = 1024;
    
    reg clock = 0; 
    reg reset = 0;
    reg stopw = 0;
    reg [511:0] message;
    reg [15:0] indirizzo = 0;
    reg [8:0] width = 9'd63; //range: 511-0
    reg [15:0] indirizzo_nonce = 0;
    
    wire fine;       
    wire [2:0] state;       
    wire [511:0] chunk;                           
    wire [63:0] OUT;
    wire [255:0] HASH;
             
    reg [1023:0] messaggio;
    
    integer i = 0;
    integer k = LENGHT-1;
    initial begin
        for (i=0;i<LENGHT;i=i+1) begin
            messaggio[i] <= {$random}%2;
        end
    end
    
    always@(posedge clock) begin
        if (state == 3'h1) begin          
           if (~stopw) begin                                         
               message = messaggio[k-:512];
               if (indirizzo < LENGHT/512-1) indirizzo = indirizzo + 1;                                     
               k = k - 512;               
           end
           if (k <= 0) begin
               stopw = 1;  
           end
        end       
        
    end 
    
    Mining_FSM fsm1(
        .clock(clock),
        .reset(reset),      
        .stopw(stopw),       
        .fine(fine),
        .HASH(HASH),
                               
        .state(state),
        .OUT(OUT)       
        );
    
    Preprocessing p1(
        .clock(clock),
        .reset(reset),      
        .indirizzo(indirizzo),
        .state(state),
        .message(message),
        .width(width),
        .indirizzo_nonce(indirizzo_nonce),
        .stopw(stopw),
        
        .fine(fine),
        .chunk(chunk)                     
        );
    
    Chunks c1(
        .clock(clock),
        .reset(reset),    
        .state(state),
        .chunk(chunk),
                                          
        .HASH(HASH)
        );
    
    always #5 clock = ~clock;  
    
endmodule
