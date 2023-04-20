f21 = figure(211);
clf
plotnodesBCC([rn(:,1:3)*amag,rn(:,4)],links,plim*amag,vertices*amag,Ubar*amag);
hold on
radius = Rcontact*amag;
center = [dx/2,dy/2,dz]*amag;
theta=0:0.01:2*pi;
v=null([0 0 1]);
points=repmat(center',1,size(theta,2))+radius*(v(:,1)*cos(theta)+v(:,2)*sin(theta));
axis equal
xlim([0.3*vertices(3,2) 0.7*vertices(3,2)]*amag);
ylim([0.3*vertices(3,2) 0.7*vertices(3,2)]*amag);
zlim([0.6*vertices(5,3) 1.0*vertices(5,3)]*amag);
% xlim([0 vertices(2,1)]*amag);
% ylim([0 vertices(3,2)]*amag);
% zlim([0 vertices(5,3)]*amag);
ax = gca;
ax.FontSize = 20
viewangle = [-75 25];
view(viewangle);
% view(2)
drawnow
% hold off

set(f21,'Units','Inches');
pos = get(f21,'Position');
set(f21,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print('dislocations unload.pdf','-dpdf','-r600')



f22 = figure(212);
plot(U_mesh(1:curstep)*amag*1000,Fend(1:curstep)*amag^2*mumag,'k','LineWidth',3)
hold on
% Fanalyticright = 4/3*2*MU/(1-NU).*sqrt(1000/1000/amag.*U_bar(1:curstep).^3);
hold on
% plot(U_bar(1:curstep)*amag,Fanalyticright*amag^2*mumag,'b--','LineWidth',3)
hold off
xlabel('Indentation depth (nm)');
ylabel('Reaction force (\muN)');
xlim([0 23])
ylim([0 650])

% axis equal;
ax = gca;
ax.FontSize = 20;
% set(gca, 'XDir','reverse')
% set(gca,'visible','off')


set(f22,'Units','Inches');
pos = get(f22,'Position');
set(f22,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print('dislocations unload full.pdf','-dpdf','-r600')
% 
% figure(5);
% hold on
% plot(U_mesh(1:10:curstep)*amag,DisDensity(1:10:curstep,1)+DisDensity(1:10:curstep,2),'b-','LineWidth',3)
% xlabel('Displacement (\mum)');
% ylabel('multiple density (10^{12}m^{-2})');
% 
% figure(6);
% hold on
% plot(U_mesh(1:10:curstep)*amag,DisDensity(1:10:curstep,2),'b-','LineWidth',3)
% xlabel('Displacement (\mum)');
% ylabel('multiple density (10^{12}m^{-2})');
% 
