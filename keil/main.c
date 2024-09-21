#include <stdint.h>
#include <stdio.h>
#include "code_def.h"



int main(void)
{
	NVIC_CTRL_ADDR = 0x3FF;	//3ff
	
	TIME_Init();
	while (1) {
		Key_Scan();
		smg_display();
	}
}



