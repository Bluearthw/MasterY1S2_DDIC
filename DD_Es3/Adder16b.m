%% initiate the simulation

%clear all
inputfile = 'Adder16b_BrentKungStandard';

clear transientsim
clear acsim
close all

if (exist('supply', 'var') == 0)
    supply = 1;
end

globals.supply = supply;

tic;
runSpice;
toc

%To plot the voltage signal of node named S:
%plotsig(transientsim,'v_s')
%Ff several signals s[1], s[2], s[3] in the same plot:
plotsig(transientsim,'v_s1;v_s2;v_s3')

%% calculate the characteristics

vdd = globals.supply;

%- delay calculation -
%---------------------
inputBitWidth = 16;
time        = evalsig(transientsim, 'TIME');
a0          = evalsig(transientsim, 'v_a_buff0');

a0Crossing  = findPositiveZeroCrossings(time,a0-vdd/2);
for i = 0:inputBitWidth
    signal = evalsig(transientsim, [ 'v_s',num2str(i)]);
    sCrossP{i+1} = findPositiveZeroCrossings(time, signal-vdd/2);
    sCrossN{i+1} = findNegativeZeroCrossings(time, signal-vdd/2);
    sum{i+1} = signal;
end

delays = zeros(1,inputBitWidth+1);
for i = 0:inputBitWidth
    delays(i+1) = (sCrossP{i+1}(1) - a0Crossing(i+1));
end

[delay,cpp1] = max(delays);

critical_path_index = cpp1-1;

%- Power calculations -
%----------------------
I_vdd   = evalsig(transientsim, 'i_vdd');
n = 35; % amount of patterns simulated
Charge = zeros(n,1);
%for i = 1:n
for i = [1,2,3:2:n]
    if i == 1
        begintime = 0;
        endtime = 4e-9*i-0.2e-9;
    else
        begintime = 4e-9*(i-1)-0.2e-9;
        endtime = 4e-9*i-0.2e-9;
    end
    if begintime == 0
        beginindex = 1;
    else
        beginindex = getElementNumber(time,begintime);
    end
    endindex = getElementNumber(time,endtime);
    Charge(i) = trapz(time(beginindex:endindex),I_vdd(beginindex:endindex));
end

Energy = -Charge*vdd;
SwitchingEnergyCP = Energy(critical_path_index*2+1); % energy of the switching event
[SwitchingEnergyWC,ep] = max(Energy);
DCpower = Energy(2)/4e-9; % power = energy/time


%- Output generation -
%---------------------
if( exist('displayOn','var') == 0)
    displayOn = 1;
end

if(displayOn)
    disp(' ');
    disp(['Worst Case delay (on node s',num2str(critical_path_index),')            = ' num2str(delay*1e12),' ps'])
%    disp(['Switching energy of critical path         = ', num2str(SwitchingEnergyCP*1e15),' fJ'])
    %disp(' ')
    disp(['Worst Case Switching energy (on node s',num2str((ep-1)/2-1),') = ',num2str(SwitchingEnergyWC*1e15),' fJ'])
    %disp(' ')
    disp(['DC power consumption                      = ',num2str(DCpower*1e9),' nW'])
    
    type(['spicefiles/',inputfile, '.err0'])
end
