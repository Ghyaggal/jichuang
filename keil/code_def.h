#ifndef __code_def_H__
#define __code_def_H__

#include <stdint.h>


//INTERRUPT DEF
#define NVIC_CTRL_ADDR (*(volatile unsigned *)0xe000e100)
#define NVIC_CLRP_ADDR (*(volatile unsigned *)0xe000e280)

//SysTick DEF
typedef struct{
    volatile uint32_t CTRL;
    volatile uint32_t LOAD;
    volatile uint32_t VALUE;
    volatile uint32_t CALIB;
}SysTickType;

#define SysTick_BASE 0xe000e010
#define SysTick ((SysTickType *)SysTick_BASE)

//LED DEF
typedef struct{
    volatile uint32_t WaterLight_LED;
		volatile uint32_t Signal_LED;
}LEDType;

#define LED_BASE 0x40000000
#define LED ((LEDType *)LED_BASE)

//Matrix_Key DEF
typedef struct{
    volatile uint32_t ROW;
    volatile uint32_t COL;
}MKEYType;

#define MKEY_BASE 0x40020000
#define MKEY ((MKEYType *)MKEY_BASE)

//TIME DEF
typedef struct{
    volatile uint32_t LOAD;
    volatile uint32_t ENABLE;
    volatile uint32_t VALUE;
}TIMERType;

#define TIMER_BASE 0x40040000
#define TIMER ((TIMERType *)TIMER_BASE)

//SEG DEF
typedef struct{
    volatile uint32_t DATA;
}SEGType;

#define SEG_BASE 0x40030000
#define SEG ((SEGType *)SEG_BASE)

//SD DEF
typedef struct{
    volatile uint32_t ADDR_DATA;
		volatile uint32_t stop;
		volatile uint32_t remake;
		volatile uint32_t retro;
		volatile uint32_t frame_cnt;
}SDType;

#define SD_BASE 0x40040000
#define SD ((SDType *)SD_BASE)


//UART DEF
typedef struct{
    volatile uint32_t UARTRX_DATA;
    volatile uint32_t UARTTX_STATE;
    volatile uint32_t UARTTX_DATA;
}UART1Type;

#define UART1_BASE 0x40050000
#define UART1 ((UART1Type *)UART1_BASE)



//PINTO DEF
typedef struct{
    volatile uint32_t PINTO_en;
}PINTOType;

#define PINTO_BASE 0x40060000
#define PINTO ((PINTOType *)PINTO_BASE)


//Bayer2RGB DEF
typedef struct{
    volatile uint32_t Bayer2RGB_en;
}Bayer2RGBType;

#define Bayer2RGB_BASE 0x40070000
#define Bayer2RGB ((Bayer2RGBType *)Bayer2RGB_BASE)

//MedFilter DEF
typedef struct{
    volatile uint32_t MedFilter_en;
}MedFilterType;

#define MedFilter_BASE 0x40080000
#define MedFilter ((MedFilterType *)MedFilter_BASE)

//Gamma DEF
typedef struct{
    volatile uint32_t Gamma_en;
}GammaType;

#define Gamma_BASE 0x40080000
#define Gamma ((GammaType *)Gamma_BASE)


void delay_us(uint32_t us);
void delay_ms(uint32_t ms);
void Key_Scan(void);
void smg_display(void);

  
uint32_t ReadUART1State(void);
uint32_t ReadUART1(void);
void WriteUART1(char data);
void UART1String(char *stri);
void UART1Handle(void);
void TIME_Init(void);
void TIMEHandle(void);
void KEY0Handle(void);
void KEY1Handle(void);
void KEY2Handle(void);	
void KEY3Handle(void);	
void KEY4Handle(void);	
void KEY5Handle(void);	
void KEY6Handle(void);	
void KEY7Handle(void);

#endif


