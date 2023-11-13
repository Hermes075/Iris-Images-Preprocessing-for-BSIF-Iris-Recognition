% Arthur Rubio & Lucas Rivière - Bresenham algorithm - 13/11/2023

function [x, y] = bresenham(x1, y1, x2, y2)
% Bresenham line algorithm
% Inputs:
%   x1, y1 - Les coordonnées du premier point de la ligne
%   x2, y2 - Les coordonnées du deuxième point de la ligne
% Outputs:
%   x, y - Les coordonnées des points sur la ligne

    x1 = round(x1); y1 = round(y1);
    x2 = round(x2); y2 = round(y2);
    
    dx = abs(x2 - x1);
    dy = abs(y2 - y1);
    steep = dy > dx;
    
    if steep
        [x1, y1] = deal(y1, x1);
        [x2, y2] = deal(y2, x2);
        [dx, dy] = deal(dy, dx);
    end
    
    if x1 > x2
        [x1, x2] = deal(x2, x1);
        [y1, y2] = deal(y2, y1);
    end
    
    derr = 2*dy;
    err = 0;
    y = y1;
    ystep = 1;
    if y1 > y2
        ystep = -1;
    end
    
    x = x1:x2;
    if steep
        y_points = arrayfun(@(xx) deal(y), x);
    else
        y_points = zeros(1, numel(x));
    end
    
    for idx = 1:numel(x)
        if steep
            y_points(idx) = x(idx);
            x(idx) = y;
        else
            y_points(idx) = y;
        end
        err = err + derr;
        if err > dx
            y = y + ystep;
            err = err - 2*dx;
        end
    end
    
    if steep
        [x, y] = deal(y_points, x);
    end
end
