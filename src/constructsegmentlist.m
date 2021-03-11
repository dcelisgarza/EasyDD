function [segments, index] = constructsegmentlist(rn, links, novirtsegs)

    [LINKMAX, ~] = size(links);

    segments = zeros(LINKMAX, 14);
    index = false(LINKMAX, 1);
    nseg = 0;

    for i = 1:LINKMAX
        n0 = links(i, 1);
        n1 = links(i, 2);

        if ((n0 ~= 0) && (n1 ~= 0))
            
            rn0 = rn(n0, :);
            rn1 = rn(n1, :);
            tVec = rn0(1:3) - rn1(1:3);
            
            if novirtsegs == true && (rn0(end) == 67 || rn1(end) == 67) || dot(tVec, tVec) < eps
                continue
            end

            nseg = nseg + 1;
            segments(nseg, :) = [links(i, 1:5), rn0(1:3), rn1(1:3), links(i, 6:8)];
            index(i) = true;
        end

    end

    segments = segments(1:nseg, :);
end
