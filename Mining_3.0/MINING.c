#include "xil_io.h"
#include "xparameters.h"
#include "mining_ip.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>


int main(){

	u32 IP_ADDR = 0x43C00000;
	u32 slv0 = 0;
	u32 slv1 = 4;
	u32 slv2 = 8;
	u32 OUT_state = 12;

	char Messaggio[] = "Prova Bitcoin Miner!";
	u32 mess_lenght = (strlen(Messaggio)*8);

	u32 indirizzo_nonce = floor(mess_lenght/512);
	u32 nonce_width = 511-mess_lenght%512;

	/*NOTA:
	 	 2^16 = 65.536
	 	 2^32 = 4.294.967.296
	 	 2^35 = 34.359.738.368
	 	 2^25 = 33.554.432
	 	 2^31 = 2.147.483.648
	*/

	u32 slv_reg2 = indirizzo_nonce + nonce_width*65536;

	u32 slv_reg1 = 511*65536;

	u32 stopw = 33554432;

	//Scrivo l'indirizzo (profondità) del nonce sul registro slv2[15:0]
	//Scrivo l'indirizzo (ampiezza) del nonce sul registro slv2[24:16]
	//Scrivo il segnale "stopw" sul registro slv2[25]
	MINING_IP_mWriteReg(IP_ADDR, slv2, slv_reg2);

	//Scrivo l'indirizzo (profondità) del messaggio sul registro slv1[15:0]
	//Scrivo l'indirizzo (ampiezza) del messaggio sul registro slv1[24:16]
	MINING_IP_mWriteReg(IP_ADDR, slv1, slv_reg1);

	u32 state;

	while(1){
		state = MINING_IP_mReadReg(IP_ADDR, OUT_state)/4294967296;
		if (state == 1) {
			u32 indirizzo = slv_reg1;
			u32 ind = 0;
			char mess[4];

			//Scrivo il messaggio in memoria
			for (int i=0;i<mess_lenght/4;i++) {
				u32 indice = i*4;
				memcpy(mess, Messaggio + indice, 4);
				if (i == 120){
					indirizzo = indirizzo + 1;
					ind = ind + 1;
					MINING_IP_mWriteReg(IP_ADDR, slv1, indirizzo);
				}
				MINING_IP_mWriteReg(IP_ADDR, slv1, ((511-32*i)*65536 + ind));
				MINING_IP_mWriteReg(IP_ADDR, slv0, mess);
			}

			//salvo il nonce in memoria
			MINING_IP_mWriteReg(IP_ADDR, slv1, slv_reg2);
			MINING_IP_mWriteReg(IP_ADDR, slv0, 0);

			//Salvo l'imbottitura in memoria
			u32 imbottitura = (512-((mess_lenght+32)%512))/32;
			u32 uno = 0;
			for (int i=0;i<imbottitura;i++){
				if (uno == 0) {
					MINING_IP_mWriteReg(IP_ADDR, slv1, 2147483648);
					uno = 1;
				}
				else {
					MINING_IP_mWriteReg(IP_ADDR, slv1, 0);
				}
			}

			//Notifico alla macchina che ho finito di passare dati alla PL
			MINING_IP_mWriteReg(IP_ADDR, slv2, stopw);
		}

		//Controllo periodicamente lo stato della macchina

		//Controllo periodicamente se è stato trovato il nonce giusto
		u32 out = floor(MINING_IP_mReadReg(IP_ADDR, OUT_state)/34359738368);
		if (out == 1) {
			u32 nonce = MINING_IP_mReadReg(IP_ADDR, OUT_state);
			xil_printf("Nonce trovato: %h", nonce);
			break;
		}
	}

}
