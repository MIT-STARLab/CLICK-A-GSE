%Generate angle data for GSE FSM for PAT Test Dithering
filename = 'pat_dither_gse_fsm_angles_rad.csv';
test_period_sec = 3*60; %3 minutes is a reasonable pass time
dither_frequency_hz = 5; %the bus adcs loop runs at 5 Hz
start_mu_rad = 3.82e1 * 1e-6; %acquisition error distribution from Pointing_Budget_V4.0.xlsx 
start_sigma_rad = 2497.700383 * 1e-6; %acquisition error distribution from Pointing_Budget_V4.0.xlsx 
start_reliability = 0.99; %use 99th percentile of initial error distribution
dither_sigma_rad = 122.1730476 * 1e-6; %bus pointing error from Pointing_Budget_V4.0.xlsx 
sig_figs = 6; %step resolution is about 1e-6 rad

%set starting angle
start_nu_rad = sqrt(2)*start_mu_rad;
start_ptgErr_rad = icdf('Rician',start_reliability,start_nu_rad,start_sigma_rad);
start_angles_rad = [start_ptgErr_rad, start_ptgErr_rad]; %assume worst case starting error
number_pts = test_period_sec*dither_frequency_hz;
angles_rad = zeros(number_pts, 2);
angles_rad(1,:) = start_angles_rad;
for i = 2:number_pts
    for j = 1:2
        angles_rad(i,j) = round(angles_rad(i-1,j) + normrnd(0,dither_sigma_rad), 6);
    end
end
time_vec = linspace(0,test_period_sec,number_pts);
csvwrite(filename, [time_vec', angles_rad]);

%%
figure;
plot(angles_rad(:,1)*1e3, angles_rad(:,2)*1e3,'*');
xlabel('X (mrad)');
ylabel('Y (mrad)');
title('GSE FSM Angles for PAT Dither');

figure;
subplot(2,1,1);
plot(time_vec, angles_rad(:,1)*1e3,'*');
ylabel('X (mrad)');
title('GSE FSM Angles for PAT Dither in Each Axis');
subplot(2,1,2);
plot(time_vec, angles_rad(:,2)*1e3,'*');
ylabel('Y (mrad)');
xlabel('time (sec)');