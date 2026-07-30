' =========================================================================
'
'   Project 7
'   RollRate.bas
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

LIGHT_IN  PIN       2         ' Light -> frequency input

EEPROM    PIN       0         ' EEPROM data pin is 0; EEPROM clock pin is 1


' -----[ Constant definitions ]--------------------------------------------

EEPROM_WRITE  CON   %10100000 ' Control code to perform write operation to
                              ' I2C EEPROM
EEPROM_SIZE   CON   32768     ' Size in bytes of EEPROM


' -----[ Variable definitions ]--------------------------------------------

light_level  VAR    Word

address      VAR    Word      ' Address in EEPROM to write data
eeprom_data  VAR    Byte      ' Data byte to be written to EEPROM


' -----[ Initialisation ]--------------------------------------------------

INPUT G_SWITCH                ' Sets g-switch pin to input

address = 0


' -----[ Main program ]----------------------------------------------------

Wait_for_liftoff:
  IF G_SWITCH=0 THEN wait_for_liftoff    ' Waiting for lift off to be detected

DO

  COUNT LIGHT_IN, 10, light_level        ' Count pulses on LIGHT_IN for 10ms
                                         ' and store in light_level
  eeprom_data = light_level.HIGHBYTE
  GOSUB Write_EEPROM

  eeprom_data = light_level.LOWBYTE
  GOSUB Write_EEPROM

LOOP WHILE address < EEPROM_SIZE

END


' -----[ Subroutines ]-----------------------------------------------------

Write_EEPROM:
  I2COUT EEPROM, EEPROM_WRITE, address.HIGHBYTE\address.LOWBYTE, [eeprom_data]
  address = address + 1
RETURN
