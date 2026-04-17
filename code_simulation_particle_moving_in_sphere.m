% Parameters
N = 1;            % Number of particles (reduced for plotting)
T = 149;            % Number of time steps
R = 1.6;            % Radius of sphere
stepSize = 0.7;     % Step size (comparable to R)
dt = 4.0;           % Time step

% Initialization
positions = zeros(N, 3, T);     % Store full trajectories
current_positions = zeros(N, 3);  % Current positions
MSD = zeros(1, T);              % Mean square displacement

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

    % Compute MSD
    MSD(t) = mean(vecnorm(current_positions, 2, 2).^2);
end

% === Plot MSD ===
figure;
time = (1:T) * dt;
plot(time, MSD, 'b', 'LineWidth', 2);
hold on;
yline((3/5)*R^2, '--r', 'Max MSD = (3/5)R^2');
xlabel('Time');
ylabel('Mean Square Displacement');
title('MSD of Diffusion in a Sphere');
grid on;

% === Plot Trajectories (first few particles only) ===
figure;
hold on;
num_to_plot = 10;  % Show only first 10 trajectories
colors = lines(num_to_plot);

for i = 1:1 %num_to_plot
    traj = squeeze(positions(i, :, :))';  % T x 3
    plot3(traj(:,1), traj(:,2), traj(:,3), 'Color', colors(i,:), 'LineWidth', 1.5);
%     scatter3(traj(:,1), traj(:,2), traj(:,3), 40, time, 'filled')
%     colormap(jet)
%     colorbar
%     hold on
%     plot3(traj(:,1), traj(:,2), traj(:,3), 'k')
end

% Draw boundary sphere
[Xs, Ys, Zs] = sphere(30);
surf(R*Xs, R*Ys, R*Zs, 'FaceAlpha', 0.05, 'EdgeColor', 'none');
axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Particle Trajectories Inside a Sphere');
grid on;
view(3);