function sigma = hatStress(uhat, nc, x, D, mx, mz, w, h, d, x0)

    % returns stress tensor at a point x=x0 by constructing B matrix B(x)
    % notes with mx=90 dx=6,dy=dz=1, agrees with S(1:5) agree with Abaqus to 1%
    % S(6) is approx zero so the error is huge!

    i = ceil(x0(1) / w);
    i = max(i, 1);
    j = ceil(x0(2) / h);
    j = max(j, 1);
    k = ceil(x0(3) / d);
    k = max(k, 1);
    p = i + (k - 1) * mx + (j - 1) * mx * mz;

    if any(x0 < 0) || p > mx * mz * mz || isnan(p)
        % Sort of have to do this when using int_trapezium.m because real
        % segment will move out of domain during trial before it can be
        % remeshed?
        % fprintf('Node outside domain! See hatStress.m\n')
        sigma = zeros(3); % do something better like remeshing later...
        return
    end

    % 4. ----- .3
    %  �\       �\
    %  � \      � \
    % 1. -\---- .2 \
    %   \  \     \  \
    %    \ 8. ----\- .7
    %     \ �      \ �
    %      \�       \�
    %      5. ----- .6

    %  s2   s3
    %    \  ^
    %     \ �
    %      \�
    %       . -----> s1
    % redefine local corordinate system (s1,s2,s3) to have same orientation as
    % the global system (x,y,z) this should save calcualting Jij and inv(J)
    xc = zeros(3, 1);

    for i = 1:3
        xc(i) = 0.5 * (x(nc(p, 1), i) + x(nc(p, 7), i)); %xc is center of element p
    end

    a = w / 2; % element dx
    b = h / 2; % element dy
    c = d / 2; % element dz

    s1 = (x0(1) - xc(1)) / a;
    s2 = (x0(2) - xc(2)) / b;
    s3 = (x0(3) - xc(3)) / c;

    ds1dx = 1 / a;
    ds2dy = 1 / b;
    ds3dz = 1 / c;

    B = zeros(6, 24);
    dNds1 = zeros(8, 1);
    dNds2 = zeros(8, 1);
    dNds3 = zeros(8, 1);

    pm1 = [-1 1 1 -1 -1 1 1 -1];
    pm2 = [1 1 1 1 -1 -1 -1 -1];
    pm3 = [-1 -1 1 1 -1 -1 1 1];
    %eg shape function a: Na = 1/8*(1+pm1(a)*s1)(1+pm2(a)*s2)(1+pm3(a)*s3)
    % dNa/ds1 = 1/8* pm1(a)*(1+pm2(a)*s2)(1+pm3(a)*s3)
    % dNa/dx = (dNa/ds1)(ds1/dx) where ds1/dx = 1/a
    % dN1/dx = 1/a(dNa/ds1) = -b*c*(1+s2)(1-s3)/(abc)
    % The explicit derivatives as found in finiteElement3D work, so do the
    % pms found there.
    % I think the signs used here are wrong. They do not give the same
    % explicit expressions as doing the explicit  derivatives of the shape
    % functions. I don't know why they are used here. The correct ones are
    % these:
%     pm1 = [-1 1 1 -1 -1 1 1 -1];
%     pm2 = [-1 -1 1 1 -1 -1 1 1];
%     pm3 = [-1 -1 -1 -1 1 1 1 1];
    % This function uses pm2 for pm3, and -pm3 for pm2, i don't know why.
    % dNds1(1) = -1/8 * (1 - s2) * (1 - s3);
    % dNds2(1) = -1/8 * (1 - s1) * (1 - s3);
    % dNds3(1) = -1/8 * (1 - s1) * (1 - s2);

    % dNds1(2) = 1/8 * (1 - s2) * (1 - s3);
    % dNds2(2) = -1/8 * (1 + s1) * (1 - s3);
    % dNds3(2) = -1/8 * (1 + s1) * (1 - s2);

    % dNds1(3) = 1/8 * (1 + s2) * (1 - s3);
    % dNds2(3) = 1/8 * (1 + s1) * (1 - s3);
    % dNds3(3) = -1/8 * (1 + s1) * (1 + s2);

    % dNds1(4) = -1/8 * (1 + s2) * (1 - s3);
    % dNds2(4) = 1/8 * (1 - s1) * (1 - s3);
    % dNds3(4) = -1/8 * (1 - s1) * (1 + s2);

    % dNds1(5) = -1/8 * (1 - s2) * (1 + s3);
    % dNds2(5) = -1/8 * (1 - s1) * (1 + s3);
    % dNds3(5) = 1/8 * (1 - s1) * (1 - s2);

    % dNds1(6) = 1/8 * (1 - s2) * (1 + s3);
    % dNds2(6) = -1/8 * (1 + s1) * (1 + s3);
    % dNds3(6) = 1/8 * (1 + s1) * (1 - s2);

    % dNds1(7) = 1/8 * (1 + s2) * (1 + s3);
    % dNds2(7) = 1/8 * (1 + s1) * (1 + s3);
    % dNds3(7) = 1/8 * (1 + s1) * (1 + s2);

    % dNds1(8) = -1/8 * (1 + s2) * (1 + s3);
    % dNds2(8) = 1/8 * (1 - s1) * (1 + s3);
    % dNds3(8) = 1/8 * (1 - s1) * (1 + s2);
    %%

    for a = 1:8
        dNds1(a) = 1/8 * pm1(a) * (1 + pm2(a) * s2) * (1 + pm3(a) * s3);
        dNds2(a) = 1/8 * (1 + pm1(a) * s1) * pm2(a) * (1 + pm3(a) * s3);
        dNds3(a) = 1/8 * (1 + pm1(a) * s1) * (1 + pm2(a) * s2) * pm3(a);

        B(1, 3 * (a - 1) + 1) = dNds1(a) * ds1dx;
        B(2, 3 * (a - 1) + 2) = dNds2(a) * ds2dy;
        B(3, 3 * (a - 1) + 3) = dNds3(a) * ds3dz;

        B(4, 3 * (a - 1) + 1) = B(2, 3 * (a - 1) + 2);
        B(4, 3 * (a - 1) + 2) = B(1, 3 * (a - 1) + 1);

        B(5, 3 * (a - 1) + 1) = B(3, 3 * a);
        B(5, 3 * a) = B(1, 3 * (a - 1) + 1);

        B(6, 3 * (a - 1) + 2) = B(3, 3 * a);
        B(6, 3 * a) = B(2, 3 * (a - 1) + 2);
    end

    %
    %----------------------------------------------------------------------
    U = zeros(24, 1);

    for a = 1:8
        U(3 * a - 2) = uhat(3 * nc(p, a) - 2);
        U(3 * a - 1) = uhat(3 * nc(p, a) - 1);
        U(3 * a) = uhat(3 * nc(p, a));
    end

    sigmaA = D * (B * U); %

    sigma = zeros(3);
    sigma(1, 1) = sigmaA(1); %11
    sigma(2, 2) = sigmaA(2); %22
    sigma(3, 3) = sigmaA(3); % 33
    sigma(1, 2) = sigmaA(4); % 12
    sigma(1, 3) = sigmaA(5); % 13
    sigma(2, 3) = sigmaA(6); % 23
    sigma(2, 1) = sigma(1, 2);
    sigma(3, 1) = sigma(1, 3);
    sigma(3, 2) = sigma(2, 3);

end
