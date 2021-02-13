%Assess Beacon Spot
addpath('2dgaussian301');
addpath('data');
sigma_req = 0.5*(0.95/0.963)*4.2; %uplink budget has a 96.3% airy radius of 4.2, or about a 2 sigma (95%) of 4.1433
filename = 'data/2020-09-12-16-22-30_ACQUISITION_exp_963.png';
imdata = imread(filename);
imdata_normalized = imdata/max(max(imdata));
figure;
imagesc(imdata_normalized);
title('Beacon Image (Normalized)');
colorbar;

sz = size(imdata_normalized);
[xi,yi] = meshgrid(1:sz(2), 1:sz(1));
zi = double(imdata_normalized);
results = autoGaussianSurf(xi,yi,zi);
disp(['file: ', filename]);
disp(results);
disp(['sigma_req = ', num2str(sigma_req)]);
if((results.sigmax <= sigma_req) && (results.sigmay <= sigma_req))
    disp('(results.sigmax <= sigma_req)) and (results.sigmax <= sigma_req)');
    disp('PASSED');
else
    disp('(results.sigmax > sigma_req)) or (results.sigmax > sigma_req)');
    disp('FAILED');
end
hold on;
gaussian_fit = @(xi,yi,results) results.a*exp(-((xi-results.x0).^2/2/results.sigmax^2 + (yi-results.y0).^2/2/results.sigmay^2)) + results.b;
contour(xi,yi,results.G,gaussian_fit(results.x0 + results.sigmax, results.y0, results));
hold off;

