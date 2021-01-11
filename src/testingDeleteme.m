
dx = 1009;
dy = 1013;
dz = 1019;
mx = 11;
my = 13;
mz = 17;
mu = 1;
nu = 0.28;
[vertices, B, xnodes, mno, nc, n, D, kg, w, h, d, mx, my, mz, mel] = finiteElement3D(dx, dy, dz, mx, my, mz, mu, nu);

idx = [
        9   3
        9  18
        6   5
        5  20
        10  9
    ];
xnodes(idx(1,:), :)
idxCon = [6,8,3,1,5];
idxNode = [1703,2430,592,1732,976];
nc(idxNode, idxCon)


idxK = [3435, 3400;
 1108, 1069;
 8973, 9009;
 3019, 3664;
 6670, 6706;
 5488, 4840;
 675, 29;
 1042, 357;
 5710, 5096;
 1918, 1275;
];

kg(idxK(:,1), idxK(:,2));

%%

dx = 2000;
dy = 2000;
dz = 2000;
mx = 5;
my = 5;
mz = 5;
mu = 1;
nu = 0.28;
[vertices, B, xnodes, mno, nc, n, D, kg, w, h, d, mx, my, mz, mel] = finiteElement3D(dx, dy, dz, mx, my, mz, mu, nu);

uhat = zeros(3*mno, 1);
tic;
uhat([91;126;130;195;217;226;229;256;281;293;309;342], 1) = 1000*[0.5231621885339968, 0.5771429489788034, 0.7151190318538345, 0.7283662326812077, 0.6314274719472075, 0.9814688915693632, 0.5672795171250207, 0.002712918060655989, 0.1788941754890383, 0.188299784057536, 0.8489027048214433, 0.029995302953659708];
hatStress(uhat, nc, xnodes, D, mx, mz, w, h, d, [1575.,985.,1341.])
toc;

hatStress(uhat, nc, xnodes, D, mx, mz, w, h, d, [1893.0, 408.0, 1782.0])