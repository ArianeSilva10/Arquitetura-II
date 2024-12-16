
#include "hw_types.h"
#include "soc_AM335x.h"

#define WDT_WSPR           0x44E35048 
#define WDT_WWPS           0x44E35034

// Definindo a ativação do clock
#define CM_PER_GPIO1_CLKCTRL        0xAC
#define CM_PER_GPIO1_CLKCTRL_MODULEMODE_ENABLE   (0x2u) 
#define CM_PER_GPIO1_CLKCTRL_OPTFCLKEN_GPIO_1_GDBCLK (0x00040000u)
#define CM_PER_GPIO1_CLKCTRL_M_O      (0x00040002u) 

// Definindo a configuração do mux
#define CM_conf_gpmc_a1         0x844
#define CM_conf_gpmc_a5         0x854

// Definição da direção do pino 
#define GPIO_OE           0x134
#define GPIO_1_CLEARDATAOUT        0x190
#define GPIO_1_SETDATAOUT        0x194
#define GPIO_1_DATAIN         0x138

int button(){
 if(HWREG(SOC_GPIO_1_REGS+GPIO_1_DATAIN) & (1<<17)){
  return 1;
 }
 return 0;
}

int _main(void){
 unsigned char pisca=0;
 unsigned int valor;
 volatile unsigned int i;
 
 HWREG(WDT_WSPR) = 0xAAAA;
 while(HWREG(WDT_WWPS) & (1<<4));
 HWREG(WDT_WSPR) = 0x5555;
 while(HWREG(WDT_WWPS) & (1<<4));
 // Definindo a ativação do clock
 //0x44E000AC |= (1<<18) | (1<<2;)
 HWREG(SOC_PRCM_REGS+CM_PER_GPIO1_CLKCTRL) |= CM_PER_GPIO1_CLKCTRL_M_O;
 
 // Definindo a configuração do mux
 
 HWREG(SOC_CONTROL_REGS+CM_conf_gpmc_a5) |= 7;
 
 // Definição da direção do pino 
 valor = HWREG(SOC_GPIO_1_REGS+GPIO_OE);
 valor &= ~(1<<21);
 HWREG(SOC_GPIO_1_REGS+GPIO_OE) = valor;
 
 HWREG(SOC_CONTROL_REGS+CM_conf_gpmc_a1) |= 7;
 
 // Definição da direção do pino 
 valor = HWREG(SOC_GPIO_1_REGS+GPIO_OE);
 valor &= ~(1<<17);
 HWREG(SOC_GPIO_1_REGS+GPIO_OE) = valor;
 
 
 while(1){
  pisca ^= (0x01u);
  if(button()){
   HWREG(SOC_GPIO_1_REGS+GPIO_1_SETDATAOUT)  = (1<<21);
  }else{
   HWREG(SOC_GPIO_1_REGS+GPIO_1_CLEARDATAOUT) = (1<<21);
  }
  //delay
  for(i = 0; i<1000000;i++);  
 }
 
 return(0);
}