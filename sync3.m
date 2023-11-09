function[input_data, min_t]=sync3(bdata, cluster_id, spike_time)
spike_time = double(spike_time);
bdata = [bdata.Time bdata.Position];
pos_tim = bdata;
ind = abs(diff(pos_tim(:,1)))==0;
pos_tim(ind,:) = [];

posx = interp1(pos_tim(:,1), pos_tim(:,2:end), spike_time);
   
input_data = [spike_time posx cluster_id];
[r ~] = find(isnan(input_data));
input_data(r,:)=[];    

min_t = min(input_data(1,1));