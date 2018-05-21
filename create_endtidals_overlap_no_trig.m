function [co2_trace,o2_trace] = create_endtidals_overlap_no_trig(phys_traces,TR,CO2_col,O2_col,sf)
%create_endtidals: create end-tidal traces from respiratory recordings
% 
warning off

co2_data=phys_traces(:,CO2_col);
o2_data=phys_traces(:,O2_col);

sample_res=1/sf;
sample_points=length(co2_data);
duration=sample_points*sample_res; %duration of the trace in seconds

no_TRs=sample_points*(sample_res/TR);

trace_axis=linspace(0,duration,sample_points);
TR_axis=linspace(0,duration,no_TRs);



%% CO2 data processing
%find peaks
[maxtab_co2, mintab_co2] = peakdet(co2_data, 8, trace_axis);

%plot data for review
fig=figure;
set(fig,'units','normalized','outerposition',[0 0 1 1]);
set(fig,'Toolbar','figure');

plot(trace_axis,co2_data);
hold on
red=plot(maxtab_co2(:,1),maxtab_co2(:,2),'--ro');
%set display limits
xlim([trace_axis(1),trace_axis(end)]);
ylim([20,max(co2_data)+5]);

%add buttons
but1 = uicontrol('Style','togglebutton','String','Remove Point','units','normalized','Position',[0.01 0.55 0.1 0.05]);
but2 = uicontrol('Style','togglebutton','String','Insert Point','units','normalized','Position',[0.01 0.5 0.1 0.05]);
but3 = uicontrol('Style','togglebutton','String','DONE!','units','normalized','Position',[0.01 0.45 0.1 0.05]);


%while loop for adding and removing data points to maxtab
loop = 1;
while (loop == 1);
    while ((get(but1,'Value') == 0) && (get(but2,'Value') == 0) && (get(but3,'Value') == 0))
				pause(0.01)
    end
            if (get(but1,'Value') == 1)
				h = impoint;
				pos = getPosition(h);
				delete(h);
                remove_ind = knnsearch(maxtab_co2(:,1),pos(1));
                maxtab_co2(remove_ind,:)=[];
                
                delete(red);
                red=plot(maxtab_co2(:,1),maxtab_co2(:,2),'--ro');
                
				delete(but1);
				but1 = uicontrol('Style','togglebutton','String','Remove Point','units','normalized','Position',[0.01 0.55 0.1 0.05]);
			
            elseif (get(but2,'Value') == 1)
				h = impoint;
				pos = getPosition(h);
				delete(h);
                
                
                maxtab_co2_sort = sort([maxtab_co2(:,1); pos(1)]); % sort new max indices including new point
                new_ind = knnsearch(maxtab_co2_sort,pos(1)); %find location of new point
                
                maxtab_co2(new_ind+1:end+1,:)=maxtab_co2(new_ind:end,:); %move current data one loction on
                maxtab_co2(new_ind,1)=pos(1); %enter new data
                maxtab_co2(new_ind,2)=pos(2);
                
                delete(red);
                red=plot(maxtab_co2(:,1),maxtab_co2(:,2),'--ro');

				delete(but2);
				but2 = uicontrol('Style','togglebutton','String','Insert Point','units','normalized','Position',[0.01 0.5 0.1 0.05]);
			elseif (get(but3,'Value') == 1)
				loop = 0;
				delete(but1);
				delete(but2);
				delete(but3);
                close;
            end
end



%% O2 data processing

%find peaks
[maxtab_o2, mintab_o2] = peakdet(o2_data, 1, trace_axis);

%plot data for review
fig=figure;
set(fig,'units','normalized','outerposition',[0 0 1 1]);
set(fig,'Toolbar','figure');

plot(trace_axis,o2_data);
hold on
red=plot(mintab_o2(:,1),mintab_o2(:,2),'--ro');
%set display limits
xlim([trace_axis(1),trace_axis(end)]);
ylim([0,max(o2_data)+5]);

%add buttons
but1 = uicontrol('Style','togglebutton','String','Remove Point','units','normalized','Position',[0.01 0.55 0.1 0.05]);
but2 = uicontrol('Style','togglebutton','String','Insert Point','units','normalized','Position',[0.01 0.5 0.1 0.05]);
but3 = uicontrol('Style','togglebutton','String','DONE!','units','normalized','Position',[0.01 0.45 0.1 0.05]);


%while loop for adding and removing data points to maxtab
loop = 1;
while (loop == 1);
    while ((get(but1,'Value') == 0) && (get(but2,'Value') == 0) && (get(but3,'Value') == 0))
				pause(0.01)
    end
            if (get(but1,'Value') == 1)
				h = impoint;
				pos = getPosition(h);
				delete(h);
                remove_ind = knnsearch(mintab_o2(:,1),pos(1));
                mintab_o2(remove_ind,:)=[];
                
                delete(red);
                red=plot(mintab_o2(:,1),mintab_o2(:,2),'--ro');
                
				delete(but1);
				but1 = uicontrol('Style','togglebutton','String','Remove Point','units','normalized','Position',[0.01 0.55 0.1 0.05]);
			
            elseif (get(but2,'Value') == 1)
				h = impoint;
				pos = getPosition(h);
				delete(h);
                
                
                mintab_o2_sort = sort([mintab_o2(:,1); pos(1)]); % sort new max indices including new point
                new_ind = knnsearch(mintab_o2_sort,pos(1)); %find location of new point
                
                mintab_o2(new_ind+1:end+1,:)=mintab_o2(new_ind:end,:); %move current data one loction on
                mintab_o2(new_ind,1)=pos(1); %enter new data
                mintab_o2(new_ind,2)=pos(2);
                
                delete(red);
                red=plot(mintab_o2(:,1),mintab_o2(:,2),'--ro');

				delete(but2);
				but2 = uicontrol('Style','togglebutton','String','Insert Point','units','normalized','Position',[0.01 0.5 0.1 0.05]);
			elseif (get(but3,'Value') == 1)
				loop = 0;
				delete(but1);
				delete(but2);
				delete(but3);
                close;
            end
end



%% Re-sample traces to TR

%create timeseries from the end-tidal sample points
ts_co2_endtidals = timeseries(maxtab_co2(:,2),maxtab_co2(:,1));
ts_o2_endtidals = timeseries(mintab_o2(:,2),mintab_o2(:,1));

%re-sample series to TR
res_ts_co2=resample(ts_co2_endtidals,TR_axis);
co2_trace=res_ts_co2.Data;
res_ts_o2=resample(ts_o2_endtidals,TR_axis);
o2_trace=res_ts_o2.Data;

%fill in any NaN data due to shifting and interpolation
index=find(isnan(co2_trace));
b_index=index(le(index,length(co2_trace)/2));
e_index=index(gt(index,length(co2_trace)/2));
co2_trace(b_index)=nanmean(co2_trace(1:20));
co2_trace(e_index)=nanmean(co2_trace(end-2:end));

index=find(isnan(o2_trace));
b_index=index(le(index,length(o2_trace)/2));
e_index=index(gt(index,length(o2_trace)/2));
o2_trace(b_index)=nanmean(o2_trace(1:20));
o2_trace(e_index)=nanmean(o2_trace(end-2:end));

end
