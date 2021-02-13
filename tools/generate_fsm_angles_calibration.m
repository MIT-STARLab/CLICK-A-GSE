%Generate angle data for GSE FSM for Camera Calibration
filename = 'calib_cmds.csv';
number_pts = 200; num_revs = 4; 
update_frequency_hz = 0.5; 
test_period_sec = number_pts/update_frequency_hz;
max_range_rad = 2.5e-3; %total angle = 2x this value (max FSM range is +/- 5 deg)
sig_figs = 6; %step resolution is about 1e-6 rad
angles_rad = zeros(number_pts, 2);
for i = 0:number_pts
    t = i/number_pts;
    angles_rad(i+1, 1) = round(max_range_rad*t*cos(2*pi*num_revs*t), sig_figs);
    angles_rad(i+1, 2) = round(max_range_rad*t*sin(2*pi*num_revs*t), sig_figs);
end
angles_rad = [angles_rad; [0, 0]];
number_pts = number_pts + 1;
angles_rel_rad = zeros(number_pts, 2);
for j = 1:number_pts
    for k = 1:2
        angles_rel_rad(j,k) = angles_rad(j+1,k) - angles_rad(j,k);
    end
end
TIME = linspace(0,test_period_sec,number_pts)';
X_CMD = angles_rel_rad(:,1);
Y_CMD = angles_rel_rad(:,2);
T = table(X_CMD,Y_CMD);
writetable(T,filename);
%csvwrite(filename, [time_vec', angles_rad]);

%%
figure;
plot(angles_rad(:,1)*1e3, angles_rad(:,2)*1e3,'*');
hold on;
plot(angles_rad(end,1)*1e3, angles_rad(end,2)*1e3,'ro');
xlabel('X (mrad)');
ylabel('Y (mrad)');
title('GSE FSM Angles for Calibration');
hold off;

figure;
subplot(2,1,1);
plot(TIME, angles_rel_rad(:,1)*1e3,'*');
ylabel('X_CMDS (mrad)');
title('GSE FSM Relative Angles for Calibration in Each Axis');
subplot(2,1,2);
plot(TIME, angles_rel_rad(:,2)*1e3,'*');
ylabel('Y_CMDS (mrad)');
xlabel('TIME (sec)');