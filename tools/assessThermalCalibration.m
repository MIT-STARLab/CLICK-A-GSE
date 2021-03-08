%Assess Tx Offset Thermal Calibration Data
addpath('data');
fileName = 'data/Tx Offset Calibration.xlsx';
f_ir_mm = 125; %ir camera focal length
w_pxl_ir_mm = 12.5e-3; %ir camera pixel pitch
n_pts = 22;
data = xlsread(fileName);
temperatures = data(1:n_pts,2);
offset_x = data(1:n_pts,3);
offset_y = data(1:n_pts,4);
tx_x = data(1:n_pts,5);
tx_y = data(1:n_pts,6);
bcn_x = data(1:n_pts,7);
bcn_y = data(1:n_pts,8);
err_x = tx_x - bcn_x;
err_y = tx_y - bcn_y;
pxls_to_urad = w_pxl_ir_mm/f_ir_mm*1e6;
pxls_to_mrad = w_pxl_ir_mm/f_ir_mm*1e3;
err_x_urad = err_x*pxls_to_urad;
err_y_urad = err_y*pxls_to_urad;
calib_err_mean_x_urad = mean(err_x_urad);
calib_err_std_x_urad = std(err_x_urad);
calib_err_mean_y_urad = mean(err_y_urad);
calib_err_std_y_urad = std(err_y_urad);
disp(['X calib uncertainty (urad): mu = ', num2str(calib_err_mean_x_urad), ', sigma = ', num2str(calib_err_std_x_urad)]);
disp(['Y calib uncertainty (urad): mu = ', num2str(calib_err_mean_y_urad), ', sigma = ', num2str(calib_err_std_y_urad)]);

%fit linearly to x
fit_x = polyfit(temperatures,offset_x,1);
disp(['X Linear Coeffs (pxls/C, pxls): ', num2str(fit_x)]);

dither_radius_x = 4;
dither_radius_y = 1;
temp_axis = linspace(min(temperatures)-1,max(temperatures)+1,50);
figure;
plot(temperatures,offset_x*pxls_to_mrad,'r*');
hold on;
plot(temp_axis, (fit_x(1)*temp_axis + fit_x(2))*pxls_to_mrad,'r-');
plot(temp_axis, (fit_x(1)*temp_axis + fit_x(2) + dither_radius_x)*pxls_to_mrad,'r--');
plot(temp_axis, (fit_x(1)*temp_axis + fit_x(2) - dither_radius_x)*pxls_to_mrad,'r--');
hold off;
legend('Data','Linear Model','Dither Upper Range','Dither Lower Range');
xlabel('Camera Temperature (deg C)');
ylabel('Tx Offset in X (mrad)');
title('Tx Offset X Calibration and Dither Range Determination')

%fit quadratically to y
fit_y = polyfit(temperatures,offset_y,2);
disp(['Y Quadratic Coeffs (pxls/C^2, pxls/C, pxls): ', num2str(fit_y)]);
figure;
plot(temperatures,offset_y*pxls_to_mrad,'r*');
hold on;
plot(temp_axis, (fit_y(1)*temp_axis.^2 + fit_y(2)*temp_axis + fit_y(3))*pxls_to_mrad,'r-');
plot(temp_axis, (fit_y(1)*temp_axis.^2 + fit_y(2)*temp_axis + fit_y(3) + dither_radius_y)*pxls_to_mrad,'r--');
plot(temp_axis, (fit_y(1)*temp_axis.^2 + fit_y(2)*temp_axis + fit_y(3) - dither_radius_y)*pxls_to_mrad,'r--');
hold off;
legend('Data','Quadratic Model','Dither Upper Range','Dither Lower Range');
xlabel('Camera Temperature (deg C)');
ylabel('Tx Offset in Y (mrad)');
title('Tx Offset in Y Calibration and Dither Range Determination')

% figure;
% subplot(1,2,1);
% histogram(err_x_urad);
% xlabel('X Calibration Err (urad)');
% subplot(1,2,2);
% histogram(err_y_urad);
% xlabel('Y Calibration Err (urad)');