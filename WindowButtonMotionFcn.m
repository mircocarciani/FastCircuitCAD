function WindowButtonMotionFcn(src,event,clickFlag)

if ~clickFlag
    return
end

pos = get(Obj.Ax,'CurrentPoint')
Obj.DisplayGrObj
drawnow limitrate


end