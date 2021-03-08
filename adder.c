#include "xil_io.h"
#include "xparameters.h"
#include "myip_adder.h"

int main(){

	u32 out;

	xil_printf("\nProva Addizionatore\n");

	MYIP_ADDER_mWriteReg(0x43C00000, 0, 0x00000302);
	out = MYIP_ADDER_mReadReg(0x43C00000, 12);

	xil_printf("\nRisultato: %d\n", out);
}
