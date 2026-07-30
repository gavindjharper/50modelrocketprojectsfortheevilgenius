' =========================================================================
'
'   DataDownload1.bas
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

EEPROM    PIN       0         ' EEPROM data pin is 0; EEPROM clock pin is 1


' -----[ Constant definitions ]--------------------------------------------

EEPROM_READ   CON   %10100001 ' Control code to perform read operation to
                              ' I2C EEPROM
EEPROM_SIZE   CON   32768     ' Size in bytes of EEPROM


' -----[ Variable definitions ]--------------------------------------------

address       VAR   Word      ' Address in EEPROM to write data
eeprom_data   VAR   Word      ' Data byte to be written to EEPROM


' -----[ Initialisation ]--------------------------------------------------

address = 0


' -----[ Main program ]----------------------------------------------------

DO

  I2CIN EEPROM, EEPROM_READ, address.HIGHBYTE\address.LOWBYTE, [eeprom_data.HIGHBYTE]
  address = address + 1

  I2CIN EEPROM, EEPROM_READ, address.HIGHBYTE\address.LOWBYTE, [eeprom_data.LOWBYTE]
  address = address + 1

  DEBUG DEC eeprom_data, CR

LOOP WHILE address < EEPROM_SIZE

END