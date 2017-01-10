clc
clear all
close all

data(1) = importdata('export1-10.csv');
data(2) = importdata('export11-20.csv');
data(3) = importdata('export21-30.csv');
data(4) = importdata('export31-40.csv');
data(5) = importdata('export41-50.csv');

for i = 1:5
    dat = data(i);
    dat.textdata = dat.textdata.';
    data(i) = dat;
end

maxRun = 3;
maxTime = data(1);
maxTime = maxTime.data(end,1)*maxRun;

fontSize = 32;
lineWidth = 3;
%% Power Deposition
h = figure;
hold on
ind = 5;
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plot(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind),'b', 'LineWidth',lineWidth);
end
h.CurrentAxes.XScale = 'log';
h.CurrentAxes.XLim = [1e-7, maxTime ];
h.CurrentAxes.FontSize = fontSize;
h.CurrentAxes.LineWidth = lineWidth;
xlabel('Time (s)','FontSize',fontSize);
ylabel('Power Deposition (W)','FontSize',fontSize);

%% Temperatures
h = figure;
hold on
ind = 9;
tShift = data(1);
tShift = tShift.data(end,1);
plots = [];
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = plot(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind),'b', 'LineWidth',lineWidth);
end

ind = 12;
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = plot(dat.data(:,1) + (i-1)*tShift, 11600*dat.data(:,ind),'r','LineWidth',lineWidth);
end

h.CurrentAxes.FontSize = fontSize;
h.CurrentAxes.LineWidth = lineWidth;
xlabel('Time (s)','FontSize',fontSize);
ylabel('Temperature (K)','FontSize',fontSize);
legend([plots(1), plots(maxRun+1)], 'T_{gas}','T_e')

%% Charge Species
h = figure;
hold on
plots = [];

% E
ind = 13;
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind),'b', 'LineWidth',lineWidth);
end

% H2+
ind = 23;
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind),'k', 'LineWidth',lineWidth);
end

% CH3+
ind = 26;
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind),'r', 'LineWidth',lineWidth);
end

% CH4+
ind = 25;
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind),'g', 'LineWidth',lineWidth);
end

% AR+
ind = [159, 167, 174];
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind(i)),'m', 'LineWidth',lineWidth);
end

h.CurrentAxes.XLim = [1e-7, maxTime ];
h.CurrentAxes.FontSize = fontSize;
h.CurrentAxes.LineWidth = lineWidth;
xlabel('Time (s)','FontSize',fontSize);
ylabel('Mole Fraction','FontSize',fontSize);
h.CurrentAxes.YScale = 'log';
h.CurrentAxes.YLim = [1e-9 1e-5];
legend(plots(1:3:end), 'E','H2+','CH3+','CH4+','Ar+');

%% Charge Species -1  pulse
h = figure;
hold on
plots = [];

% E
ind = 13;
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind),'b', 'LineWidth',lineWidth);
end

% H2+
ind = 23;
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind),'k', 'LineWidth',lineWidth);
end

% CH3+
ind = 26;
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind),'r', 'LineWidth',lineWidth);
end

% CH4+
ind = 25;
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind),'g', 'LineWidth',lineWidth);
end

% AR+
ind = [159, 167, 174];
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind(i)),'m', 'LineWidth',lineWidth);
end

h.CurrentAxes.XLim = [1e-7, 1e-3 ];
h.CurrentAxes.FontSize = fontSize;
h.CurrentAxes.LineWidth = lineWidth;
xlabel('Time (s)','FontSize',fontSize);
ylabel('Mole Fraction','FontSize',fontSize);
h.CurrentAxes.YScale = 'log';
h.CurrentAxes.YLim = [1e-9 1e-5];
h.CurrentAxes.YTick = [1e-9 1e-8 1e-7 1e-6 1e-5];
legend(plots(1:maxRun:end), 'E','H2+','CH3+','CH4+','Ar+');

%% Ar* and CxHy

h = figure;
hold on
plots = [];

% Ar*
ind = [158, 166, 173];
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind(i)),'m', 'LineWidth',lineWidth);
end

% C3H8
ind = [103, 103, 103];
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind(i)),'b', 'LineWidth',lineWidth);
end

% C2H6
ind = [48,48,48];
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind(i)),'g', 'LineWidth',lineWidth);
end

% CH4
ind = [30,30,30];
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind(i)),'k', 'LineWidth',lineWidth);
end

% H2
ind = [22,22,22];
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind(i)),'r', 'LineWidth',lineWidth);
end

h.CurrentAxes.FontSize = fontSize;
h.CurrentAxes.LineWidth = lineWidth;
xlabel('Time (s)','FontSize',fontSize);
ylabel('Mole Fraction','FontSize',fontSize);
h.CurrentAxes.YScale = 'log';
h.CurrentAxes.YLim = [1e-9 1e-3];
h.CurrentAxes.YTick = [1e-9 1e-8 1e-7 1e-6 1e-5 1e-4 1e-3];
legend(plots(1:maxRun:end), 'Ar*', 'C3H8', 'C2H6', 'CH4', 'H2');

%% Radicals

h = figure;
hold on
plots = [];

% C3H7
ind1 = 104;
ind2 = 105;
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind1) + dat.data(:,ind2),'r', 'LineWidth',lineWidth);
end

% H
ind = [29,29,29];
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind(i)),'b', 'LineWidth',lineWidth);
end

% O
ind = [18,18,18];
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind(i)),'g', 'LineWidth',lineWidth);
end

% OH
ind = [38,38,38];
tShift = data(1);
tShift = tShift.data(end,1);
for i = 1:maxRun
    dat = data(i);
    plots(end+1) = semilogy(dat.data(:,1) + (i-1)*tShift, dat.data(:,ind(i)),'m', 'LineWidth',lineWidth);
end

h.CurrentAxes.FontSize = fontSize;
h.CurrentAxes.LineWidth = lineWidth;
xlabel('Time (s)','FontSize',fontSize);
ylabel('Mole Fraction','FontSize',fontSize);
h.CurrentAxes.YScale = 'log';
h.CurrentAxes.YLim = [1e-9 1e-3];
h.CurrentAxes.YTick = [1e-9 1e-8 1e-7 1e-6 1e-5 1e-4 1e-3];
legend(plots(1:maxRun:end), 'C3H7','H','O','OH');