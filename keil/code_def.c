#include <string.h>
#include <stdio.h>
#include "code_def.h"

#define DAY_IMG_ADDR	34880
#define NIGHT_IMG_ADDR	1515920 

void delay_us(uint32_t us)
{
	uint32_t temp;
	SysTick->LOAD  = us*25;
	SysTick->VALUE = 0x00;      
	SysTick->CTRL  = 0x05;     
	do
	{
		temp = SysTick->CTRL;
	}while((temp&0x01)&&!(temp&(1<<16)));
	SysTick->CTRL  = 0x00;     
	SysTick->VALUE = 0x00;			
}

void delay_ms(uint32_t ms)					//1 ~ 1398
{
	uint32_t temp;
	SysTick->LOAD  = ms*25000;
	SysTick->VALUE = 0x00;      
	SysTick->CTRL  = 0x05;      
	do
	{
		temp = SysTick->CTRL;
	}while((temp&0x01)&&!(temp&(1<<16)));
	SysTick->CTRL  = 0x00;      
	SysTick->VALUE = 0x00;		
}


void  Key_Scan(void)
{
	MKEY->ROW = 0x00;          
	if(MKEY->COL != 0x0F)
	{
		delay_ms(1);            
	
	  if(MKEY->COL != 0x0F)     
		{		
			MKEY->ROW = 0x07;      
			switch(MKEY->COL)
			{
				case 0x07: if (SD->ADDR_DATA == DAY_IMG_ADDR) {
						SD->ADDR_DATA = NIGHT_IMG_ADDR;
						UART1String("output_img:night_img\r\n");
						LED->Signal_LED = LED->Signal_LED & 0x07;
					} else {
						SD->ADDR_DATA = DAY_IMG_ADDR;
						UART1String("output_img:day_img\r\n");
						LED->Signal_LED = LED->Signal_LED | 0x08;
					}  
					break;
				case 0x0B: if (SD->remake) {
						SD->remake = 0;
						UART1String("Contrl_stop:remake\r\n");
						LED->Signal_LED = LED->Signal_LED & 0x0B;
					} else {
						SD->remake = 1;
						UART1String("Contrl_run:remake\r\n");
						LED->Signal_LED = LED->Signal_LED | 0x04;
					} 
					break;	
				case 0x0D: 
					if (SD->stop) {
						SD->stop = 0;
						UART1String("Contrl_stop:stop\r\n");
						LED->Signal_LED = LED->Signal_LED & 0x0D;
					} else {
						SD->stop = 1;
						UART1String("Contrl_run:stop\r\n");
						LED->Signal_LED = LED->Signal_LED | 0x02;
					}
					break;	
				case 0x0E: 
					if (SD->retro) {
						SD->retro = 0;
						UART1String("Contrl_stop:retro\r\n");
						LED->Signal_LED = LED->Signal_LED & 0x0E;
					} else {
						SD->retro = 1;
						UART1String("Contrl_run:retro\r\n");
						LED->Signal_LED = LED->Signal_LED | 0x01;
					} 
					break;
			}
			
			MKEY->ROW = 0x0B;       
			switch(MKEY->COL)
			{
				case 0x07: 
					if (PINTO->PINTO_en) {
						PINTO->PINTO_en = 0;
						UART1String("PINTO off\r\n");
						LED->WaterLight_LED = LED->WaterLight_LED & 0x7F; 
					} else {
						PINTO->PINTO_en = 1;
						UART1String("PINTO on\r\n");
						LED->WaterLight_LED = LED->WaterLight_LED | 0x80; 
					}
					break;
				case 0x0B: 
					if (Bayer2RGB->Bayer2RGB_en) {
						Bayer2RGB->Bayer2RGB_en = 0;
						UART1String("Bayer2RGB off\r\n");
						LED->WaterLight_LED = LED->WaterLight_LED & 0xBF; 
					} else {
						Bayer2RGB->Bayer2RGB_en = 1;
						UART1String("Bayer2RGB on\r\n");
						LED->WaterLight_LED = LED->WaterLight_LED | 0x40; 
					}
					break;
				case 0x0D: 
						if (MedFilter->MedFilter_en) {
							MedFilter->MedFilter_en = 0;
							UART1String("MedFilter off\r\n");
							LED->WaterLight_LED = LED->WaterLight_LED & 0xDF;
						} else {
							MedFilter->MedFilter_en = 1;
							UART1String("MedFilter on\r\n");
							LED->WaterLight_LED = LED->WaterLight_LED | 0x20;
						}
					break;
				case 0x0E:
						if (Gamma->Gamma_en) {
							Gamma->Gamma_en = 0;
							UART1String("MedFilter off\r\n");
							LED->WaterLight_LED = LED->WaterLight_LED & 0xEF;
						} else {
							Gamma->Gamma_en = 1;
							UART1String("MedFilter on\r\n");
							LED->WaterLight_LED = LED->WaterLight_LED | 0x10;
						}
						break;
			}
			


//			MKEY->ROW = 0x0D;       //1101  Row1
//			switch(MKEY->COL)
//			{
//				case 0x07:  break;
//				case 0x0B:  break;
//				case 0x0D:  break;
//				case 0x0E:  break;
//			}
//			MKEY->ROW = 0x0E;       //1110  Row0
//			
//			switch(MKEY->COL)
//			{
//				case 0x07:  break;
//				case 0x0B:  break;
//				case 0x0D:  break;
//				case 0x0E:  break;
//			}
	
			MKEY->ROW = 0x00;       	
			while(MKEY->COL != 0x0F);
		}
	}
	
}

