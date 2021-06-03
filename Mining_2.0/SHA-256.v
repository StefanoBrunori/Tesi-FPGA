 `timescale 1ns / 1ps

module Preprocessing(
    input clock,
    input reset,
    input reset_fsm,
    input [6:0] indirizzo,
    input [2:0] state,   
    input wire [31:0] message,
    input wire [63:0] mess_lenght,
    input wire [31:0] NONCE,
    input wire nonce_flag,
    
      
    output reg [511:0] chunk,
    output reg fine    
    );
    
    parameter WIDTH = 512;
    parameter DEPTH = 2000;
    
    //Mi costruisco una memoria 2000 blocchi da 512 bit ciascuno
    reg [WIDTH-1:0] memoria [0:DEPTH-1];  
    
    //Diachiarazione registri e variabili d'appoggio   
    integer i, j, k, resto, ind;
    reg [15:0] new_lenght;
    integer indirizzo_width;
    reg [11:0] index;
    
        
    always@(posedge clock) begin
        
        //Reset
        if (reset || reset_fsm) begin
            new_lenght <= 16'h0;
            indirizzo_width <= 1'b1;
            index <= 12'h0;
            fine <= 1'b0;
            chunk <= 512'h0;
        end
        
        //Inizializzazione del segnale di controllo           
        if (^fine === 1'bx) fine <= 1'b0;        
                   
        case (state)
                   
            3'b000: begin              
                //----------------------STATO 000-----------------------------//
                //--------------------Stato iniziale--------------------------//
                end                              
            
            
            3'b001: begin               
                //----------------------STATO 001-----------------------------//
                //-----------------SCRITTURA IN MEMORIA-----------------------//
                
                //Scrivo il messaggio in memoria       
                memoria[indirizzo] = message;
                              
            end
        
            3'b010: begin                      
                //----------------------STATO 010-----------------------------//        
                //--------IMBOTTITURA E SALVATAGGIO NONCE IN MEMORIA----------//
                
                for (i=0;i<512;i=i+1) begin
                    if (^memoria[indirizzo][i] === 1'bx) begin
                        memoria[indirizzo][i] <= 1'b0;
                    end 
                end
                
                //Salvataggio nel nonce in memoria (concatenato al messaggio originale)
                //Se lo spazio nell'ultimo blocco di memoria è minore di 32 bit... 
                //...allora il nonce sarà salvato in due blocchi differenti                                              
                if (512-(mess_lenght%512)<32) begin
                   for (i=0;i<512-(mess_lenght%512);i=i+1) begin
                       if (nonce_flag) begin
                           memoria[indirizzo][512-(mess_lenght%512)+i] <= NONCE[31-i]; 
                       end
                       else begin
                           memoria[indirizzo] <= {memoria[indirizzo], NONCE[31-i]};
                       end 
                   end
                   for (i=512-(mess_lenght%512);i<32;i=i+1) begin
                       memoria[indirizzo+1] <= NONCE[31-i];  
                   end 
                end
                //Altrimenti verrà salvato nel blocco corrente
                if (512-(mess_lenght%512)>=32) begin
                    if (nonce_flag) begin
                        memoria[indirizzo][0+:32] <= NONCE;  
                    end
                    else begin
                        memoria[indirizzo] <= {memoria[indirizzo], NONCE};
                    end
                end                                                                               
                new_lenght = mess_lenght + 32;
                
                
                //Calcolo l'indirizzo esatto in cui salvare il bit "1"
                indirizzo_width = new_lenght%WIDTH;
                
                //Lunghezza del messaggio dopo aver aggiunto il bit "1"
                new_lenght = new_lenght + 1;
                
                //Appendo al messaggio il bit "1" e lo "imbottisco" con gli zeri (caso 1) 
                if (indirizzo_width == 0) begin
                    memoria[indirizzo+1] = {1'b1, 447'h0};
                    new_lenght = new_lenght + 447;                    
                end
                               
                //Appendo al messaggio il bit "1" e lo "imbottisco" con gli zeri (caso 2) 
                else begin                                    
                    memoria[indirizzo] = {memoria[indirizzo], 1'b1};
                    if (new_lenght%512 > 448) begin
                        for (i=0;i<new_lenght%512;i=i+1) begin
                            memoria[indirizzo] = {memoria[indirizzo], 1'b0}; 
                        end
                        memoria[indirizzo+1] = 448'h0;
                        new_lenght = new_lenght + new_lenght%512 + 448;
                        ind = indirizzo + 1;
                    end
                    else begin //(if new_lenght%512 < 448)
                        for (i=0;i<448-new_lenght%512;i=i+1) begin
                            memoria[indirizzo] = {memoria[indirizzo], 1'b0};     
                        end
                        new_lenght = new_lenght + (448-new_lenght%512);
                        ind = indirizzo; 
                    end
                end                                                         
                                                                          
                                                                   
                //Appendo la lunghezza del messaggio originale al messaggio "imbottito"
                //come intero da 64-bit big-endian               
                memoria[ind] = {memoria[ind], mess_lenght+32};          
                new_lenght = new_lenght+64;              
                index = 0;
            end
            
            3'b011: begin               
                //----------------------------------STATO 011------------------------------------------//
                //------DIVIDO IL MESSAGGIO IN BLOCCHI DA 512-bit E LI PASSO ALLA FUNZIONE "Chunks"----//
                
                //Sposto il messaggio nel modulo Chunks a blocchi di 512-bit                                                                                         
                if (~fine) begin
                    chunk <= memoria[index];
                    //$display();
                    index = index + 1;
                end
                if (index > ind) begin
                    fine = 1;                                    
                end
            end
            
            
            //Stati in cui la funzione non esegue operazioni
            3'b100: begin
            end
            
            3'b101: begin
            end
            
            3'b110: begin
            end
            
            3'b111: fine <= 1'b0;           
                   
        endcase
        
    end    

endmodule

//----------------------------------------------------------------------------   

module Chunks(
    input clock,
    input reset,
    input reset_fsm,
    input [2:0] state,
    input [511:0] chunk,
               
    output reg fine_mining 
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
    
    reg [255:0] HASH;    
      
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
        if (reset || reset_fsm) begin
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
        if (^fine_mining === 1'bx) fine_mining <= 1'b0;
        
        case (state)
            
            3'b000: begin               
                //------------------------STATO 000------------------------//
                //------Stato in cui la funzione non esegue operazioni-----//                                            
            end
            
            //Stati in cui la funzione non esegue operazioni
            3'b001: begin
                //------------------------STATO 001------------------------//
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
            
            //Stati in cui la funzione non esegue operazioni        
            3'b010: begin
            end
                 
            3'b011: begin
            end
            
            3'b100: begin              
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
            
            3'b101: begin                                      
                //------------------------STATO 101------------------------//
                //---------------------Ciclo principale--------------------// 
                                                                                                                   
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
            end
            
            3'b110: begin                            
                //------------------------STATO 110------------------------//
                //-------------------Aggiornamento valori------------------//    
                       
                h0 = h0 + a;
                h1 = h1 + b;
                h2 = h2 + c;
                h3 = h3 + d;
                h4 = h4 + e;
                h5 = h5 + f;
                h6 = h6 + g;
                h7 = h7 + h;
            end
            
            3'b111: begin              
                //------------------------STATO 111------------------------//
                //-------------------Produco l'hash finale-----------------//
                
                HASH = {h0, h1, h2, h3, h4, h5, h6, h7};
                if (HASH[255:246] == 10'b0000000000) begin                  
                    fine_mining <= 1'b1;   
                end                                            
                $monitor("\nHash finale: %h\n", HASH);
            end
            
        endcase
    end

endmodule
