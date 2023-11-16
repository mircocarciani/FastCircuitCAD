function [x,y] =  DrawCircle(r)
    fi = 0:pi/50:2*pi;
    x = r * cos(fi);
    y = r * sin(fi); 
end