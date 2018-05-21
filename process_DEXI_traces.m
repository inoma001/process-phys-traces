function [co2_trace,o2_trace] = process_DEXI_traces(filename,TR,phys_trolly,sf)

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
 %trig_chan=5;
    
    co2_chan=3;
    o2_chan=2;
    A.data(:,co2_chan)=A.data(:,co2_chan).*(760/100);%convert % to mmHg assuming 760 mmHg pressure 
end



trig_data=A.data(:,trig_chan);
    
if phys_trolly <2 % old style triggers
    %clean trigger data
    trig_data(lt(trig_data,1))=0;
    trig_data(gt(trig_data,1))=0;
    A.data(:,trig_chan)=trig_data;
else  %toggle triggers
    
    trig_data(lt(trig_data,1))=0;
    trig_data(gt(trig_data,1))=1;
    A.data(:,trig_chan)=trig_data;
           
end

% A.data(5.902e5:5.909e5,trig_chan)=0; %manually edit out bad triggers
% A.data(7.265e5:7.268e5,trig_chan)=0;

disp('Select the period of the acquisition (click once either side of the data)');

%use GUI to set start and end points for desired data range
fig=figure;
set(fig,'units','normalized','outerposition',[0 0 1 1]);
plot(A.data(:,trig_chan));
%get two data points from the plot either end of the DEXI acquisition 
[x,y]=ginput(2);
%close the gui

close

pause(0.1);

%select the appropriate range 

A_trim=A.data(round(x(1)):round(x(2)),:);
% A_trim is a matrix with the trimmed physiological traces to experiment
% region
trig_data=A_trim(:,trig_chan);
vol_trigs=trig_data; %volume triggers for TR[0] in DEXI acquisition


if phys_trolly <2 % old style triggers
    %remove every other trigger (BOLD trig)
    count=0;
    for i=1:length(trig_data)
        if count>0 && trig_data(i)>0
            vol_trigs(i)=0;
            count=0;
        elseif trig_data(i)>0
            count=1;
        end
    end
    A_trim(:,trig_chan)=vol_trigs;
else %convert toggle data to triggers
    
    vol_trigs=diff(vol_trigs);
    if trig_data(1) < 1 %if starting toggle on a 'low'
        vol_trigs(le(vol_trigs,0))=0; %remove BOLD trigger
    else
        vol_trigs(gt(vol_trigs,0))=0; %remove BOLD trigger.... not tested yet.
        vol_trigs(lt(vol_trigs,0))=1;
    end
        
end


k=find(vol_trigs);
if TR==0 %calculate TR from triggers if none specified
  %  TR=(k(3)-k(2))*(1/500) %500Hz sample rate
    TR=(k(3)-k(2))*(1/sf) %500Hz sample rate
end
NAQ=sum(vol_trigs)

%figure,plot(vol_trigs)
%%

% call function to calculate end-tidals with user assistance
[co2_trace,o2_trace] = create_endtidals_overlap(A_trim,NAQ,TR,co2_chan,o2_chan,trig_chan,sf);

z=strfind(filename,'/');
out_dir=filename(1:z(end));
save([out_dir 'endtidal_traces_overlap.mat'],'co2_trace','o2_trace');

end

