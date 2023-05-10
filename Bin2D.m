function [counts,centers_x, centers_y] = Bin2D(measure_x, bounds_x, binsize_x, measure_y, bounds_y, binsize_y, scaling, valid)
    % this function bins a two dimensional matrix given the bounds and bin
    % sizes. Set scaling to 1 if the count is needed and to sampling period
    % if occupancy time needed. Valid puts restrictions on what original
    % values to use.
    
    if nargin  < 8; valid = true(size(measure_x)); end
    if nargin < 7; scaling = 1; end

    edges_x = bounds_x(1) : binsize_x : bounds_x(2);
    edges_y = bounds_y(1) : binsize_y : bounds_y(2);
    centers_x = 0.5 * (edges_x(1 : end - 1) + edges_x(2 : end));
    centers_y = 0.5 * (edges_y(1 : end - 1) + edges_y(2 : end));
    
    measure_x = measure_x(valid);
    measure_y = measure_y(valid);
    
    % make sure the dimensions of the data are correct
    if isrow(measure_x); measure_x = measure_x'; end
    if isrow(measure_y); measure_y = measure_y'; end
    
    temp_occ = histcn([measure_x measure_y], edges_x, edges_y);
    temp_occ = temp_occ(1 : length(centers_x),  1 : length(centers_y));    
    counts = temp_occ * scaling;
    counts = squeeze(counts);

end