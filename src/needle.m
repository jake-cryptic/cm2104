S	=	1;					% Scale factor
N	=	1000;				% Number of needles
NoP	=	10;					% Number of planks
L	=	S/NoP;
size = 5;

disp(N);

x_coord = L + rand(1,N) * (size - 2*L);
y_coord = L + rand(1,N) * (size - 2*L);

angles = rand(1, N) * 360;
x_angle = x_coord + L * cosd(angles);
y_angle = y_coord + L * sind(angles);

plot([x_coord; x_angle], [y_coord; y_angle], 'LineWidth', 2);