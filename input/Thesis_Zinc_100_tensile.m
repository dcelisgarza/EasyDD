% Results in strain-stress
% Stress := load/area = Fsim/area of cantilever face
% Strain := displacement/length = Usim/cantilever length
clear all;
close all;
CRYSTAL_STRUCTURE = 'fcc';

slipPlanes = [
        1.0 1.0 1.0;
        1.0 1.0 1.0;
        1.0 1.0 1.0;
        -1.0 1.0 1.0;
        -1.0 1.0 1.0;
        -1.0 1.0 1.0;
        1.0 -1.0 1.0;
        1.0 -1.0 1.0;
        1.0 -1.0 1.0;
        1.0 1.0 -1.0;
        1.0 1.0 -1.0;
        1.0 1.0 -1.0
        ];
bVec = [
    1.0 -1.0 0.0;
    1.0 0.0 -1.0;
    0.0 1.0 -1.0;
    1.0 1.0 0.0;
    1.0 0.0 1.0;
    0.0 1.0 -1.0;
    1.0 1.0 0.0;
    0.0 1.0 1.0;
    1.0 0.0 -1.0;
    1.0 0.0 1.0;
    0.0 1.0 1.0;
    1.0 -1.0 0.0
    ];

% Values from https://www.azom.com/properties.aspx?ArticleID=749
% FCC Zinc lattice parameter: 0.541 nm
amag = 0.541 * 10^ - 3; % microns
% FCC Zinc shear modulus: 35 - 45 GPA
mumag = 40e3; % MPa
MU = 1.0;
% FCC Zinc poisson's ratio 0.245--0.255.
NU = 0.25;

% x = <100>, y = <010>, z = <001>
dz = 8.711 / amag; % 8.711 microns
dx = 3 * dz;
dy = 2 * dz;

vertices = [0, 0, 0; ...
            dx, 0, 0; ...
            0, dy, 0; ...
            dx, dy, 0; ...
            0, 0, dz; ...
            dx, 0, dz; ...
            0, dy, dz; ...
            dx, dy, dz];
% u_dot = [m]/MPa, u_dot_real = [m]/[s]
% mumag*1e6 converts the meters to micrometers in the units.
% The experimental displacement rate is 5 nm = 5e-3 micrometers.
% The cantilever is dx micrometers long.
timeUnit = 5e-3*(mumag*1e6)/dx;
u_dot = dx/timeUnit;
sign_u_dot = 1;
loading = @displacementControlMicropillarTensile;
simType = @micropillarTensile;

run fccLoops
xmin = 0.70*dx;
xmax = 0.85*dx;
ymin = 0.15*dy;
ymax = 0.85*dy;
zmin = 0.15*dz;
zmax = 0.85*dz;
distRange = [xmin ymin zmin; xmax ymax zmax];
displacement = distRange(1, :) + (distRange(2, :) - distRange(1, :)) .* rand(1, 3);

segLen = 1/amag;
links = [prismLinks(1:8, :) prismbVec(1:8, :) prismSlipPlane(1:8, :)];
displacedCoord = prismCoord(1:8, :)*segLen + displacement;

rn = [displacedCoord [0;7;0;7;0;7;0;7]];
plotnodes(rn,links,dx,vertices);
dt0 = 1e9;
totalSimTime = 1e12;
mobility = @mobfcc0;
saveFreq = 1e9;
plotFreq = 5;

plotFlags = struct('nodes', true, 'secondary', true);
