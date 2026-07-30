' =========================================================================
'
'   Project 1
'   DelayTimer.bas
'   {$STAMP BS2p}
'   {$PBASIC 2.5}
'
' =========================================================================
'
' -----[ Program Description ]---------------------------------------------
'
' This program waits for lift off, waits for a set number of seconds, and
' then fires the pyro charge. TO alter the delay (default is 5 seconds)
' change the value of the constant DELAY ON line 26.
' -------------------------------------------------------------------------


' -----[ Pin assignments ]-------------------------------------------------

PYRO      PIN       0         ' Pyro charge
G_SWITCH  PIN       1         ' Acceleration switch


' -----[ Constant definitions ]--------------------------------------------

DELAY     CON       5         ' delay in seconds


' -----[ Initialisation ]--------------------------------------------------

LOW PYRO                      ' Ensures that pyro is turned off
INPUT G_SWITCH                ' Sets g-switch pin to input


' -----[ Main program ]----------------------------------------------------

wait_for_liftoff:
  IF G_SWITCH=0 THEN wait_for_liftoff    ' Waiting for lift off to be detected

PAUSE DELAY * 1000            ' Because PAUSE uses milliseconds

HIGH PYRO                     ' Fire pyro charge

END
