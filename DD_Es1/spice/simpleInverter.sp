*--------------------------------------
*---  INVERTER: simple example
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
*Transient simulation with final time = 5ns
.tran 0.001n 5n 
.probe v i


* Voltage sources
*-----------------
.param supply = 1
Vdd vdd vss supply 
Vss vss 0 0 

* Input signal
*-----------------
.param period = 2n
Vin in  vss pulse 0 supply 0.99p 20p 20p 1n 2n *Input signal to the circuit. Pulse signal named "in" with period 2ns.

* DC input to measure Leakage
*Vin in  vss insert_value_here


*******************************************************************
**** CIRCUIT TO SIMULATE
*******************************************************************
*In this circuit we use a MYNOT gate, which input is the pulse signal "in" and the output is signal "out".
Xnot1 in out2 vdd vss MYNOT 
Xnot2 out2 out vdd vss MYNOT2 
*Cload out vss 10f


**********************************
**** SUBCIRCUITS USED IN THE CIRCUIT
**********************************
* We design an inverter gate named MYNOT
.SUBCKT MYNOT input output vdd vss multfac='1'
*nmos: Xname source gate drain bulk MOSN width length
xM1 output input vss vss MOSN w='multfac*120e-9' l='45e-9'
*pmos: Xname source gate drain bulk MOSP width length
*xM2 output input vdd vdd MOSP w='multfac*4*120e-9' l='45e-9'
xM2 output input vdd vdd MOSP w='multfac*2*120e-9' l='45e-9'
.ENDS MYNOT

.SUBCKT MYNOT2 input output vdd vss multfac='16'
*nmos: Xname source gate drain bulk MOSN width length
xM1 output input vss vss MOSN w='multfac*120e-9' l='45e-9'
*pmos: Xname source gate drain bulk MOSP width length
*xM2 output input vdd vdd MOSP w='multfac*4*120e-9' l='45e-9'
xM2 output input vdd vdd MOSP w='multfac*2*120e-9' l='45e-9'
.ENDS MYNOT2

*******************************************************************
**** MEASUREMENTS
*******************************************************************
.PARAM edge = 2
.MEASURE TRAN delayNot1_FR TRIG v(in) VAL='0.5*supply' FALL='edge' 
+ 			   TARG v(out) VAL='0.5*supply' FALL='edge'
*TARG v(out) VAL='0.5*supply' RISE='edge' 


.MEASURE TRAN delayNot1_RF TRIG v(in) VAL='0.5*supply' RISE='edge' 
+ 			   TARG v(out) VAL='0.5*supply' RISE='edge' 

.MEASURE TRAN iavg avg i(vdd) from=0.5n to=2.5n *average current in one clock cycle
.MEASURE energyNot1 param='-supply*iavg*2n' *energy in a clock cycle


.END

