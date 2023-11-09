function [place_cell] = plc_cell(input_data, neuron_num)
place_cell = cell(1, neuron_num);
for j = 1:neuron_num;
    rr = input_data(:,j+3)==0; % this line can be adjusted to rows in input_data *used to be +7 with all bdata included
    temp = input_data;
    temp(rr,:)=[];
    place_cell{1,j}=temp(:,1:4); %this line can be adjusted to rows in input_data *used to be 8
end