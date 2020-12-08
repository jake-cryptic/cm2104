% Config
opengl('save', 'hardware');

% Variables
N = 1000;		% Number of needles
L = 0.30;		% Length of needles
size = 5;

% Make coordinates
x_coord = L + rand(1,N) * (size - 2*L);
y_coord = L + rand(1,N) * (size - 2*L);

angles = rand(1, N) * 360;
x_angle = x_coord + L * cosd(angles);
y_angle = y_coord + L * sind(angles);

% Plot the needles
plot(axes, [x_coord; x_angle], [y_coord; y_angle], 'LineWidth', 2)
axis square

hold on

% Plot the floor
for i = 0:L:size
	xline(i, '-', 'LineWidth', 3)
end

% Estimate Pi
n = sum(floor(x_coord / L) ~= floor(x_angle / L));
piEstimate = 2 * N / n