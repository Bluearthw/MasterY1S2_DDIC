% Simulate data over a range of supply voltages

%fill in the clock period in ps
clk_period_ps = 2000;

supplyarray = 0.75:0.05:1;
delayarray = zeros(size(supplyarray));
energyarray = zeros(size(supplyarray));
DCpowerarray = zeros(size(supplyarray));

displayOn = 0;
for j=1:numel(supplyarray)
    supply = supplyarray(j);
    Adder16b;
    delayarray(j) = delay;
    energyarray(j) = SwitchingEnergyWC;
    DCpowerarray(j) = DCpower;
end


vtime = interp1(delayarray, supplyarray, clk_period_ps*10^-12);
etime = interp1(supplyarray, energyarray, vtime);
ptime = interp1(supplyarray, DCpowerarray, vtime);
disp(' ')
disp(' ')
disp(['Your adder has supply voltage of ', num2str(vtime), ' V,'])
disp(['a worst case switching energy of ', num2str(etime*1e15), ' fJ,'])
disp(['a DC power consumption of ', num2str(ptime*1e9), ' nW,'])
disp(['and a total power consumption of ', num2str((ptime+etime/(5e-9))*1e6), ' uW.'])
%disp(['and a total energy consumption of ', num2str((p_5ns*5e-9+e_5ns)*1e15), ' fJ/op'])
