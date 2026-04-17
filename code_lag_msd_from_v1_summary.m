hold off
[ss,mm] = size(v1_summary);
time = uint32(1):uint32(ss-1);

% --- Lag-MSD (moving t0): your current code ---
for delay = 1:ss-1

    distance = [];
    msd = [];

    for i = 1:ss-delay

        x1 = v1_summary(i,8)*0.145;
        y1 = v1_summary(i,9)*0.145;
        z1 = v1_summary(i,10)*0.250;

        x2 = v1_summary(i+delay,8)*0.145;
        y2 = v1_summary(i+delay,9)*0.145;
        z2 = v1_summary(i+delay,10)*0.250;

        distance(i) = sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2);
        msd(i)      = (x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2;

    end

    msd_average(delay,1) = mean(msd);
    msd_average(delay,2) = std(msd);
    msd_average(delay,3) = i;
    msd_average(delay,4) = delay;
    msd_average(delay,5) = mean(distance);
    msd_average(delay,6) = std(distance);

end

% --- Fixed t0 MSD: |r(t0+delay) - r(t0)|^2 with t0 = first frame ---
x0 = v1_summary(1,8)*0.145;
y0 = v1_summary(1,9)*0.145;
z0 = v1_summary(1,10)*0.250;

msd_fixed = zeros(ss-1,1);
for delay = 1:ss-1
    x2 = v1_summary(1+delay,8)*0.145;
    y2 = v1_summary(1+delay,9)*0.145;
    z2 = v1_summary(1+delay,10)*0.250;

    msd_fixed(delay) = (x2-x0)^2 + (y2-y0)^2 + (z2-z0)^2;
end

% --- Mean-square radius <r^2> (assumes already centered to moving sphere center) ---
x = v1_summary(:,8) * 0.145;
y = v1_summary(:,9) * 0.145;
z = v1_summary(:,10) * 0.250;

r2 = x.^2 + y.^2 + z.^2;
r2_mean = mean(r2);
r2_std  = std(r2);

% --- Plot all together ---
hold off
hold on
plot(2.3*time, msd_average(:,1), 'k', 'LineWidth', 2); hold on;      % lag-MSD
plot(2.3*time, msd_fixed, 'Color', [0.5 0.5 0.5], 'LineWidth', 2);   % fixed t0 MSD
yline(r2_mean, '--b', '<r^2>', 'LineWidth', 2);                   % <r^2> value

xlabel(' \Delta\tau (s)','Interpreter','Tex')
ylabel('(\mum^2)','Interpreter','Tex')
legend('Lag-MSD(\Delta)', 'Fixed t_0: |r(t)-r(0)|^2', '<r^2>', 'Location','best')
ylim([0 max(msd_fixed)*1.5])
grid on

disp(['<r^2> = ', num2str(r2_mean), ' +/- ', num2str(r2_std)])
disp(['2<r^2> = ', num2str(2*r2_mean)])
disp(['Lag-MSD plateau ~ ', num2str(mean(msd_average(end-5:end,1)))])
disp(['Fixed-t0 plateau ~ ', num2str(mean(msd_fixed(end-5:end)))])


% --- Estimate R from the long-lag plateau of the lag-MSD ---
nTail = min(10, ss-1);                         % use last 10 lags (or fewer if short track)
P_lag = mean(msd_average(end-nTail+1:end, 1)); % plateau estimate (µm^2)

% For diffusion confined within a spherical VOLUME: MSD_inf = (6/5) R^2
R_from_lag = sqrt((5/6) * P_lag);              % R in µm

disp(['Lag-MSD plateau P = ', num2str(P_lag), ' (\mum^2)'])
disp(['R from lag-MSD plateau (volume) = ', num2str(R_from_lag), ' (\mum)'])

