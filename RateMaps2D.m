function ratemap = RateMaps2D(TT,bdata, bin_size, smooth_kernel, dimension, circular)
%% RATEMAPS2D Parameters
if nargin < 6; circular = true; end
if nargin < 5; dimension = [200 200]; end %cm either the diameter of the table if circular or the length of the edges
if nargin < 4; smooth_kernel = [7.5 7.5]; end %cm
if nargin < 3; bin_size = [5 5]; end %cm
%     these can be modified 
%     min_time = 100 * 1e-3;;
%     min_time = min_time * 1e-6 * ((bdata.Time(end) - bdata.Time(1)) / 1e6);
      min_time = bdata.Min_time;
%     min_time =  bdata.Min_time; % this is to get rid of very low occupancy bins.
%% Load Data
string = sprintf('TT%d.spike.mat',TT);
load(string,'cluster_id','spike_time','session','subject','mean_rate')
% Match bdata with spike data. Input data has first 4 vectors as bdata: 1 =
% bdata.Time 2,3 = bdata.Position (x,y), 4 = cluster_id
[input_data, min_t] = sync3(bdata,cluster_id,spike_time);
bdata.Time(:,1) = (bdata.Time(:,1)-min_t)./1000000; % Time in seconds
input_data(:,1) = (input_data(:,1)-min_t)./1000000; % Time in seconds
neuron_num = size(cluster_id, 2); % Number of neurons 
place_cell = plc_cell2D(input_data,neuron_num); %spike data place cells
%% Bin Data
%%
% 
%   bin the spikes
%
for g = 1:neuron_num
    clear counts centers_x centers_y valid 
    scaling = 1;
    [counts,centers_x, centers_y] = Bin2D(place_cell{1,g}(:,2), [-dimension(1)/2 +dimension(1)/2], ...
        bin_size(1), place_cell{1,g}(:,3), [-dimension(2)/2 dimension(2)/2], bin_size(2), scaling);
    spikes = counts;
    %   bin the occupancy time
    clear counts centers_x centers_y valid
    scaling = mean(diff(bdata.Time));%/ 1e6;  %set to sampling period if occ_time is needed 
    %valid = bdata.Speed(:,3) > min_speed;
    %valid = true(size(bdata.Time));
    [counts,centers_x, centers_y] = Bin2D(bdata.Position(:,1), [-dimension(1)/2 +dimension(1)/2], ...
        bin_size(1), bdata.Position(:,2), [-dimension(2)/2 dimension(2)/2], bin_size(2), scaling);
    occ_time = counts;
    occ_time = smooth_gaussian_2d(centers_x, centers_y, occ_time, smooth_kernel(1), smooth_kernel(2)); % smoothing
%% Generate Plot
      if circular
        radial_cutoff_cm = dimension(1)/2;
        [a,b] = meshgrid(centers_x, centers_y);
        radial_distance = sqrt(a.^2 + b.^2);
        spikes((occ_time < min_time)) = 0;
      end
      spikes = smooth_gaussian_2d(centers_x, centers_y, spikes, smooth_kernel(1), smooth_kernel(2));
      rate = spikes ./ occ_time;
      rate((radial_distance > radial_cutoff_cm)) = nan;
      %rate(rate > 10) = 10;
      figure
imagesc(centers_x, centers_y, rate)
axis xy
colorbar
title(sprintf('Firing Rate Map Neuron %g, Mean Firing Rate = %.2f Hz',g,mean_rate(g)));
xlabel('X (cm)')
ylabel('Y (cm)')
hold on 
x = place_cell{1,g}(:,2); % x-coordinates
y = place_cell{1,g}(:,3); % y-coordinates
% Calculate the distance from the origin to each point
r = sqrt(x.^2 + y.^2);
% Define the radius of the circle map
radius = 100; % cm
% Scale the x and y coordinates to fit within the circle
x_scaled = radius * x ./ r;
y_scaled = radius * y ./ r;
% Create a circle map using the rectangle function
%figure;
rectangle('Position',[-radius,-radius,radius*2,radius*2],'Curvature',[1,1],'EdgeColor','k','LineWidth',2);
axis equal;
xlim([-radius-5, radius+5]); ylim([-radius-5, radius+5]); % Add a small margin
% Plot the position data as a scatter plot
hold on;
scatter(x, y, 10, 'filled');
xlabel('X (cm)'); ylabel('Y (cm)');
title(sprintf('Spike Locations Neuron %g',g));
end
%%