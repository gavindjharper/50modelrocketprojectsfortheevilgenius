' =========================================================================
'
'   Project 2
'   MagneticApogeeDetection.bas
'   {$STAMP BS2p}
'   {$PBASIC 2.5}
'
' =========================================================================
'
' -----[ Program Description ]---------------------------------------------
'
' This program reads magnetic field strength from the ADC, and searches for
' a minimum point in field strength. It then fires the deployment charge.
' 8 readings are taken and totalled, and compared to the total of the
' previous 8 readings to prevent premature deployment due to noise.
' -------------------------------------------------------------------------


' -----[ Pin assignments ]-------------------------------------------------

PYRO      PIN       0         ' Pyro charge
G_SWITCH  PIN       1         ' Acceleration switch

ADC_SCLK  PIN       0         ' ADC serial clock pin
ADC_CS    PIN       1         ' ADC chip select pin
ADC_DATA  PIN       2         ' ADC serial data pin


' -----[ Variable definitions ]--------------------------------------------

adc_value VAR       Word      ' Value read from ADC

total     VAR       Word      ' Current total of ADC readings
prev_total  VAR     Word      ' Previous total of ADC values

i         VAR       Byte      ' Loop counter


' -----[ Initialisation ]--------------------------------------------------

LOW PYRO                      ' Ensures that pyro is turned off
INPUT G_SWITCH                ' Sets g-switch pin to input
HIGH ADC_CS                   ' Switches off ADC

total = 0                     ' Ensures that total < prev_total for first
prev_total = 65535            ' cycle through do...loop


' -----[ Main program ]----------------------------------------------------

Wait_for_liftoff:
  IF G_SWITCH=0 THEN wait_for_liftoff    ' Waiting for lift off to be detected

Flight:

  total = 0

  FOR i=1 TO 8
    GOSUB Read_ADC
    total =  total + adc_value
  NEXT

  IF total > prev_total THEN Apogee_detected

  prev_total = total

GOTO Flight

Apogee_detected:
  HIGH PYRO                   ' Fire deployment charge

END


' -----[ Subroutines ]-----------------------------------------------------

Read_ADC:
  LOW ADC_CS
  SHIFTIN ADC_DATA,ADC_SCLK,MSBPOST,[adc_value\12]
  HIGH ADC_CS
RETURN
