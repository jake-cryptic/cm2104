%grye2
% Config
opengl('save', 'hardware');

% Variables
S = 1;		% Scaling factor
N = 10000000;	% Number of squares
NoP = 10;	% Number of planks
D = S/NoP;	% Distance between planks
SL = D/4;	% Length of squares

% Plot the floor
for i = 0:D:S
	xline(i, '-', 'LineWidth', 2)
end

% Make coordinates
sq_angles = rand(1, N) * 360;
xc = rand(1, N);
yc = rand(1, N);

xcr = [...
	SL * cosd(sq_angles) + SL * sind(sq_angles) + xc;...
	SL * cosd(sq_angles) - SL * sind(sq_angles) + xc;...
	-SL * cosd(sq_angles) - SL * sind(sq_angles) + xc;...
	-SL * cosd(sq_angles) + SL * sind(sq_angles) + xc;...
];
ycr = [...
	-SL * sind(sq_angles) + SL * cosd(sq_angles) + yc;...
	-SL * sind(sq_angles) - SL * cosd(sq_angles) + yc;...
	SL * sind(sq_angles) - SL * cosd(sq_angles) + yc;...
	SL * sind(sq_angles) + SL * cosd(sq_angles) + yc;...
];

% Plot all the things
% patch(xcr, ycr, 'red');

% aa

n = 0;
n = n + sum(floor(xcr(1, :)/D) ~= floor(xcr(2, :)/D)) + ...
		sum(floor(xcr(2, :)/D) ~= floor(xcr(3, :)/D)) + ...
		sum(floor(xcr(3, :)/D) ~= floor(xcr(4, :)/D)) + ...
		sum(floor(xcr(4, :)/D) ~= floor(xcr(1, :)/D))
t = N*4;
pi_estimate = t/n

axis square
hold on