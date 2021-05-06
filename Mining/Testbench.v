`timescale 1ns / 1ps

module FSM_testbench;
    
    parameter MESS_WIDTH = 4096; 
    
    reg start=1;
    
    //Segnali di clock e reset
    reg clk=0; 
    reg reset=1;
    
    //Segnali di controllo in output della FSM
    wire[1:0] state;    
    
    //Segnali di controllo in input della FSM       
    wire fine_scrittura;
    wire fine_lettura;
    
    
    wire [7:0] out_mem;
    wire we;
    wire re;
    reg [8:0] indirizzo_write = 9'h0;
    wire [8:0] indirizzo_read;
    
    //Registri per l'adder
    reg [MESS_WIDTH-1:0] msg;
    reg [7:0] dati;
    wire [12:0] out;
    wire fine;
    
    
    integer j;
    initial begin
        for(j=0; j<MESS_WIDTH; j=j+1)
            msg[j] <= {$random}%2;          
    end 
    
    integer i=0;  
    always@(posedge clk) begin
        if (i>511) begin                      
        end
        else begin
            dati <= msg[8*i+:8];           
            i=i+1;
            indirizzo_write <= indirizzo_write +1;
        end   
    end
    
    FSM f1(
        .start(start),
        .clk(clk),
        .reset(reset),
        .we(we),
        .re(re),          
        .fine_scrittura(fine_scrittura),
        .fine_lettura(fine_lettura),
        .fine(fine),
        .indirizzo_read(indirizzo_read),              
        .state(state)
        );
    
    Memoria m1(
        .clk(clk),
        .reset(reset),
        .we(we),
        .re(re),
        .indirizzo_write(indirizzo_write),
        .indirizzo_read(indirizzo_read),
        .dati(dati),
        .state(state),        
        .fine_scrittura(fine_scrittura),
        .fine_lettura(fine_lettura),       
        .out_mem(out_mem)
        );
    
    Adder add1(
        .in(out_mem),
         
        .clk(clk), 
        .reset(reset), 
                
        .state(state),                
        
        .fine(fine), 
        .out(out)
        );
    
    always #5 clk = ~clk;          
    always #10 reset <= 0;    // 2 x clk
    always #15 start <= 0;    // 3 x clk
    
endmodule
