for iii = 1:1

% Parameters
N = 1; % Number of particles
T = 149; % Number of time steps
R = 2.4; % Radius of sphere
stepSize = 0.3; % Surface diffusion step size
dt = 4.0; % Time step
omega = pi/200; % Sphere rotation rate (radians per step)

% great! omega = pi/50; % Sphere rotation rate (radians per step)


% Initialization
initial_positions = zeros(N, 3);
positions = zeros(N, 3, T);

% Random initial positions on the sphere
theta = acos(2*rand(N,1) - 1); % [0, pi]
phi = 2*pi*rand(N,1); % [0, 2pi]
x = R * sin(theta) .* cos(phi);
y = R * sin(theta) .* sin(phi);
z = R * cos(theta);
current_positions = [x, y, z];
initial_positions = current_positions;
positions(:,:,1) = current_positions;

% Run simulation
for t = 2:T
    % Global rotation around z-axis
    rotMat = [cos(omega), -sin(omega), 0;
              sin(omega), cos(omega), 0;
                    0 , 0 , 1];
    current_positions = (rotMat * current_positions')';

    % Surface diffusion step for each particle
    for i = 1:N
        r = current_positions(i, :)';
        % Tangent plane basis
        z_hat = r / norm(r);
        arbitrary = [0; 0; 1];
        if abs(dot(z_hat, arbitrary)) > 0.99
            arbitrary = [1; 0; 0];
        end
        u = cross(z_hat, arbitrary); u = u / norm(u);
        v = cross(z_hat, u);

        % Random step in tangent plane
        alpha = 2*pi*rand();
        step = stepSize * (cos(alpha)*u + sin(alpha)*v);
        r_new = r + step;
        current_positions(i,:) = R * (r_new' / norm(r_new));
    end

    % Store position
    positions(:,:,t) = current_positions;
end

% === Compute Mean Square Displacement (MSD) in Cartesian coordinates ===
MSD = zeros(1, T);
for t = 1:T
    displacements = positions(:,:,t) - initial_positions;
    MSD(t) = mean(vecnorm(displacements, 2, 2).^2);
end

% === Plot MSD ===
time = (1:T) * dt;
figure;
plot(time, MSD, 'LineWidth', 2);
xlabel('Time');
ylabel('Mean Square Displacement (r^2)');
title('MSD of Surface Diffusing Particles on a Rotating Sphere');
grid on;

%exportgraphics(gcf, append(int2str(iii),'_MSD_simulation.pdf'), 'Resolution', 1200);
%close

%plot 3D tracks and sphere here
% === Optional: Plot trajectories ===
figure;
hold on;
[Xs, Ys, Zs] = sphere(40);
surf(R*Xs, R*Ys, R*Zs, 'FaceAlpha', 0.05, 'EdgeColor', 'none');
axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Trajectories on the Surface of a Rotating Sphere');
num_to_plot = 10;
colors = lines(num_to_plot);

for i = 1:1 %num_to_plot
    traj = squeeze(positions(i, :, :))';
    plot3(traj(:,1), traj(:,2), traj(:,3), 'Color', colors(i,:), 'LineWidth', 1.5);
end
view(3);
grid on;

save(append(int2str(iii), '_MSD_simulation_positions.mat'),'positions');

%exportgraphics(gcf, append(int2str(iii),'_track_simulation.pdf'), 'Resolution', 1200);


end