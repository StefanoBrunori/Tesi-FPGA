`timescale 1ns / 1ps

module Mining_test;
    
    //Lunghezza del messaggio
    parameter LENGHT = 1000;
    
    reg clock = 0; 
    reg reset = 0;
    reg start = 1;
    
    reg [6:0] indirizzo = 0;
    wire fine;    
    reg stopw = 0;
    wire [2:0] state;
    reg [31:0] message;
    reg [63:0] mess_lenght = LENGHT; 
    wire [511:0] chunk;
    
    wire fine_mining;
    wire [31:0] NONCE;
    wire reset_fsm;       
    
    wire [63:0] OUT;
    
    reg [31:0] h0 = 32'h6a09e667;
    reg [31:0] h1 = 32'hbb67ae85;
    reg [31:0] h2 = 32'h3c6ef372;
    reg [31:0] h3 = 32'ha54ff53a;
    reg [31:0] h4 = 32'h510e527f;
    reg [31:0] h5 = 32'h9b05688c;
    reg [31:0] h6 = 32'h1f83d9ab;
    reg [31:0] h7 = 32'h5be0cd19;
       
    reg [29999:0] messaggio;
    
    integer i;
    initial begin
        for (i=0;i<LENGHT;i=i+1) begin
            messaggio[i] = {$random}%2;
        end
    end  
    
    integer j = LENGHT;
    integer k = 0;
    always@(posedge clock) begin
        if (state == 3'b001) begin
            if (j<31) begin
                message = messaggio[(LENGHT%32)-1:0];
                start <= 0;
                stopw <= 1;          
            end
            else begin
                message = messaggio[(j-1)-:32];                   
                j = j - 32;
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
        .fine_mining(fine_mining),
                               
        .state(state),
        .OUT(OUT),
        .reset_fsm(reset_fsm),
        .NONCE(NONCE)
        );
    
    Preprocessing p1(
        .clock(clock),
        .reset(reset),
        .reset_fsm(reset_fsm),
        .indirizzo(indirizzo),
        .state(state),
        .message(message),
        .mess_lenght(mess_lenght),
        .NONCE(NONCE),
        
        .chunk(chunk),
        .fine(fine)        
        );
    
    Chunks c1(
        .clock(clock),
        .reset(reset),
        .reset_fsm(reset_fsm),
        .state(state),
        .chunk(chunk),
                                          
        .fine_mining(fine_mining)
        );
    
    always #5 clock = ~clock;  
    
endmodule
