------------------------------------------------------------------------------
--                                                                          --
--                    Copyright (C) 2015, AdaCore                           --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of STMicroelectronics nor the names of its       --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

--  This file provides declarations for devices on the STM32F469 Discovery kits
--  manufactured by ST Microelectronics.

with Ada.Interrupts.Names;  use Ada.Interrupts;

with STM32.Device;  use STM32.Device;

with STM32.DMA;     use STM32.DMA;
with STM32.FMC;     use STM32.FMC;
with STM32.GPIO;    use STM32.GPIO;
with STM32.I2C;     use STM32.I2C;
with STM32.SAI;     use STM32.SAI;

use STM32;  -- for base addresses

with Audio;
with Framebuffer_OTM8009A;
with Touch_Panel_FT6x06;
with SDCard;

package STM32.Board is

   pragma Elaborate_Body;

   subtype User_LED is GPIO_Point;

   Green     : User_LED renames PG6;
   Orange    : User_LED renames PD4;
   Red       : User_LED renames PD5;
   Blue      : User_LED renames PK3;

   LCH_LED   : User_LED renames Red;

   All_LEDs  : GPIO_Points := Green & Orange & Red & Blue;

   procedure Initialize_LEDs;
   --  MUST be called prior to any use of the LEDs

   procedure Turn_On (This : in out User_LED)
     renames STM32.GPIO.Clear;
   procedure Turn_Off (This : in out User_LED)
     renames STM32.GPIO.Set;

   procedure All_LEDs_Off with Inline;
   procedure All_LEDs_On  with Inline;
   procedure Toggle_LEDs (These : in out GPIO_Points)
     renames STM32.GPIO.Toggle;

   -----------
   -- SDRAM --
   -----------

   FMC_D : constant GPIO_Points :=
             (PD0, PD1, PD8, PD9, PD10, PD14, PD15,
              PE7, PE8, PE9, PE10, PE11, PE12, PE13, PE14, PE15,
              PH8, PH9, PH10, PH11, PH12, PH13, PH14, PH15,
              PI0, PI1, PI2, PI3, PI6, PI7, PI9, PI10);

   FMC_A : constant GPIO_Points :=
              (PF0, PF1, PF2, PF3, PF4, PF5,
               PF12, PF13, PF14, PF15, PG0, PG1, PG4, PG5);

   FMC_SDNWE  : GPIO_Point renames PC0;
   FMC_SDNRAS : GPIO_Point renames PF11;
   FMC_SDNCAS : GPIO_Point renames PG15;
   FMC_SDNE0  : GPIO_Point renames PH3;
   FMC_SDCKE0 : GPIO_Point renames PH2;
   FMC_SDCLK  : GPIO_Point renames PG8;

   FMC_NBL0   : GPIO_Point renames PE0;
   FMC_NBL1   : GPIO_Point renames PE1;
   FMC_NBL2   : GPIO_Point renames PI4;
   FMC_NBL3   : GPIO_Point renames PI5;

   SDRAM_PINS    : constant GPIO_Points :=
                     FMC_A & FMC_D &
                     FMC_SDNWE & FMC_SDNRAS & FMC_SDNCAS & FMC_SDCLK &
                     FMC_SDNE0 & FMC_SDCKE0 & FMC_NBL0 & FMC_NBL1 &
                     FMC_NBL2 & FMC_NBL3;

   --  SDRAM CONFIGURATION Parameters

   SDRAM_Base            : constant := 16#C0000000#;
   SDRAM_Size            : constant := 16#800000#;
   SDRAM_Bank            : constant STM32.FMC.FMC_SDRAM_Cmd_Target_Bank :=
                             STM32.FMC.FMC_Bank1_SDRAM;
   SDRAM_Mem_Width       : constant STM32.FMC.FMC_SDRAM_Memory_Bus_Width :=
                             STM32.FMC.FMC_SDMemory_Width_32b;
   SDRAM_Row_Bits        : constant STM32.FMC.FMC_SDRAM_Row_Address_Bits :=
                             FMC_RowBits_Number_11b;
   SDRAM_CAS_Latency     : constant STM32.FMC.FMC_SDRAM_CAS_Latency :=
                             STM32.FMC.FMC_CAS_Latency_3;
   SDRAM_CLOCK_Period    : constant STM32.FMC.FMC_SDRAM_Clock_Configuration :=
                             STM32.FMC.FMC_SDClock_Period_2;
   SDRAM_Read_Burst      : constant STM32.FMC.FMC_SDRAM_Burst_Read :=
                             STM32.FMC.FMC_Read_Burst_Single;
   SDRAM_Read_Pipe       : constant STM32.FMC.FMC_SDRAM_Read_Pipe_Delay :=
                             STM32.FMC.FMC_ReadPipe_Delay_0;
   SDRAM_Refresh_Cnt     : constant := 16#0569#;
   SDRAM_Min_Delay_In_ns : constant := 70;

   ---------
   -- I2C --
   ---------

   I2C1_SCL : GPIO_Point renames PB8;
   I2C1_SDA : GPIO_Point renames PB9;
   I2C2_SCL : GPIO_Point renames PH4;
   I2C2_SDA : GPIO_Point renames PH5;

   procedure Initialize_I2C_GPIO (Port : in out I2C_Port)
     with
   --  I2C_3 is not accessible on this board
     Pre => As_Port_Id (Port) = I2C_Id_1
            or else
            As_Port_Id (Port) = I2C_Id_2;

   procedure Configure_I2C (Port : in out I2C_Port);

   --------------------------------
   -- Screen/Touch panel devices --
   --------------------------------

   LCD_Natural_Width  : constant := Framebuffer_OTM8009A.LCD_Natural_Width;
   LCD_Natural_Height : constant := Framebuffer_OTM8009A.LCD_Natural_Height;
   Display            : Framebuffer_OTM8009A.Frame_Buffer;
   Touch_Panel        : Touch_Panel_FT6x06.Touch_Panel;

   -----------------
   -- Touch Panel --
   -----------------

   TP_INT   : GPIO_Point renames PJ5;

   -----------
   -- Audio --
   -----------

   Audio_SAI       : SAI_Controller renames SAI_1;
   Audio_I2C       : STM32.I2C.I2C_Port renames I2C_2;
--     Audio_INT     : GPIO_Point renames PB10;

   --  Audio DMA configuration
   Audio_DMA               : DMA_Controller renames DMA_2;
   Audio_Out_DMA_Interrupt : Ada.Interrupts.Interrupt_ID renames
                               Ada.Interrupts.Names.DMA2_Stream1_Interrupt;
   Audio_DMA_Out_Stream    : DMA_Stream_Selector renames Stream_1;
   Audio_DMA_Out_Channel   : DMA_Channel_Selector renames Channel_0;

   Audio_Device : aliased Audio.CS43L22_Audio_Device (Audio_I2C'Access);

   -----------------
   -- User button --
   -----------------

   User_Button_Point     : GPIO_Point renames PA0;
   User_Button_Interrupt : constant Interrupt_ID := Names.EXTI0_Interrupt;

   procedure Configure_User_Button_GPIO;
   --  Configures the GPIO port/pin for the blue user button. Sufficient
   --  for polling the button, and necessary for having the button generate
   --  interrupts.

   ------------
   -- SDCARD --
   ------------

   SDCard_Device : aliased SDCard.SDCard_Controller (SDIO'Access);

end STM32.Board;
