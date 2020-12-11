% Config
opengl('save', 'hardware');

% Variables
S = 1;			% Scaling factor
N = 9;			% Number of squares
NoP = 10;		% Number of planks
D = S/NoP;		% Distance between planks
SL = D/5;		% Length of squares

% Plot the floor
for i = 0:D:S
	xline(i, '-', 'LineWidth', 2)
end

% Make coordinates
sq_angles = rand(1, N) * 180;
xc = rand(1, N);
yc = rand(1, N);

xcr = [...
	SL * cosd(sq_angles) + SL * sind(sq_angles) + xc;...
	SL * cosd(sq_angles) - SL * sind(sq_angles) + xc;...
	-SL * cosd(sq_angles) - SL * sind(sq_angles) + xc;...
	-SL * cosd(sq_angles) + SL * sind(sq_angles) + xc;...
	(-SL * cosd(sq_angles) + SL * sind(sq_angles) + xc)*sind(60);...
];
ycr = [...
	-SL * sind(sq_angles) + SL * cosd(sq_angles) + yc;...
	-SL * sind(sq_angles) - SL * cosd(sq_angles) + yc;...
	SL * sind(sq_angles) - SL * cosd(sq_angles) + yc;...
	SL * sind(sq_angles) + SL * cosd(sq_angles) + yc;...
	SL * sind(sq_angles) + SL * cosd(sq_angles) + yc;...
];

% Plot all the things
patch(xcr, ycr, 'red');

% Calculate root two
n = 0;
n = n + sum(floor(xcr(1, :)/D) ~= floor(xcr(2, :)/D)) + ...
		sum(floor(xcr(2, :)/D) ~= floor(xcr(3, :)/D)) + ...
		sum(floor(xcr(3, :)/D) ~= floor(xcr(4, :)/D)) + ...
		sum(floor(xcr(4, :)/D) ~= floor(xcr(1, :)/D))
	
r = 0;
r = n*2

t = N*4;
rt_estimate = t/r

axis square