void smg_display(void) {
	uint32_t num = 0;
	num += (SD->frame_cnt % 10);
	num += ((SD->frame_cnt / 10) % 10) *16;
	num += ((SD->frame_cnt / 100) % 10) *256;
	num += (SD->frame_cnt / 1000) *4096;
	SEG->DATA = num;	
}

uint32_t ReadUART1State(void)
{
    uint32_t state;
		state = UART1->UARTTX_STATE;
    return(state);
}

uint32_t ReadUART1(void)
{
    uint32_t data;
		data = UART1->UARTRX_DATA;
    return(data);
}

void WriteUART1(char data)
{
  while(ReadUART1State());
	UART1 -> UARTTX_DATA = data;
}

void UART1String(char *stri)
{
	uint32_t i;
	for(i=0;i<strlen(stri);i++)
	{
		WriteUART1(stri[i]);
	}
}

void UART1Handle(void)
{
	uint32_t temp;
	
	temp = ReadUART1();
}


void TIME_Init(void)        //T = 1s
{
	TIMER->LOAD   = 25000000;
	TIMER->ENABLE = 0;
}	


void TIMEHandle(void)				
{
	uint32_t stop;
	stop = SD->stop;
	printf("SystemStop=%d\r\n", stop);
}

void KEY0Handle(void)				
{
	if (Gamma->Gamma_en) {
		UART1String("Gamma on\r\n");
	} else {
		UART1String("Gamma off\r\n");
	}
}

void KEY1Handle(void)				
{
	if (MedFilter->MedFilter_en) {
		UART1String("MedFilter on\r\n");
	} else {
		UART1String("MedFilter off\r\n");
	}
}

void KEY2Handle(void)				
{
	if (Bayer2RGB->Bayer2RGB_en) {
			UART1String("Bayer2RGB on\r\n");
		} else {
			UART1String("Bayer2RGB off\r\n");
		}
}

void KEY3Handle(void)				
{
	if (PINTO->PINTO_en) {
			UART1String("PINTO on\r\n");
		} else {
			UART1String("PINTO off\r\n"); 
		}
}

void KEY4Handle(void)				
{
	if (SD->retro) {
		UART1String("Contrl_run:retro\r\n");
	} else {
		UART1String("Contrl_stop:retro\r\n");
	} 
}

void KEY5Handle(void)				
{
	if (SD->stop) {
			UART1String("Contrl_run:stop\r\n");
		} else {
			UART1String("Contrl_stop:stop\r\n");
		}
}

void KEY6Handle(void)				
{
	if (SD->remake) {
		UART1String("Contrl_run:remake\r\n");
	} else {
		UART1String("Contrl_stop:remake\r\n");
	} 
}

void KEY7Handle(void)				
{
		if (SD->ADDR_DATA == DAY_IMG_ADDR) {
			UART1String("output_img:day_img\r\n");
		} else {
			UART1String("output_img:night_img\r\n");
		}  
}
