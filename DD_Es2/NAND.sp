*--------------------------------------
*---  Standard NAND GATE DESIGN
*--------------------------------------


*******************************************************************
**** SIMULATION SETUP
*******************************************************************
* Simulation options 
*--------------------
.options post nomod
.option opts fast parhier=local post_version=9601
.options captab

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
.vec './vecFiles/NAND.vec'


*******************************************************************
**** CIRCUIT TO SIMULATE
*******************************************************************
Xnand A B out vdd vss MYNAND
Xnot1 out out_bar vdd vss MYNOT 


**********************************
**** SUBCIRCUITS USED IN THE CIRCUIT
**********************************
* M[name] [d] [g] [s] [b] [model node] [model parameters (length L, width W)]
*-------------
.SUBCKT MYNAND A B output vdd vss multfac='1'

xM3 output A xM4d vss MOSN w='multfac*2*120e-9' l='45e-9'
xM4 xM4d B vss vss MOSN w='multfac*2*120e-9' l='45e-9'

xM1 output A vdd vdd MOSP w='multfac*2*120e-9' l='45e-9'
xM2 output B vdd vdd MOSP w='multfac*2*120e-9' l='45e-9'
.ENDS MYNAND


.SUBCKT MYNOT input output vdd vss multfac='16'
xM1 output input vss vss MOSN w='multfac*120e-9' l='45e-9'
xM2 output input vdd vdd MOSP w='multfac*2*120e-9' l='45e-9'
.ENDS MYNOT



*******************************************************************
**** MEASUREMENTS
*******************************************************************
.PARAM edge = 2
.MEAS TRAN Rise_Delay_A trig V(A) val='supply/2' rise=1
+ targ V(out) VAL='0.5*supply' fall=1

.MEAS TRAN Fall_Delay_A trig V(A) VAL='0.5*supply' fall=1
+ targ V(out) VAL='0.5*supply' rise=1


.MEAS TRAN Rise_Delay_B trig V(B) VAL='0.5*supply' rise=1
+ targ V(out) VAL='0.5*supply' fall=2

.MEAS TRAN Fall_Delay_B trig V(B) VAL='0.5*supply' fall=2
+ targ V(out) VAL='0.5*supply' rise=2

