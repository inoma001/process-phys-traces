function [co2_trace,o2_trace] = process_DEXI_traces_no_trig(filename,TR,phys_trolly,sf)

%no trig data... need to specify TR

if sf <1
    sf=500; %default sample frequency Hz
end
%script to extact CO2 and O2 physilogical traces from traces recordings
%capture during DEXI data acquisition

%filename is the txt export recorded at 500Hz.

%TR is the effective TR (TR[0] + TR[1]) (enter 0 to calculate from
%triggers)
 
A=importdata(filename);

%set-up channels dependent on trolley used: 'west' = 0, 'east' = 1, 'new; =2 ; 

if phys_trolly==0
    %channel numbers for 'west' phys trolley
    trig_chan=6;
    co2_chan=5;
    o2_chan=4;
elseif phys_trolly==1
    %channel numbers for 'east' phys trolley
    trig_chan=5;
    co2_chan=4;
    o2_chan=3;
elseif phys_trolly==2
    %channel numbers for 'new' phys trolley
    trig_chan=6;
    co2_chan=3;
    o2_chan=2;
    A.data(:,co2_chan)=A.data(:,co2_chan).*(760/100);%convert % to mmHg assuming 760 mmHg pressure 
end


disp('Select the period of the acquisition (click once either side of the data)');

%use GUI to set start and end points for desired data range
fig=figure;
set(fig,'units','normalized','outerposition',[0 0 1 1]);
plot(A.data(:,co2_chan));
%get two data points from the plot either end of the DEXI acquisition 
[x,y]=ginput(2);
%close the gui

close

pause(0.1);

%select the appropriate range 

A_trim=A.data(round(x(1)):round(x(2)),:);

% call function to calculate end-tidals with user assistance
[co2_trace,o2_trace] = create_endtidals_overlap_no_trig(A_trim,TR,co2_chan,o2_chan,sf);

z=strfind(filename,'/');
out_dir=filename(1:z(end));
save([out_dir 'endtidal_traces_overlap.mat'],'co2_trace','o2_trace');

end

