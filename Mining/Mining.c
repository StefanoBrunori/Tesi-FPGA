#include "xil_io.h"
#include "xparameters.h"
#include "mining_ip.h"
#include <stdlib.h>


int main(){
  
  //Definisco l'indirizzo base della IP Custom e la lunghezza complessiva del messaggio in bit
	int BASE_ADDR = 0x43C00000;
	int MESS_WIDTH = 4096;
  
	u32 dati;
	u32 indirizzo=0;
  
  //Metto il segnale start a 1 per far partire il programma
	MINING_IP_mWriteReg(BASE_ADDR, 4, 1);
  
  //Genero un messaggio casuale di 4096 bit, passandolo al programma 8 bit alla volta
	for (int i=0; i<MESS_WIDTH/8; i++){
		dati = rand()%256;
		MINING_IP_mWriteReg(BASE_ADDR, 8, indirizzo);
		MINING_IP_mWriteReg(BASE_ADDR, 0, dati);
		indirizzo++;
	}

  //Abbasso il segnale start a 0
	MINING_IP_mWriteReg(BASE_ADDR, 4, 0);

  //Sto in ascolto finchè non esce in output il valore che mi interessa: finchè il registro di output ha valore 0 rimango in attesa
	u32 out;
	while (1){
		out = MINING_IP_mReadReg(BASE_ADDR, 12)-(MINING_IP_mReadReg(BASE_ADDR, 12)/512);
		if (MINING_IP_mReadReg(BASE_ADDR, 12)!=0){
			xil_printf("\nNumero dei bit: %d\n", out);
			break;
		}
	}
}
