% positions: N x 3 x T   (LOADED BY YOU)
[N,~,T] = size(positions);

% Parameters
N = 1;            % Number of particles
T = 149;          % Number of time steps
R = 2.4;          % Radius of sphere
stepSize = 0.3;   % Surface diffusion step size
dt = 4.0;         % Time step
omega = pi/200;   % Sphere rotation rate (radians per step)

% === Fixed-t0 MSD ===
initial_positions = positions(:,:,1);

MSD_t0 = zeros(T,1);
for t = 1:T
    dr = positions(:,:,t) - initial_positions;
    MSD_t0(t) = mean(sum(dr.^2, 2));
end

% === Lag-MSD (moving t0, SAME as real data) ===
maxLag = T - 1;
MSD_lag = zeros(maxLag,1);

for lag = 1:maxLag
    d2_all = zeros(N, T-lag);
    for t0 = 1:(T-lag)
        dr = positions(:,:,t0+lag) - positions(:,:,t0);
        d2_all(:,t0) = sum(dr.^2, 2);
    end
    MSD_lag(lag) = mean(d2_all(:));
end

% === Mean-square radius <r^2> ===
r2_t = sum(positions.^2, 2);   % N x 1 x T
r2_t = squeeze(r2_t);          % N x T
r2_mean = mean(r2_t(:));

% === Plot comparison ===
time = (1:T)' * dt;
tau  = (1:maxLag)' * dt;

figure;
plot(time, MSD_t0, 'LineWidth', 2); hold on;
plot(tau,  MSD_lag, 'LineWidth', 2);
yline(r2_mean, '--', '<r^2>', 'LineWidth', 2);

xlabel('Time / Lag (s)');
ylabel('(\mum^2)');
legend('Fixed t_0 MSD', 'Lag-MSD (moving t_0)', '<r^2>', 'Location','best');
title('Bound motion: fixed-t_0 MSD vs lag-MSD vs <r^2>');
grid on;

% === Diagnostics ===
disp(['<r^2> = ', num2str(r2_mean)])
disp(['2<r^2> = ', num2str(2*r2_mean)])
disp(['Lag-MSD plateau ~ ', num2str(mean(MSD_lag(end-5:end)))])
disp(['Fixed-t0 plateau ~ ', num2str(mean(MSD_t0(end-5:end)))])
