
% requires frameInfo -> Detection 3D from CME analysis
% requires box information -> MultiTemplate match Fiji

clearvars -except frameInfo box

D = 15; %pixels measured in FIJI line profile
R = D/2*0.14;
name = 'crop2_ex11_bound2_rebuttal.';
z0 = 22;
zf = 32;

z_npc1 = 28;

for t = 1:149
    
x0 = box(t,2);
y0 = box(t,3);

xf = box(t,2) + box(t,4);
yf = box(t,3) + box(t,5);

x1 = frameInfo(t).x;
y1 = frameInfo(t).y;
z1 = frameInfo(t).z;

l1 = find(x1 > x0);
l2 = find(x1 < xf);
l3 = find(y1 > y0);
l4 = find(y1 < yf);
l5 = find(z1 > z0);
l6 = find(z1 < zf);


lfinal = intersect(l1,l2);
lfinal = intersect(lfinal,l3);
lfinal = intersect(lfinal,l4);
lfinal = intersect(lfinal,l5);
lfinal = intersect(lfinal,l6);

test(t).ids = lfinal;

end


%%
for t=1:numel(test)
    
    if numel(test(t).ids) > 0
    
   max_ids(t) = max(frameInfo(t).A(test(t).ids)); 
   id_final(t) = find(frameInfo(t).A == max(frameInfo(t).A(test(t).ids)));
   
    else
        
        max_ids(t) = 0; 
        id_final(t) = 0;
    end 
   
end

hold off
plot(max_ids)

for t=1:numel(test)
    
    if id_final(t) > 0
           
    real_track(1).x(t) = frameInfo(t).x(id_final(t));  
    real_track(1).y(t) = frameInfo(t).y(id_final(t));  
    real_track(1).z(t) = frameInfo(t).z(id_final(t));  
    real_track(1).A(t) = frameInfo(t).A(id_final(t));     
    
    end
end


find_0 = find(id_final == 0);

for i=1:numel(find_0)
    
    real_track(1).x(find_0(i)) = (real_track(1).x(find_0(i)-1) + real_track(1).x(find_0(i)+1))*0.5;  
    real_track(1).y(find_0(i)) = (real_track(1).y(find_0(i)-1) + real_track(1).y(find_0(i)+1))*0.5;
    real_track(1).z(find_0(i)) = (real_track(1).z(find_0(i)-1) + real_track(1).z(find_0(i)+1))*0.5; 
    real_track(1).A(find_0(i)) = (real_track(1).A(find_0(i)-1) + real_track(1).A(find_0(i)+1))*0.5;    
    
end

hold off
time = uint32(1):uint32(149);
plot(real_track(1).A)

%%
hold off
scatter3(0.145*real_track(1).x, 0.145*real_track(1).y, 0.25*real_track(1).z, 40, time, 'filled')
colormap(jet)
colorbar
hold on
plot3(0.145*real_track(1).x, 0.145*real_track(1).y, 0.25*real_track(1).z, 'k')

%%
v1 = [];
npc1 = [];

for i=1:numel(real_track(1).x)
    
    npc1(1,i) = box(i,2) + box(i,4)/2;
    npc1(2,i) = box(i,3) + box(i,5)/2;
    npc1(3,i) = z_npc1;
end


for i=1:numel(real_track(1).x)
    v1(1,i) = real_track(1).x(i) - npc1(1,i);
    v1(2,i) = real_track(1).y(i) - npc1(2,i);
    v1(3,i) = real_track(1).z(i) - npc1(3,i);
end


v1_summary(:,1) =  real_track(1).x';
v1_summary(:,2) =  real_track(1).y';
v1_summary(:,3) =  real_track(1).z';
v1_summary(:,4) =  real_track(1).A';

v1_summary(:,5) =  npc1(1,:)';
v1_summary(:,6) =  npc1(2,:)';
v1_summary(:,7) =  npc1(3,:)';

v1_summary(:,8) =  v1(1,:)';
v1_summary(:,9) =  v1(2,:)';
v1_summary(:,10) =  v1(3,:)';

save(append(name, 'mat'),'v1_summary');

hold off
%f = figure('Units', 'pixels', 'Position', [100, 100, 1600, 1200]);
scatter3(0.145*v1_summary(:,8), 0.145*v1_summary(:,9), 0.25*v1_summary(:,10), 100, 4*time, 'filled')
colormap(jet)
%colorbar
hold on
plot3(0.145*v1_summary(:,8), 0.145*v1_summary(:,9), 0.25*v1_summary(:,10), 'Color', [0 0 0], 'linewidth', 0.5)
set(gca, 'LineWidth', 1, 'GridColor', [0 0 0]);
set(gcf, 'Renderer', 'OpenGL');
set(gca, 'SortMethod', 'childorder');
set(gca, 'fontsize', 26);
xlabel('x (\mum)','interpreter','Tex')
ylabel('y (\mum)','interpreter','Tex')
zlabel('z (\mum)','interpreter','Tex')


xlim([-1.9 1.9])
ylim([-1.9 1.9])
zlim([-1.9 1.9]) 
zticks([-1 0 1])
%zticklabels({'-2', '-1','0','1','2'})

[Xs, Ys, Zs] = sphere(30);
surf(R*Xs, R*Ys, R*Zs, 'FaceAlpha', 0.05, 'EdgeColor', 'none');
axis equal;

%surf(R*Xs, R*Ys, R*Zs, 'FaceAlpha', 0.05, 'EdgeColor', 'none');

% view(0,90)  % XY
% pause
% view(0,0)   % XZ
% pause
% view(90,0)  % YZ



%%

exportgraphics(gcf, append(name,'png'), 'Resolution', 1200);
%exportgraphics(gcf, append(name,'pdf'), 'Resolution', 1200);

% exportgraphics(gcf, append(name,'.pdf'), ...
%     'Resolution', 1200, ...
%     'ContentType','image');           % <-- key


