function [K, L, U, P_l, P_u, Sleft, Sright, Stop, Sbot, Sfront, Sback, Smixed, gammat, gammau,...
    gammaMixed, fixedDofs, freeDofs, processForceDisp, plotForceDisp] = micropillarTensile(kg, ~, ~, ~, mno, ~, ~, ~, S)


Sleft = [S.left; S.topleft; S.botleft; S.frontleft; S.backleft; S.corners([1,3,5,7],:)];
Sright = [S.right; S.topright; S.botright; S.frontright; S.backright];
Stop = [S.top; S.topfront; S.topback];
Sbot = [S.bot; S.botfront; S.botback];
Sfront = [S.front];
Sback = [S.back];

gammau = [Sleft; S.corners([1,3,5,7],:)];
gammaMixed = [S.corners([2,4,6,8], :)];
[~, gammatIdx] = setdiff(S.cat(:,1),[gammau(:,1); gammaMixed(:,1)]);
gammat = S.cat(gammatIdx, :);

Smixed = gammaMixed;

fixedDofs = [
    3*S.left(:,1) - 2;
    3*S.botleft(:,1) - 2;
    3*S.topleft(:,1) - 2;
    3*S.frontleft(:,1) - 2;
    3*S.backleft(:,1) - 2;
    3*S.corners([1,3,5,7], 1) - 2;
    %
    3*S.backleft(:,1) - 1;
    3*S.corners([3,7], 1) - 1;
    %
    3*S.botleft(:,1);
    3*S.corners([1,3], 1);
    %
    3*S.corners([2,4,6,8], 1) - 2
];


% fixedDofs = [3*gammau(:, 1) - 2; 3*gammau(:, 1) - 1; 3*gammau(:, 1); 3*gammaMixed(:,1) - 2];
freeDofs = setdiff([1:3*mno], fixedDofs);

K = kg(freeDofs, freeDofs);

try
    fprintf('Cholesky Factorization of K...\n'); %should be symmetric!
    % Special algorithm for sparse matrices
    % [R, flag, P] = chol(S)
    % R'*R = P'*S*P -> P*R'*R*P' = S
    tic;
        [U, ~, P_u] = chol(K);
        L = U';
        P_l = P_u';
    toc
catch
    sprintf('Ran out of memory in cholesky factorisation, use explicit K.\n')
    U = [];
    L = [];
    P_u = [];
    P_l = [];
end

processForceDisp = @micropillarTensileForceDisp;
plotForceDisp = @cantileverBendingPlot;
end