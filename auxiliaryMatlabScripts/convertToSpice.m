inputfile2 = strcat(inputfile,'.m2s');

inputfilestring = strcat(strcat(pwd,'/m2sfiles/'),inputfile2);

spicefilestring = strcat(pwd,'/spicefiles/');
if ( exist('globals','var') == 0)
    globals.supply=1;
end
mat2spice(inputfilestring,spicefilestring,globals);

system('rm m2s_run.m');

clear inputfile2
clear inputfilestring
clear spicefilestring