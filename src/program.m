%grye2
% Config
opengl('save', 'hardware');

% Variables
N = 3;		% Number of needles
L = 1;		% Length of needles
size = 5;

% Make coordinates
x_coord = rand(1, N);
y_coord = rand(1, N);
c = rand(1, N);

angles = rand(1, N) * 360
xc = [x_coord; x_coord + L; x_coord + L; x_coord]
yc = [y_coord; y_coord; y_coord + L; y_coord + L]

cos_ang = cosd(angles)
sin_ang = sind(angles)

patch(xc, yc, c)
colorbar
axis square

hold on

% Plot the floor
for i = 0:L:size
	%xline(i, '-', 'LineWidth', 3)
end