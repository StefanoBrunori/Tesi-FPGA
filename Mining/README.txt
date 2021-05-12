I tre file principali che formano la struttura sono FSM.v, Adder.v e Memoria.v, mentre Testbench.v è il file di simulazione per emulare il file .C che verrà scritto alla fine.
Per prima cosa viene generato un messaggio di 4096 bit nel Testbench; a quel punto viene salvato in memoria a blocchi di 8 bit facendo partire la FSM, la quale ha quattro stati:

  - stato 00 := La macchina non esegue operazioni, è lo stato iniziale.
  - stato 01 := In questo stato la macchina salva in memoria il messaggio mantenendo il segnale di we (write enable) a 1.
  - stato 10 := In quasto stato la macchina mette we a 0, re (read enable) a 1 e fa iniziare le operazioni dell'adder, il quale ad ogni posedge del clock eseguirà la somma degli
                8 bit presi in input in quel fronte di clock.
  - stato 11 := In questo stato la macchina mette re a 0 e manda in output la somma totale eseguita su tutto il messaggio, ritornando così il numero di bit pari a 1 nel messaggio 
                iniziale. 

NOTA: Quando il programma viene eseguito sulla FPGA ritorna un valore "out" errato: per aggiustarlo è necessario sottrarre a quest'ultimo n=out/512 arrotondato per difetto.
