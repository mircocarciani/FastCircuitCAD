function [xprim,yprim] = rotate_figure(x, y, alpha)
xtemp  = x;
ytemp = y;

mod = sqrt(xtemp.^2 + y.^2);
x0idx = xtemp == 0;
xtemp(x0idx) = 0;

y0idx = ytemp == 0;
ytemp(y0idx) = 0;


xtemp = xtemp .*(mod>0) + 1 .*(mod==0);
ytemp = ytemp .*(mod>0) + 1 .*(mod==0);



beta = pi.*(xtemp<0) + atan(ytemp./xtemp);


gamma = beta + alpha;

xprim = mod .* cos(gamma) .*(mod>0) + x .* (mod==0);
yprim = mod .* sin(gamma) .*(mod>0) + y .* (mod==0);