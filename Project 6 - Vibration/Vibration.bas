' =========================================================================
'
'   Project 6
'   Vibration.bas
'   {$STAMP BS2p}
'   {$PBASIC 2.5}
'
' =========================================================================
'
' -----[ Program Description ]---------------------------------------------
'
' This program reads vibration data from a two-axis accelerometer via an
' ADC, and then stores the data in external EEPROM until the EEPROM is
' full.
' -------------------------------------------------------------------------


' -----[ Pin assignments ]-------------------------------------------------

G_SWITCH  PIN       1         ' Acceleration switch

ADC_SCLK  PIN       0         ' ADC serial clock pin
ADC_CS    PIN       1         ' ADC chip select pin
ADC_DATAOUT   PIN   2         ' Stamp -> ADC serial data pin
ADC_DATAIN    PIN   3         ' ADC -> Stamp serial data pin

EEPROM    PIN       0         ' EEPROM data pin is 0; EEPROM clock pin is 1


' -----[ Constant definitions ]--------------------------------------------

VIBRATION_X   CON   142       ' X-axis on ADC channel 0
VIBRATION_Y   CON   206       ' Y-axis on ADC channel 1

EEPROM_WRITE  CON   %10100000 ' Control code to perform write operation to
                              ' I2C EEPROM
EEPROM_SIZE   CON   32768     ' Size in bytes of EEPROM


' -----[ Variable definitions ]--------------------------------------------

adc_value VAR       Word      ' Value read from ADC
channel   VAR       Byte      ' Analog channel to read from

address   VAR       Word      ' Address in EEPROM to write data
eeprom_data  VAR    Byte      ' Data byte to be written to EEPROM


' -----[ Initialisation ]--------------------------------------------------

INPUT G_SWITCH                ' Sets g-switch pin to input
HIGH ADC_CS                   ' Switches off ADC

address = 0


' -----[ Main program ]----------------------------------------------------

Wait_for_liftoff:
  IF G_SWITCH=0 THEN wait_for_liftoff    ' Waiting for lift off to be detected

DO

  channel = VIBRATION_X
  GOSUB Read_ADC

  eeprom_data = adc_value.HIGHBYTE
  GOSUB Write_EEPROM
  eeprom_data = adc_value.LOWBYTE
  GOSUB Write_EEPROM

  channel = VIBRATION_Y
  GOSUB Read_ADC

  eeprom_data = adc_value.HIGHBYTE
  GOSUB Write_EEPROM
  eeprom_data = adc_value.LOWBYTE
  GOSUB Write_EEPROM

LOOP WHILE address < EEPROM_SIZE

END


' -----[ Subroutines ]-----------------------------------------------------

Read_ADC:
   LOW ADC_CS
   SHIFTOUT ADC_DATAOUT, ADC_SCLK, MSBFIRST, [channel]
   SHIFTIN ADC_DATAIN, ADC_SCLK, MSBPOST, [adc_value\12]
   HIGH ADC_CS
RETURN


Write_EEPROM:
  I2COUT EEPROM, EEPROM_WRITE, address.HIGHBYTE\address.LOWBYTE, [eeprom_data]
  address = address + 1
RETURN
