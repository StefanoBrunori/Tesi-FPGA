`timescale 1ns / 1ps

module Mining_test;
    
    parameter LENGHT = 1;
    
    reg clock = 0; 
    reg reset = 0;
    reg start = 1;
    
    reg [6:0] indirizzo = 0;
    wire fine;    
    reg stopw = 0;
    wire [2:0] state;
    reg [31:0] message;
    reg [14:0] mess_lenght = LENGHT; 
    wire [511:0] chunk;
    
    wire [255:0] HASH;
    
    reg [31:0] h0 = 32'h6a09e667;
    reg [31:0] h1 = 32'hbb67ae85;
    reg [31:0] h2 = 32'h3c6ef372;
    reg [31:0] h3 = 32'ha54ff53a;
    reg [31:0] h4 = 32'h510e527f;
    reg [31:0] h5 = 32'h9b05688c;
    reg [31:0] h6 = 32'h1f83d9ab;
    reg [31:0] h7 = 32'h5be0cd19;
    
    //La prova l'ho eseguita con input:= "0"
    reg [29999:0] messaggio = 1'b0;
    
    integer j = 0;
    integer k = 0;
    always@(posedge clock) begin
        if (state == 3'b001) begin
            if (j>LENGHT/32) begin
                start <= 0;
                stopw <= 1;          
            end
            else begin
                message = messaggio[(j*32)+:32];                    
                j = j + 1;
                k = k + 32;
                if (k%512 == 0) begin
                   indirizzo = indirizzo + 1; 
                end              
            end
        end    
    end
    
    Mining_FSM fsm1(
        .clock(clock),
        .reset(reset),
        .start(start),
        .stopw(stopw),       
        .fine(fine),                       
        .state(state)
        );
    
    Preprocessing p1(
        .clock(clock),
        .reset(reset),
        .indirizzo(indirizzo),
        .state(state),
        .message(message),
        .mess_lenght(mess_lenght),
        .chunk(chunk),
        .fine(fine)        
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
