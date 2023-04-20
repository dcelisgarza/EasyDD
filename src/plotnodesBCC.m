function [output]=plotnodesBCC(rn,links,plim,vertices,Ubar)
%HY20180414
% global burgsref planesref burgnumbers planenumbers;

%plot nodes
%only those nodes within [-plim,plim] in x,y,z directions are plotted
% figure(1);
% clf
%amag = 3.18e-4; %lattice vector BCC W, in microns

global rotationBCC

count =0;
amag=1;
plot3(0,0,0); hold on;
LINKMAX=length(links(:,1));
for i=1:LINKMAX
    n0=links(i,1);
    n1=links(i,2);
    %to skip external nodes...
    
    
    %     if rn(n0,end)==0||rn(n0,end)==7||rn(n0,end)==6
    %         continue;
    %     end
    %
    %     if rn(n1,end)==0||rn(n1,end)==7||rn(n1,end)==6
    %         continue;
    %     end
    
    
    if rn(n0,end)==67||rn(n1,end)==67
        continue;
    end
    if rn(n0,end)==6||rn(n1,end)==6
        continue;
    end
    if rn(n0,end)==7||rn(n1,end)==8
        continue;
    end
    
    lvec = amag*(rn(n1,1:3)-rn(n0,1:3));
    plane_n = links(i,6:8);
    bvec = links(i,3:5);
    %     plane_n = cross(lvec/norm(lvec),bvec/norm(bvec));
    
    %11-1
    normals = 1/sqrt(2)*[1 -1 0;
        1 0 -1;
        0 1 -1]*rotationBCC;
    
    b_vecs = 1/2*[1 1 1;
        1 1 -1;
        1 -1 1;
        -1 1 1]*rotationBCC;
    
    color = 'r';
    linewidth = 2;
    if sum(abs(plane_n-normals(1,:)))/3<1E-2|sum(abs(plane_n+normals(1,:)))/3<1E-2
        color = 'b';
    elseif sum(abs(plane_n-normals(2,:)))/3<1E-2|sum(abs(plane_n+normals(2,:)))/3<1E-2
        color = 'g';
    elseif sum(abs(plane_n-normals(3,:)))/3<1E-2|sum(abs(plane_n+normals(3,:)))/3<1E-2
        color ='k';
    end
    
    color = 'k';
    %     if abs(norm(bvec)-1)<1E-2
    %         color = 'r';
    %     end
    
        color = 'k';
        linewidth = 2;
        if sum(abs(bvec-b_vecs(1,:)))/3<1E-2|sum(abs(bvec+b_vecs(1,:)))/3<1E-2
            color = 'b';
        elseif sum(abs(bvec-b_vecs(2,:)))/3<1E-2|sum(abs(bvec+b_vecs(2,:)))/3<1E-2
            color = 'g';
        elseif sum(abs(bvec-b_vecs(3,:)))/3<1E-2|sum(abs(bvec+b_vecs(3,:)))/3<1E-2
            color ='m';
        elseif abs(norm(bvec)-sqrt(3)/2)>1E-2
            color = 'r';
            linewidth = 3;
        end
    
    %     if color=='m'
    %         count = count+1
    %         bvec
    %         plane_n
    %     end
    %     color = 'b';
    %     dline = norm(lvec);
    %     linedir=lvec./dline;
    %     costh2=(linedir*bvec')^2/(bvec*bvec');
    %     sinth2 = 1-costh2;
    %
    %     column = 1;
    %     if sinth2 < 0.0076%HY20180503: +-5 degrees
    %         color = 'r';%HY20180501: calculate the density of pure screw components
    %     end
    
    %     if plane_n == [-1 0 1]/sqrt(2)
    r0 = rn(n0,1:3)*amag;
    %      if rn(n0,4)==0
    %filter out "infinity" lines
    %        plot3(rn([n0,n1],1)*amag,rn([n0,n1],2)*amag,rn([n0,n1],3)*amag,'k-','LineWidth',2);
    plot3(rn([n0,n1],1)*amag,rn([n0,n1],2)*amag,rn([n0,n1],3)*amag,color,'LineWidth',linewidth);
    %             quiver3(r0(1),r0(2),r0(3),lvec(1),lvec(2),lvec(3),color,'LineWidth',4);
    
    
    %     plot3(rn(n0,1)*amag,rn(n0,2)*amag,rn(n0,3)*amag,'ko');
    %     if rn(n0,end) == 7
    % %     if n0 == 188 || n0 == 456
    %         plot3(rn(n0,1)*amag,rn(n0,2)*amag,rn(n0,3)*amag,'ro');
    %     end
    %     if rn(n0,end) == 6
    % %     if n0 == 188 || n0 == 456
    %         plot3(rn(n0,1)*amag,rn(n0,2)*amag,rn(n0,3)*amag,'bo');
    %     end
    
    %     if rn(n1,end) == 6
    % %     if n0 == 188 || n0 == 456
    %         plot3(rn(n1,1)*amag,rn(n1,2)*amag,rn(n1,3)*amag,'bo');
    %     end
    
    
    %     plot3(rn(n0,1)*amag,rn(n0,2)*amag,rn(n0,3)*amag,'ko');
    %      end
    
end

% plot film film location
% dt = delaunayTriangulation(vertices*bmag);
% dt = delaunayTri(vertices);
% [tri, Xb] = freeBoundary(dt);
% trisurf(tri, Xb(:,1), Xb(:,2), Xb(:,3), 'FaceColor', 'white','FaceAlpha', 0.1);
% plot bounding box

face1=[1 2 4 3 1];
face2=[5 6 8 7 5];
vertices_scaled=vertices*amag;
surf1=vertices_scaled(face1,:);
surf2=vertices_scaled(face2,:);

plot3(surf1(:,1),surf1(:,2),surf1(:,3),'k','LineWidth',2);
hold on;
plot3(surf2(:,1),surf2(:,2),surf2(:,3),'k','LineWidth',2);

side = vertices_scaled([1 5],:);
plot3(side(:,1),side(:,2),side(:,3),'k','LineWidth',2);
side = vertices_scaled([2 6],:);
plot3(side(:,1),side(:,2),side(:,3),'k','LineWidth',2);
side = vertices_scaled([3 7],:);
plot3(side(:,1),side(:,2),side(:,3),'k','LineWidth',2);
side = vertices_scaled([4 8],:);
plot3(side(:,1),side(:,2),side(:,3),'k','LineWidth',2);







% plot virtual segments
% if isempty(virtual_seg)
%     %do nothing
% else
% for j=1:size(virtual_seg,1)% (node_ID_int, node_ID_inf, bx,by,bz,x_int,y_int,z_int,x_inf,y_inf,z_inf,nx,ny,nz)
% plot3([virtual_seg(j,6) virtual_seg(j,9)] , [virtual_seg(j,7) virtual_seg(j,10)], [virtual_seg(j,8) virtual_seg(j,11)],'k--');
% end

plotHandle=gcf;
hold off
axis equal
% grid
xlabel('x / \mu m','FontSize',10);
ylabel('y / \mu m','FontSize',10);
zlabel('z / \mu m','FontSize',10);
%
% %  xlim([0 vertices(2,1)]*amag);
% %  ylim([0 vertices(3,2)]*amag);
% %  zlim([0 vertices(5,3)]*amag);
%
% %  xlim([0 0.3*vertices(2,1)]*amag);
%  xlim([0 1*vertices(2,1)]*amag);
%  ylim([0 vertices(3,2)]*amag);
%  zlim([0 vertices(5,3)]*amag);

%axis equal;
output=plotHandle;
