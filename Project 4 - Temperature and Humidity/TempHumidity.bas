' =========================================================================
'
'   Project 4
'   TempHumidity.bas
'   {$STAMP BS2p}
'   {$PBASIC 2.5}
'
' =========================================================================
'
' -----[ Program Description ]---------------------------------------------
'
' This program reads temperature and humidity data from the SHT11 sensor,
' and stores it in external EEPROM until the EEPROM is full.
' -------------------------------------------------------------------------

' -----[ Pin assignments ]-------------------------------------------------

G_SWITCH  PIN       1         ' Acceleration switch

TH_DATA   PIN       2         ' Sensor data pin
TH_CLOCK  PIN       3         ' Sensor clock pin

EEPROM    PIN       0         ' EEPROM data pin is 0; EEPROM clock pin is 1


' -----[ Constant definitions ]--------------------------------------------

TEMP      CON       %00011    ' Control codes to read temperature and
HUMID     CON       %00101    ' humidity from SHT11 sensor
STATUS_WRITE  CON   %00110    ' Control codes to read and write SHT11
STATUS_READ   CON   %00111    ' status register

EEPROM_WRITE  CON   %10100000 ' Control code to perform write operation to
                              ' I2C EEPROM
EEPROM_SIZE   CON   32768     ' Size in bytes of EEPROM


' -----[ Variable definitions ]--------------------------------------------

sensor_data   VAR    Byte     ' Data read from sensor
ctrl_byte     VAR    Byte     ' Control byte sent to sensor
ack_bit       VAR    Bit
time_out      VAR    Bit

address       VAR    Word     ' Address in EEPROM to write data
eeprom_data   VAR    Byte     ' Data byte to be written to EEPROM

temperature   VAR    Word
humidity      VAR    Word

i             VAR    Byte     ' Loop counter


' -----[ Initialisation ]--------------------------------------------------

INPUT G_SWITCH                ' Sets g-switch pin to input

SHIFTOUT TH_DATA, TH_CLOCK, LSBFIRST, [$FFF\9]
GOSUB TH_Start_Sequence       ' Resets connection to temp/humidity sensor

address = 0


' -----[ Main program ]----------------------------------------------------

Wait_for_liftoff:
  IF G_SWITCH=0 THEN wait_for_liftoff    ' Waiting for lift off to be detected

DO

  GOSUB Read_Temp

  eeprom_data = temperature.HIGHBYTE
  GOSUB Write_EEPROM
  eeprom_data = temperature.LOWBYTE
  GOSUB Write_EEPROM

  address = address + 1

  GOSUB Read_Humidity

  eeprom_data = humidity.HIGHBYTE
  GOSUB Write_EEPROM
  eeprom_data = humidity.LOWBYTE
  GOSUB Write_EEPROM

  address = address + 1

LOOP WHILE address < EEPROM_SIZE

END


' -----[ Subroutines ]-----------------------------------------------------

Read_Temp:
  GOSUB TH_Start_Sequence

  ctrl_byte = TEMP
  GOSUB Send_Ctrl_Byte
  GOSUB Wait_For_Ack

  ack_bit = 0

  GOSUB Read_Data
  temperature.HIGHBYTE = sensor_data
  ack_bit = 1

  GOSUB Read_Data
  temperature.LOWBYTE = sensor_data
RETURN


Read_Humidity:
  GOSUB TH_Start_Sequence

  ctrl_byte = HUMID
  GOSUB Send_Ctrl_Byte
  GOSUB Wait_For_Ack

  ack_bit = 0

  GOSUB Read_Data
  humidity.HIGHBYTE = sensor_data
  ack_bit = 1

  GOSUB Read_Data
  humidity.LOWBYTE = sensor_data
RETURN


TH_Start_Sequence:
  INPUT TH_DATA
  LOW TH_CLOCK
  HIGH TH_CLOCK
  LOW TH_DATA
  LOW TH_CLOCK
  HIGH TH_CLOCK
  INPUT TH_DATA
  LOW TH_CLOCK
RETURN


Read_Data:
  SHIFTIN  TH_DATA, TH_CLOCK, MSBPRE, [sensor_data]     ' get byte
  SHIFTOUT TH_DATA, TH_CLOCK, LSBFIRST, [ack_bit\1] ' send ack bit
  INPUT TH_DATA                                 ' release data line
RETURN


Wait_For_Ack:
  INPUT TH_DATA                                 ' data line is input
  FOR i = 1 TO 250                        ' give ~1/4 second to finish
    time_out = INS.LOWBIT(TH_DATA)               ' scan data line
    IF (time_out = 0) THEN EXIT        ' if low, we're done
    PAUSE 1
  NEXT
RETURN


Send_Ctrl_Byte:
  SHIFTOUT TH_DATA, TH_CLOCK, MSBFIRST, [ctrl_byte]   ' send byte
  SHIFTIN  TH_DATA, TH_CLOCK, LSBPRE, [ack_bit\1]   ' get ack bit
RETURN


Write_EEPROM:
  I2COUT EEPROM, EEPROM_WRITE, address.HIGHBYTE\address.LOWBYTE, [eeprom_data]
RETURN
