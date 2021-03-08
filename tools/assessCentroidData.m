%Assess Centroid Data
addpath('data');
filename = 'data/centroidData_38_to_40.xlsx';
f_ir_mm = 125; %ir camera focal length
w_pxl_ir_mm = 12.5e-3; %ir camera pixel pitch

data = xlsread(filename);
tx_res = data(:,5);
bcn_res = data(:,10);
start_pt = 1;
num_points = length(tx_res);
valid_data = zeros(1,num_points);
for k = start_pt:num_points
    if((tx_res(k) == -1) || (bcn_res(k) == -1))
        valid_data(k) = 0;
    else
        valid_data(k) = 1;
    end
end
valid_data = logical(valid_data);

tx_a = data(valid_data,1);
tx_sigma = data(valid_data,2);
tx_x = data(valid_data,3);
tx_y = data(valid_data,4);
bcn_a = data(valid_data,6);
bcn_sigma = data(valid_data,7);
bcn_x = data(valid_data,8);
bcn_y = data(valid_data,9);


err_x_pxl = tx_x - bcn_x;
err_y_pxl = tx_y - bcn_y;
err_x_urad = err_x_pxl*w_pxl_ir_mm/f_ir_mm*1e6;
err_y_urad = err_y_pxl*w_pxl_ir_mm/f_ir_mm*1e6;

figure;
subplot(2,1,1);
plot(1:length(err_x_pxl), err_x_pxl);
ylabel('X Err (pixels)');
subplot(2,1,2);
plot(1:length(err_y_pxl), err_y_pxl);
ylabel('Y Err (pixels)');
xlabel('Data Point Number');
figure;
subplot(1,2,1);
histogram(err_x_urad);
xlabel('X Err (urad)');
subplot(1,2,2);
histogram(err_y_urad);
xlabel('Y Err (urad)');

err_x_mean = mean(err_x_urad);
err_x_std = std(err_x_urad);
err_y_mean = mean(err_y_urad);
err_y_std = std(err_y_urad);
disp(['PAT Test - X Err Stats (urad): mu_x = ', num2str(err_x_mean), ', sigma_x = ', num2str(err_x_std)]);
disp(['PAT Test - Y Err Stats (urad): mu_y = ', num2str(err_y_mean), ', sigma_y = ', num2str(err_y_std)]);





