%Generate angle data for GSE FSM for Camera Calibration
filename = 'calibration_gse_fsm_angles_rad.csv';
number_pts = 250; num_revs = 4; 
update_frequency_hz = 0.5; 
test_period_sec = number_pts/update_frequency_hz;
max_range_rad = deg2rad(3); %total angle = 2x this value (max FSM range is +/- 5 deg)
sig_figs = 6; %step resolution is about 1e-6 rad
angles_rad = zeros(number_pts, 2);
for i = 0:(number_pts-1)
    t = i/(number_pts-1);
    angles_rad(i+1, 1) = round(max_range_rad*t*cos(2*pi*num_revs*t), sig_figs);
    angles_rad(i+1, 2) = round(max_range_rad*t*sin(2*pi*num_revs*t), sig_figs);
end
time_vec = linspace(0,test_period_sec,number_pts);
csvwrite(filename, [time_vec', angles_rad]);

%%
figure;
plot(angles_rad(:,1)*1e3, angles_rad(:,2)*1e3,'*');
xlabel('X (mrad)');
ylabel('Y (mrad)');
title('GSE FSM Angles for Calibration');

figure;
subplot(2,1,1);
plot(time_vec, angles_rad(:,1)*1e3,'*');
ylabel('X (mrad)');
title('GSE FSM Angles for Calibration in Each Axis');
subplot(2,1,2);
plot(time_vec, angles_rad(:,2)*1e3,'*');
ylabel('Y (mrad)');
xlabel('time (sec)');