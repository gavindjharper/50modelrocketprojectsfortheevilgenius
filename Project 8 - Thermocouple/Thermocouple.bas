' =========================================================================
'
'   Project 8
'   Thermocouple.bas
'   {$STAMP BS2p}
'   {$PBASIC 2.5}
'
' =========================================================================
'
' -----[ Program Description ]---------------------------------------------
'
' This program reads Seebeck voltage and cold junction temperature from the
' DS2760 One-Wire thermocouple interface. This data is stored for later
' processing in external EEPROM.
' -------------------------------------------------------------------------

' -----[ Pin assignments ]-------------------------------------------------

G_SWITCH  PIN       1         ' Acceleration switch

TC        PIN       2         ' One -Wire interface to thermocouple

EEPROM    PIN       0         ' EEPROM data pin is 0; EEPROM clock pin is 1


' -----[ Constant definitions ]--------------------------------------------

SkipNetAddr   CON   $CC       ' Control code to skip One-Wire net address
ReadReg       CON   $69       ' Control code to read register

EEPROM_WRITE  CON   %10100000 ' Control code to perform write operation to
                              ' I2C EEPROM
EEPROM_SIZE   CON   32768     ' Size in bytes of EEPROM


' -----[ Variable definitions ]--------------------------------------------

SeebeckV      VAR   Word      ' Seebeck voltage read from thermocouple
sign          VAR   Bit       ' Sign of Seebeck voltage
CJ_temp       VAR   Word      ' Cold junction temperature

address       VAR   Word      ' Address in EEPROM to write data
eeprom_data   VAR   Byte      ' Data byte to be written to EEPROM


' -----[ Initialisation ]--------------------------------------------------

INPUT G_SWITCH                ' Sets g-switch pin to input

address = 0


' -----[ Main program ]----------------------------------------------------

wait_for_liftoff:
  IF G_SWITCH=0 THEN wait_for_liftoff    ' waiting for lift off to be detected

DO
  GOSUB Read_TC_Voltage
  eeprom_data = SeebeckV.HIGHBYTE
  GOSUB Write_EEPROM
  eeprom_data = SeebeckV.LOWBYTE
  GOSUB Write_EEPROM

  GOSUB Read_CJ_Temp
  eeprom_data = CJ_temp.HIGHBYTE
  GOSUB Write_EEPROM
  eeprom_data = CJ_temp.LOWBYTE
  GOSUB Write_EEPROM

LOOP WHILE address < EEPROM_SIZE

END


' -----[ Subroutines ]-----------------------------------------------------

Read_TC_Voltage:
  OWOUT TC, %0001, [SkipNetAddr, ReadReg, $0E]
  OWIN  TC, %0010, [SeebeckV.HIGHBYTE, SeebeckV.LOWBYTE]

  sign = SeebeckV.BIT15                  ' save sign bit
  SeebeckV = SeebeckV >> 3               ' correct alignment

  IF sign THEN
    SeebeckV = SeebeckV | $F000          ' pad 2's-compliment bits
  ENDIF

  SeebeckV = ABS SeebeckV */ 4000        ' x 15.625 uV
RETURN


Read_CJ_Temp:
  OWOUT TC, %0001, [SkipNetAddr, ReadReg, $18]
  OWIN  TC, %0010, [CJ_temp.BYTE1, CJ_temp.BYTE0]

  IF (CJ_temp.BIT15) THEN                ' check sign
    CJ_temp = 0                          ' disallow negative
  ELSE
    CJ_temp = CJ_temp.HIGHBYTE         ' >> 5 x 0.125 (>> 3)
  ENDIF
RETURN


Write_EEPROM:
  I2COUT EEPROM, EEPROM_WRITE, address.HIGHBYTE\address.LOWBYTE, [eeprom_data]
  address = address + 1
RETURN
