' =========================================================================
'
'   Project 8
'   DataDownloadTC.bas
'   {$STAMP BS2p, KTablePos.BPE, JTablePos.BPE}
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

SkipNetAddr   CON   $CC       ' Control code to skip One-Wire net address
ReadReg       CON   $69       ' Control code to read register

EEPROM_READ   CON   %10100001 ' Control code to perform read operation to
                              ' I2C EEPROM
EEPROM_SIZE   CON   32768     ' Size in bytes of EEPROM


' -----[ Variable definitions ]--------------------------------------------

type          VAR   Byte      ' Type of thermocouple - either K or J

address       VAR   Word      ' Address in EEPROM to write data
eeprom_data   VAR   Byte      ' Data byte to be written to EEPROM

SeebeckV      VAR   Word      ' Seebeck voltage read from thermocouple
CJ_temp       VAR   Word      ' Cold junction temperature
CJ_compV      VAR   Word      ' Compensation voltage
Temp          VAR   Word      ' Thermocouple temperature in Celsius
error         VAR   Bit       ' Error bit is set if temperature is too high

_hi_pntr      VAR   Word      ' Table pointers
_lo_pntr      VAR   Word      '
_mid_pntr     VAR   Word      '
test_val      VAR   Word      ' Value to test compensation voltage against

' -----[ Initialisation ]--------------------------------------------------

address = 0
_hi_pntr = 1023

Select_TC_Type:
  DEBUG CLS,
        "Select TC Type", CR,
        CR,
        "K - Chromel/Alumel", CR,
        "J - Iron/Constantan", CR,
        CR,
        ">>> "

  DEBUGIN type
  IF (type <> "K") OR (type <> "J") THEN Select_TC_Type

  DEBUG CLS

  IF (type = "K") THEN
    type = 1
  ELSE
    type = 2
  ENDIF

  STORE type                                    ' point READ to table


' -----[ Main program ]----------------------------------------------------

DO
  GOSUB Read_EEPROM
  SeebeckV.HIGHBYTE = eeprom_data
  GOSUB Read_EEPROM
  SeebeckV.LOWBYTE = eeprom_data

  GOSUB Read_EEPROM
  CJ_temp.HIGHBYTE = eeprom_data
  GOSUB Read_EEPROM
  CJ_temp.LOWBYTE = eeprom_data

  READ (CJ_temp * 2), Word CJ_compV         ' get CJ compensation voltage

  CJ_compV = CJ_compV + SeebeckV

  GOSUB TC_Lookup

  IF (error = 0) THEN
    DEBUG DEC Temp, CR
  ELSE
    DEBUG "Out of range", CR
  ENDIF

LOOP WHILE address < EEPROM_SIZE

END


' -----[ Subroutines ]-----------------------------------------------------

Read_EEPROM:
  I2CIN EEPROM, EEPROM_READ, address.HIGHBYTE\address.LOWBYTE, [eeprom_data]
  address = address + 1
RETURN


TC_Lookup:
  _lo_pntr = 0

  READ (_hi_pntr * 2), Word test_val             ' check max temp

  IF (CJ_compV > test_val) THEN
    error = 1                                   ' out of range

  ELSE
    DO
      _mid_pntr = (_lo_pntr + _hi_pntr) / 2              ' midpoint of search span
      READ (_mid_pntr * 2), Word test_val           ' read value from midpoint

      IF (CJ_compV = test_val) THEN
        EXIT                                    ' found it!
      ELSEIF (CJ_compV < test_val) THEN
        _hi_pntr = _mid_pntr                          ' search lower half
      ELSE
        _lo_pntr = _mid_pntr                          ' search upper half
      ENDIF

      IF ((_hi_pntr - _lo_pntr) < 2) THEN             ' span at minimum
        _mid_pntr = _lo_pntr
        EXIT
      ENDIF
    LOOP
    temp = _mid_pntr
  ENDIF
RETURN

