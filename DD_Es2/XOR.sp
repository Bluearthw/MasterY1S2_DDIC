*--------------------------------------
*---  XOR GATE DESIGN
*--------------------------------------


*******************************************************************
**** SIMULATION SETUP
*******************************************************************
* Simulation options 
*--------------------
.options post nomod
.option opts fast parhier=local post_version=9601
*.options captab

* Technology 
*------------
*Add the 45nm CMOS library
.lib './Resources/Technology/tech_wrapper.lib' tt

* Simulation
*----------------------
* Print operating point in listing file
.op
*Transient simulation with STEP=0.001 Start from 0s and Stop at 10n
.tran 0.001n 10n 
.probe v i


* Voltage sources
*-----------------
.param supply = 1
Vdd vdd vss supply
Vss vss 0 0 


* Input signal
*-----------------
*Add the .vec file
.vec './vecFiles/XOR.vec'


* Simulated circuit
*-------------------
Xxor  A B out vdd vss MYXOR
*Xload out out1 vdd vss MYNOT multfac='16'
Xload out out1 vdd vss MYNOT

* Subcircuits
* M[name] [d] [g] [s] [b] [model node] [model parameters (length L, width W)]
*-------------


*-------------Standard-XOR-------------
.SUBCKT MYXOR A B output vdd vss multfac='1'

.ENDS MYXOR



.SUBCKT MYNOT input output vdd vss multfac='1'
xM1 output input vss vss MOSN w='multfac*120e-9' l='45e-9'
xM2 output input vdd vdd MOSP w='multfac*2*120e-9' l='45e-9'
.ENDS MYNOT



*******************************************************************
**** MEASUREMENTS
*******************************************************************



.END
