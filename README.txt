# Tesi-FPGA

I file caricati rappresentano un progetto per un addizionatore sequenziale che ad ogni fronte positivo di clock effettua la somma di due interi da 8 bit A e B e salva il risultato in un registro S da 9 bit. I file caricati sono i seguenti:
  - ADDER.v := file in verilog dove viene descritto l'addizionatore;
  - myip_adder.v := file in verilog generato automaticamente durante la creazione della nuova IP "myip_adder" e modificato affinchè possa istanziare il modulo ADDER descritto del     file "ADDER.v". Nello specifico ho creato un nuovo registro wire da 9 bit "adder_out" a cui assegnerò il valore di S, per poi mandare il risultato in output. Per fare ciò, ho     sostituito lo slave register 3 con adder_out, in modo che quando chiederò al programma di stampare a schermo il contenuto dello slv_reg3 invece mi stamperà il contenuto di         adder_out. La somma sarà effettuata tra i bit [7:0] e [15:0] dello slv_reg0.
  - adder.c := file in C scritto con Vitis dove carico i valori che devo sommare nello slv_reg0 e faccio stampare a schermo la soluzione. 
