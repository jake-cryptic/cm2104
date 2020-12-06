N = 10;   % Number of needles
L = 4;      % Length of needles
D = 2;      % Distance between planks
NoP = 4;    % Number of planks

size = 2;

if L > D
    msgbox('L > D, this cannot happen', 'Error', 'error');
end

x_coords = rand(1, N) * size;
y_coords = rand(1, N) * size;

plot(x_coords, y_coords);