function [ r ] = smooth_gaussian_2d( x, y, m, sigma_x, sigma_y, periodic, upsample_factor )
% m is length(y) by length(x)
    if nargin < 6; periodic = [false, false]; end   
    if nargin < 7; upsample_factor = 5; end

    % Need to pad the original matrix    
    
    dx = (mean(diff(x)));
    dy = mean(diff(y));
    
    dxx = dx / upsample_factor;
    dyy = dy / upsample_factor;
    
    gx = 0 : dxx : 3 * sigma_x; gx = [-gx(end:-1:2), gx];
    gy = 0 : dyy : 3 * sigma_y; gy = [-gy(end:-1:2), gy];
    
    g = zeros(length(gx), length(gy))';
    
    temp_y = repmat(gy, 1, length(gx))';
    temp_x = repmat(gx, length(gy), 1); temp_x = temp_x(:);

    g(:) = mvnpdf([temp_x, temp_y], [0,0], [sigma_x^2, 0; 0, sigma_y^2]);
               
    if upsample_factor ~= 1
        xx = min(x) : dxx : max(x);
        yy = min(y) : dyy : max(y);
        mm = interp2(x,y,m, xx, yy');
    else
        mm = m;
        xx = x;
        yy = y;
    end
    
    ly = (length(gy)-1)/2;
    lx = (length(gx)-1)/2;
    
    pad = zeros(size(mm,1) + 2 * ly, size(mm,2) + 2 * lx);
    pad(ly+1:end-ly, lx+1:end-lx) = mm;
    
    if periodic(2)
        pad(1:ly,:) = pad( (end-ly+1:end) - ly, :);
        pad( (end-ly+1:end), :) = pad( (1:ly) +ly, :);
    else
        pad(1:ly,:) = repmat(pad(ly+1,:), ly,1);
        pad(end-ly+1:end,:) = repmat(pad(end-ly,:), ly,1);
    end
    
    if periodic(1)
        pad(:, 1:lx) = pad( :, (end-lx+1:end) - lx);
        pad(:, (end-lx+1:end)) = pad( :, (1:lx) +lx);
    else
        pad(:, 1:lx) = repmat(pad(:,lx+1), 1, lx);
        pad(:, end-lx+1:end) = repmat(pad(:,end-lx), 1, lx);
    end
    
    
    r = conv2(pad,g) * dxx * dyy;

    temp = r(2*ly+1:end-2*ly, 2*lx+1:end-2*lx);
    
    temp2 = interp2(xx,yy,temp,x,y');
    
    %temp2 = temp(1:upsample_factor:end, 1:upsample_factor:end);
    
    r = temp2;
    
    %{
    
    
    
    

    r = m;
    
    tic
    
    for jj = 1 : length(x)
        r(:,jj) = smooth_gaussian_1d(y, r(:,jj), sigma_y, periodic(2));
    end    
    for jj = 1 : length(y)
        r(jj,:) = smooth_gaussian_1d(x, r(jj,:), sigma_x, periodic(1));
    end    
    toc
    %}
end

