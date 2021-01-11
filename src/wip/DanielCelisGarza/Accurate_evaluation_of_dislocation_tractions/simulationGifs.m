clear all

nameAIni = '../output/initial_analytic_11-Jan-2021_bb_0';
nameA = '../output/analytic_11-Jan-2021_bb_';
nameNIni = '../output/initial_numeric_11-Jan-2021_bb_0';
nameN = '../output/numeric_11-Jan-2021_bb_';

%%
axis tight manual % this ensures that getframe() returns a consistent size
load(nameAIni);
counter = 0;
outputname = '../output/images/analytic.gif';
while counter < 66
    filename = strcat(nameA, sprintf('%d', counter));
    load(filename)
%     view([-15 15])
    plotnodes(rn,links,plim,vertices);
    % Capture the plot as an image
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if counter == 0
        imwrite(imind,cm,outputname,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,outputname,'gif','WriteMode','append');
    end
    counter = counter + 1;
end

%%
axis tight manual % this ensures that getframe() returns a consistent size
load(nameNIni);
counter = 0;
outputname = '../output/images/numeric.gif';
while counter < 156
    filename = strcat(nameN, sprintf('%d', counter));
    load(filename)
%     view([-15 15])
    plotnodes(rn,links,plim,vertices);
    % Capture the plot as an image
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if counter == 0
        imwrite(imind,cm,outputname,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,outputname,'gif','WriteMode','append');
    end
    counter = counter + 2;
end