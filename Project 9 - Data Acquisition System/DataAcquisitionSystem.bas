' =========================================================================
'
'   Project 9
'   DataAcquisitionSystem.bas
'   {$STAMP BS2p}
'   {$PBASIC 2.5}
'
' =========================================================================
'
' -----[ Program Description ]---------------------------------------------
'
' This program...
' -------------------------------------------------------------------------


' -----[ Pin assignments ]-------------------------------------------------

G_SWITCH  PIN       1         ' Acceleration switch

ADC_SCLK  PIN       0         ' ADC serial clock pin
ADC_CS    PIN       1         ' ADC chip select pin
ADC_DATAOUT   PIN   2         ' Stamp -> ADC serial data pin
ADC_DATAIN    PIN   3         ' ADC -> Stamp serial data pin

TH_DATA   PIN       2         ' Sensor data pin
TH_CLOCK  PIN       3         ' Sensor clock pin

EEPROM    PIN       0         ' EEPROM data pin is 0; EEPROM clock pin is 1


' -----[ Constant definitions ]--------------------------------------------

' ADC channels
BARO      CON       142       ' Channel 0 : Air pressure sensor
ACCEL     CON       206       ' Channel 1 : Acceleromter
VIB_X     CON                 ' Channel 2 : Vibration X-axis
VIB_Y     CON                 ' Channel 3 : Vibration Y-axis
ROLL      CON                 ' Channel 4 : Gyroscope
MAG_FIELD CON                 ' Channel 5 : Magnetic field sensor

TEMP      CON       %00011    ' Control codes to read temperature and
HUMID     CON       %00101    ' humidity from SHT11 sensor
STATUS_WRITE  CON   %00110    ' Control codes to read and write SHT11
STATUS_READ   CON   %00111    ' status register

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

SHIFTOUT TH_DATA, TH_CLOCK, LSBFIRST, [$FFF\9]
GOSUB TH_Start_Sequence       ' Resets connection to temp/humidity sensor

address = 0


' -----[ Main program ]----------------------------------------------------

Wait_for_liftoff:
  IF G_SWITCH=0 THEN wait_for_liftoff    ' Waiting for lift off to be detected

DO

  channel = BARO
  GOSUB Read_ADC

  eeprom_data = adc_value.HIGHBYTE
  GOSUB Write_EEPROM
  eeprom_data = adc_value.LOWBYTE
  GOSUB Write_EEPROM

  channel = ACCEL
  GOSUB Read_ADC

  eeprom_data = adc_value.HIGHBYTE
  GOSUB Write_EEPROM
  eeprom_data = adc_value.LOWBYTE
  GOSUB Write_EEPROM

  channel = VIB_X
  GOSUB Read_ADC

  eeprom_data = adc_value.HIGHBYTE
  GOSUB Write_EEPROM
  eeprom_data = adc_value.LOWBYTE
  GOSUB Write_EEPROM

  channel = VIB_Y
  GOSUB Read_ADC

  eeprom_data = adc_value.HIGHBYTE
  GOSUB Write_EEPROM
  eeprom_data = adc_value.LOWBYTE
  GOSUB Write_EEPROM

  channel = ROLL
  GOSUB Read_ADC

  eeprom_data = adc_value.HIGHBYTE
  GOSUB Write_EEPROM
  eeprom_data = adc_value.LOWBYTE
  GOSUB Write_EEPROM

  channel = MAG_FIELD
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
