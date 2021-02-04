function [vn, fn] = mobfcc0(fseg, rn, links, connectivity, nodelist, conlist, Bcoeff, rotMatrix)
%mobility law function (model: FCC0)

%Drag (Mobility) parameters (should be specified by Input file)
Bscrew = Bcoeff.screw;
Bedge = Bcoeff.edge;
Bclimb = Bcoeff.climb;
Bline = Bcoeff.line;
%     global Beclimb Bedge Bscrew Bline;
%     Bclimb = Beclimb;

rotateCoords = false;

if ~isempty(rotMatrix)
    rotateCoords = true;
    rn(:, 1:3) = rn(:, 1:3) * rotMatrix;
    fseg(:, 1:3) = fseg(:, 1:3) * rotMatrix;
    fseg(:, 4:6) = fseg(:, 4:6) * rotMatrix;
    links(:, 3:5) = links(:, 3:5) * rotMatrix;
    links(:, 6:8) = links(:, 6:8) * rotMatrix;
end

%numerical tolerance
eps = 1e-10;

% length of the nodelist for which the velocity will be calculated
L1 = size(nodelist, 1);
% if no nodelist is given then the nodelist becomes the whole node population
% this portion of the code sets up that nodelist along with the connlist
% that contains all of the nodal connections
if L1 == 0
    L1 = size(rn, 1);
    nodelist = linspace(1, L1, L1)';
    [L2, L3] = size(connectivity);
    conlist = zeros(L2, (L3 - 1) / 2 + 1);
    conlist(:, 1) = connectivity(:, 1);
    
    for i = 1:L2
        connumb = conlist(i, 1);
        conlist(i, 2:connumb + 1) = linspace(1, connumb, connumb);
    end
    
end

% now cycle through all of the nodes for which the velocity must be calculated
vn = zeros(L1, 3);
fn = zeros(L1, 3);

for n = 1:L1
    n0 = nodelist(n); %n0 is the nodeid of the nth node in nodelist
    numNbrs = conlist(n, 1); %numNbrs is the number of connections for node n0 in conlist
    fn(n, :) = zeros(1, 3); % initialize the total force and the total drag matrix
    Btotal = zeros(3, 3);
    
    for i = 1:numNbrs
        ii = conlist(n, i + 1); % connectionid for this connection
        linkid = connectivity(n0, 2 * ii);
        posinlink = connectivity(n0, 2 * ii + 1);
        n1 = links(linkid, 3 - posinlink);
        rt = rn(n1, 1:3) - rn(n0, 1:3); % calculate the length of the link and its tangent line direction
        L = norm(rt);
        
        if L > 0.0
            fsegn0 = fseg(linkid, 3 * (posinlink - 1) + [1:3]);
            fn(n, :) = fn(n, :) + fsegn0; % nodeid for the node that n0 is connected to
            burgv = links(connectivity(n0, 2 * ii), 3:5); % burgers vector of the link
            linedir = rt ./ L;
            nplane = links(linkid, 6:8);
            nmag = norm(nplane);
            
            if nmag < eps
                % the normal plane is not defined try to define the normal plane
                Btotal = Btotal + (2.0 * L) .* ((Bclimb) .* eye(3) + (Bline - Bclimb) .* (linedir' * linedir));
            else
                nplane = nplane ./ nmag;
                % if abs(abs(nplane(1)*nplane(2))+abs(nplane(2)*nplane(3))+abs(nplane(1)*nplane(3))-1)>0.1 % this can be the first condition that checks for good glide planes
                if abs(nplane(1) * nplane(2) * nplane(3)) < 0.01% this is a second condition that checks for good glide planes
                    % this is a special glide plane that is not of 111 type signifying a junction dislocation
                    Btotal = Btotal + (0.5 * L) .* ((Bclimb) .* eye(3) + (Bline - Bclimb) .* (linedir' * linedir));
                else
                    cth2 = (linedir * burgv')^2 / (burgv * burgv'); % calculate how close to screw the link is
                    mdir = cross(nplane, linedir);
                    Bglide = 1 / sqrt(1 / Bedge^2 + (1 / Bscrew^2 - 1 / Bedge^2) * cth2);
                    Btotal = Btotal + (0.5 * L) .* ((Bglide) .* (mdir' * mdir) + (Bclimb) .* (nplane' * nplane) +(Bline) .* (linedir' * linedir));
                end
                
            end
            
        end
        
    end
    
    %     if rcond(Btotal) < eps
    %
    %         [evec, eval] = eig(Btotal); % find eigenvalues and eigen vectors of drag matrix
    %         evalmax = eval(1, 1);
    %         eval = eval ./ evalmax;
    %         fvec = fn(n, :)' ./ evalmax;
    %
    %         for i = 2:3% invert drag matrix and keep zero eigen values as zero
    %
    %             if eval(i, i) > eps
    %                 eval(i, i) = 1 / eval(i, i);
    %             else
    %                 eval(i, i) = 0.0d0;
    %             end
    %
    %         end
    %
    %         velocity = (evec * eval * evec' * fvec)';
    %
    %         if any(isnan(velocity))
    %             disp('NaN velocity');
    %             pause
    %         end
    %
    %         vn(n, :) = velocity; % calculate the velocity
    %     else
    %         velocity = (Btotal \ fn(n, :)')';
    %
    %         if any(isnan(velocity))
    %             disp('NaN velocity');
    %             pause
    %         end
    %
    %         vn(n, :) = velocity; % Btotal was wellconditioned so just take the inverse
    %     end
    
    if norm(Btotal) < eps%if there is no drag on the node, make its velocity zero
        vn(n, :) = [0 0 0];
    elseif rcond(Btotal) < 1e-15%if the drag tensor is poorly conditioned use special inversion protocol
        Btotal_temp = Btotal + 1e-6 * max(max(abs(Btotal))) * eye(3); % perturb drag tensor
        Btotal_temp2 = Btotal - 1e-6 * max(max(abs(Btotal))) * eye(3);
        vn_temp = (Btotal_temp \ fn(n, :)')'; % estimate velocity using perturbations
        vn_temp2 = (Btotal_temp2 \ fn(n, :)')';
        vn(n, :) = 0.5 * (vn_temp + vn_temp2); % use mean of estimated velocities
    else
        vn(n, :) = (Btotal \ fn(n, :)')'; % Btotal was well conditioned so just take the inverse
    end
    
    if any(any(isnan(vn))) || any(any(~isreal(vn)))% ensure no non-physical velocities exist
        disp('YDFUS, see line 142 of mobfcc0')
    end
end

if rotateCoords
    vn = vn * rotMatrix';
    fn = fn * rotMatrix';
end
end
