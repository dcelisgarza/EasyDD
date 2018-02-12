function [rn,links] = bccsourcegen(NUM_SOURCES,DIST_SOURCE,dx,dy,dz)

slipsys=[1, 1, 0, -1,  1,  1;
         1, 1, 0,  1, -1,  1;
        -1, 1, 0,  1,  1,  1;
        -1, 1, 0,  1,  1, -1;
         1, 0, 1,  1,  1, -1;
         1, 0, 1, -1,  1,  1;
        -1, 0, 1,  1,  1,  1;
        -1, 0, 1,  1,  1, -1;
         0, 1, 1,  1, -1,  1;
         0, 1, 1,  1,  1, -1;
         0,-1, 1,  1,  1,  1;
         0,-1, 1, -1,  1,  1];
     
bufferfactor = 1.5;
%NB Sources are idealised as squares...
Xmin = 0+bufferfactor*DIST_SOURCE+0.5*dy;
Xmax = dx*0.75-bufferfactor*DIST_SOURCE;
Ymin = 0+bufferfactor*DIST_SOURCE;
Ymax = dy-bufferfactor*DIST_SOURCE;
Zmin = 0+bufferfactor*DIST_SOURCE;
Zmax = dz-bufferfactor*DIST_SOURCE;

rn = zeros(size(slipsys,1)*8*NUM_SOURCES,4);
links = zeros(size(slipsys,1)*8*NUM_SOURCES,8);

for i=1:size(slipsys,1)
    normal=slipsys(i,1:3);
    fedge=normal/norm(normal);
    screw=slipsys(1,4:6);
    screw=screw/norm(screw);
    edge=cross(screw,fedge);
    edge=edge/norm(edge);
    b_vec=slipsys(1,4:6);
    b_vec=b_vec/norm(b_vec);
    mobvec=DIST_SOURCE*edge;
    fixvec=DIST_SOURCE*fedge;
    %Generate midpoints of sources
    midX = Xmin + (Xmax - Xmin).*rand(NUM_SOURCES,1);
    midY = Ymin + (Ymax - Ymin).*rand(NUM_SOURCES,1);
    midZ = Zmin + (Zmax - Zmin).*rand(NUM_SOURCES,1);
    midPTS = horzcat(midX,midY,midZ);
    
    for p=1:NUM_SOURCES
        
        r1=midPTS(p,:)-mobvec-fixvec;
        r2=r1+mobvec;
        r3=r2+mobvec;
        r4=r3+fixvec;
        r5=r4+fixvec;
        r6=r5-mobvec;
        r7=r6-mobvec;
        r8=r7-fixvec;
        
        rn((i-1)*NUM_SOURCES*8+(p-1)*8+1,:)=[r1,7];
        rn((i-1)*NUM_SOURCES*8+(p-1)*8+2,:)=[r2,0];
        rn((i-1)*NUM_SOURCES*8+(p-1)*8+3,:)=[r3,7];
        rn((i-1)*NUM_SOURCES*8+(p-1)*8+4,:)=[r4,7];
        rn((i-1)*NUM_SOURCES*8+(p-1)*8+5,:)=[r5,7];
        rn((i-1)*NUM_SOURCES*8+(p-1)*8+6,:)=[r6,0];
        rn((i-1)*NUM_SOURCES*8+(p-1)*8+7,:)=[r7,7];
        rn((i-1)*NUM_SOURCES*8+(p-1)*8+8,:)=[r8,7];
        
        for m = 1:7
            links((i-1)*NUM_SOURCES*8+(p-1)*8+m,1:2) = [(i-1)*NUM_SOURCES*8+(p-1)*8+m, (i-1)*NUM_SOURCES*8+(p-1)*8+(m+1)];
        end
        links((i-1)*NUM_SOURCES*8+(p-1)*8+8,1:2) = [(i-1)*NUM_SOURCES*8+(p-1)*8+8,(i-1)*NUM_SOURCES*8+(p-1)*8+1];
    
        links(((i-1)*NUM_SOURCES*8+(p-1)*8+1):((i-1)*NUM_SOURCES*8+(p-1)*8+8),3:5) = repmat(b_vec,8,1);
        links(((i-1)*NUM_SOURCES*8+(p-1)*8+1):((i-1)*NUM_SOURCES*8+(p-1)*8+8),6:8) = repmat(normal,8,1);
        
    end


end
 
end