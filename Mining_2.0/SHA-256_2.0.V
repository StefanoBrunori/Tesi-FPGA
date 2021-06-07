`timescale 1ns / 1ps

module Preprocessing(
    input clock,
    input reset,    
    input [15:0] indirizzo,
    input [2:0] state,   
    input wire [511:0] message,
    input [8:0] width,
    input [15:0] indirizzo_nonce,
    input stopw, 
    
    output reg fine,
    output reg flag,           
    output reg [511:0] chunk        
    );
    
    parameter WIDTH = 512;
    parameter DEPTH = 2000;
    
    //Mi costruisco una memoria 100 blocchi da 512 bit ciascuno
    reg [WIDTH-1:0] memoria [0:DEPTH-1];  
    
    //Diachiarazione registri e variabili d'appoggio         
    reg [15:0] index;
    reg [31:0] nonce_attuale;
    wire [15:0] ind;
    assign ind = (state == 3'h1)?indirizzo:0;
    assign ind = (state == 3'h2)?indirizzo_nonce:0;
    assign ind = (state == 3'h3)?index:0;
        
    always@(posedge clock) begin
        
        //Reset
        if (reset) begin           
            index = 12'h0;          
            chunk = 512'h0;
            fine = 1'b0;
        end                                      
        
        if (^fine === 1'bx) fine = 1'b0;
        if (^flag === 1'bx) flag = 1'b0;
        if (^chunk === 1'bx) chunk = 512'h0;
                   
        case (state)
                   
            3'h0: begin              
                //----------------------STATO 000-----------------------------//
                //--------------------Stato iniziale--------------------------//
                end                              
            
            
            3'h1: begin               
                //----------------------STATO 001-----------------------------//
                //-----------------SCRITTURA IN MEMORIA-----------------------//
                
                //Scrivo il messaggio in memoria                 
                memoria[ind] = message;               
                //$display("\nmessaggio[%d]: %h", ind, message);
                                              
            end                      
            
            3'h2: begin               
                //--------------------STATO 010--------------------------------//
                //---------INIZIO L'AGGIORNAMENTO DEL NONCE--------------------//              
                if (~flag) begin
                    index = 0;               
                    nonce_attuale = memoria[ind][width-:32];
                    flag = 1;
                end
                else begin
                    memoria[ind][width-:32] = nonce_attuale + 1;  
                    flag = 0;
                    fine = 0;                                                                      
                end
            end
                         
            3'h3: begin               
                //----------------------------------STATO 011------------------------------------------//
                //------DIVIDO IL MESSAGGIO IN BLOCCHI DA 512-bit E LI PASSO ALLA FUNZIONE "Chunks"----//
                                           
                //Sposto il messaggio nel modulo Chunks a blocchi di 512-bit                                                               
                chunk = memoria[ind];
                $display("\nindex, ind: %d, %d", index, ind);                                 
                if (index == indirizzo) fine = 1;
                                 
                index = index + 1;              
            end                                            
            
            3'h4: begin
            end
            
            3'h5: begin
            end
            
            3'h6: begin
            end
            
            3'h7: begin
            end
                   
        endcase
        
    end    

endmodule

//----------------------------------------------------------------------------   

module Chunks(
    input clock,
    input reset,   
    input [2:0] state,
    input [511:0] chunk,
                   
    output reg [255:0] HASH 
    );
    
    
    integer i, j;
    integer w[0:63];
    reg [31:0] word;
    
    reg [31:0] s0;
    reg [31:0] s1;
    
    reg [31:0] a;
    reg [31:0] b;
    reg [31:0] c;
    reg [31:0] d;
    reg [31:0] e;
    reg [31:0] f;
    reg [31:0] g;
    reg [31:0] h;
    
    reg [31:0] maj;
    reg [31:0] t2;
    reg [31:0] ch;
    reg [31:0] t1;
    
    reg [31:0] h0;
    reg [31:0] h1;
    reg [31:0] h2;
    reg [31:0] h3;
    reg [31:0] h4;
    reg [31:0] h5;
    reg [31:0] h6;
    reg [31:0] h7;
          
      
    parameter k = {
    32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5, 
    32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
    32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
    32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
    32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
    32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
    32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
    32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
    };
    
    always@(posedge clock) begin
        //reset
        if (reset) begin
            s0 <= 32'h0;
            s1 <= 32'h0;
        
            a <= 32'h0;
            b <= 32'h0;
            c <= 32'h0;
            d <= 32'h0;
            e <= 32'h0;
            f <= 32'h0;
            g <= 32'h0;
            h <= 32'h0;
        
            maj <= 32'h0;
            t2 <= 32'h0;
            ch <= 32'h0;
            t1 <= 32'h0;
            
            HASH <= 256'h0;    
        end
        
        if (^HASH === 1'bx) HASH = 256'h0;        
        
        case (state)
            
            3'h0: begin               
                //------------------------STATO 000------------------------//
                //------Stato in cui la funzione non esegue operazioni-----//                                            
            end
                       
            3'h1: begin
                //------------------------STATO 001------------------------//
                //------Stato in cui la funzione non esegue operazioni-----//                                                        
            end
                               
            3'h2: begin
                //------------------------STATO 010------------------------//
                //--------------Inizializzazione valori iniziali-----------//
                
                h0 <= 32'h6a09e667;
                h1 <= 32'hbb67ae85;
                h2 <= 32'h3c6ef372;
                h3 <= 32'ha54ff53a;
                h4 <= 32'h510e527f;
                h5 <= 32'h9b05688c;
                h6 <= 32'h1f83d9ab;
                h7 <= 32'h5be0cd19;
                
            end
                 
            3'h3: begin
                //------------------------STATO 011------------------------//
                //------Stato in cui la funzione non esegue operazioni-----//
            end
            
            3'h4: begin              
                //------------------------STATO 100------------------------//
                //----------------Preparazione delle 16 parole-------------//
                
                //Divido il chunk in sedici parole da 32-bit con notazione big-endian (quindi: little_endian=[110100] => big_endian=[001011])
                
                for (i=16; i>0; i=i-1) begin
                    w[16-i] = chunk[((i*32)-1) -: 32];                                                                                         
                end
                
                //Estendo le sedici parole da 32-bit in sessantaquattro parole da 32-bit            
                for (i=16; i<=63; i=i+1) begin           
                    s0 = {w[i-15][6:0], w[i-15][31:7]} ^ {w[i-15][17:0], w[i-15][31:18]} ^ w[i-15] >> 3;                  
                    s1 = {w[i-2][16:0], w[i-2][31:17]} ^ {w[i-2][18:0], w[i-2][31:19]} ^ w[i-2] >> 10;
                    w[i] = w[i-16] + s0 + w[i-7] + s1;                  
                end
                                                           
                //Inizializzo le costanti e i valori hash per questo blocco  
                a = h0;   
                b = h1;  
                c = h2;
                d = h3;
                e = h4;
                f = h5;
                g = h6;
                h = h7;  
                                                        
            end
            
            4'h5: begin                                      
                //------------------------STATO 101------------------------//
                //---------------------Ciclo principale--------------------//
                //--------------------Aggiorno i valori--------------------// 
                                                                                                                   
                for (i=0; i<=63; i=i+1) begin                                                                   
                    s0 = {a[1:0], a[31:2]} ^ {a[12:0], a[31:13]} ^ {a[21:0], a[31:22]};        
                    maj = (a & b) ^ (a & c) ^ (b & c);
                    t2 = s0 + maj;
                    s1 = {e[5:0], e[31:6]} ^ {e[10:0], e[31:11]} ^ {e[24:0], e[31:25]};
                    ch = (e & f) ^ (~e & g);
                    t1 = h + s1 + ch + k[i] + w[i] ;
                    
                    
                    h = g;
                    g = f;
                    f = e;
                    e = d + t1;
                    d = c;
                    c = b;
                    b = a;
                    a = t1 + t2;
                end
                
                h0 = h0 + a;
                h1 = h1 + b;
                h2 = h2 + c;
                h3 = h3 + d;
                h4 = h4 + e;
                h5 = h5 + f;
                h6 = h6 + g;
                h7 = h7 + h;
            end
            
            4'h6: begin                            
                //------------------------STATO 110------------------------//
                //-------------------Produco l'hash finale-----------------//    
                
                HASH <= {h0, h1, h2, h3, h4, h5, h6, h7};                                                         
                //$monitor("\nHash finale: %h\n", HASH);       
                                               
            end
            
            4'h7: begin              
                //------------------------STATO 111------------------------//
                //----------------------Stato finale-----------------------//               
            end
            
        endcase
    end
    
   
endmodule
