clc
clear all
close all

data = importdata('CKSoln.ckcsv',',',1);

data.textdata(1,:) = [];

file = fopen('inputMoleFracPulse40.csv','w');
fprintf(file, 'mole fraction (or mole)\n');
for i = 1:length(data.textdata)
    name = data.textdata(i,1);
    if (length(name{1})>14 && strcmp(name{1}(1:14),'Mole_fraction_'))
        fprintf(file, '%s, %5.4e \n', name{1}(15:end), data.data(i,end));
    end
end
fclose(file);