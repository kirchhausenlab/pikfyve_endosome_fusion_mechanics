% Parameters
N = 1;            % Number of particles (reduced for plotting)
T = 149;          % Number of time steps
R = 1.6;          % Radius of sphere
stepSize = 0.7;   % Step size (comparable to R)
dt = 4.0;         % Time step

% Initialization
positions = zeros(N, 3, T);        % Store full trajectories
current_positions = zeros(N, 3);   % Current positions
msr = zeros(1, T);                 % mean-square radius <r^2(t)> (misnamed MSD before)

for t = 1:T
    % Generate random directions
    directions = randn(N, 3);
    directions = directions ./ vecnorm(directions, 2, 2); % Normalize
    steps = stepSize * directions;

    % Propose new positions
    new_positions = current_positions + steps;
    distances = vecnorm(new_positions, 2, 2);
    outside = distances > R;

    % Reflect particles back if outside the sphere
    for i = 1:N
        if outside(i)
            overshoot = distances(i) - R;
            unit_vec = new_positions(i,:) / distances(i);
            new_positions(i,:) = new_positions(i,:) - 2 * overshoot * unit_vec;
        end
    end

    % Update positions and store
    current_positions = new_positions;
    positions(:, :, t) = current_positions;

    % Compute mean-square radius <r^2(t)>
    msr(t) = mean(vecnorm(current_positions, 2, 2).^2);
end

% === Compute lag-MSD from stored trajectory (raw positions) ===
maxLag = T - 1;
lagMSD = zeros(1, maxLag);

for lag = 1:maxLag
    d2_all = [];  % collect all squared displacements for this lag
    for t0 = 1:(T - lag)
        dr = positions(:, :, t0 + lag) - positions(:, :, t0); % N x 3
        d2 = sum(dr.^2, 2);                                   % N x 1
        d2_all = [d2_all; d2];                                %#ok<AGROW>
    end
    lagMSD(lag) = mean(d2_all);
end

% === Plot mean-square radius and lag-MSD together ===
figure;
time = (1:T) * dt;
tau  = (1:maxLag) * dt;

plot(time, msr, 'b', 'LineWidth', 2); hold on;
plot(tau,  lagMSD, 'k', 'LineWidth', 2);

yline((3/5)*R^2, '--b', '<r^2> = (3/5)R^2');
yline((6/5)*R^2, '--k', 'MSD_\infty = (6/5)R^2');

xlabel('Time / Lag (s)');
ylabel('(\mum^2)');
legend('<r^2(t)> (mean-square radius)', 'Lag-MSD(\Delta)', 'Location', 'best');
title('Mean-square radius vs Lag-MSD inside a sphere');
grid on;

ylim([0 25])

% === Plot Trajectories ===
figure; hold on;
num_to_plot = min(10, N);
colors = lines(num_to_plot);

for i = 1:num_to_plot
    traj = squeeze(positions(i, :, :))';  % T x 3
    plot3(traj(:,1), traj(:,2), traj(:,3), 'Color', colors(i,:), 'LineWidth', 1.5);
end

% Draw boundary sphere
[Xs, Ys, Zs] = sphere(30);
surf(R*Xs, R*Ys, R*Zs, 'FaceAlpha', 0.05, 'EdgeColor', 'none');
axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Particle Trajectories Inside a Sphere');
grid on;
view(3);
