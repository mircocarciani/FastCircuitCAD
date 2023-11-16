classdef LineHandle < handle
    
    properties
        Xo
        Yo
        ObjDrag
        GrObj
        parent
        cornersIdx
        orientation
        L = 1;
    end
    
    
    methods
   
        function obj  = LineHandle(x,y, parent,CornersIdx,Orientation)
            obj.Yo = y;
            obj.Xo = x;
            obj.parent = parent;
            obj.cornersIdx = CornersIdx;
            obj.orientation = Orientation;
            obj.CreateGrObj(parent.GrObj)
        end
        
        function CreateGrObj(this,parent)
            leng = this.L;
            X = [leng 0 -leng 0] + this.Xo;
            Y = [0 leng 0 -leng] + this.Yo;
            this.GrObj = patch('XData',X,'YData',Y,'FaceColor','blue','Parent',parent,'Tag','LineHandle');
            this.GrObj.ButtonDownFcn = @this.SelectHandle;
            this.SetVisibility('Off')
        end
        
         function DisplayGrObj(this)
             leng = this.L;
            X = [leng 0 -leng 0] + this.Xo;
            Y = [0 leng 0 -leng] + this.Yo;
            this.GrObj.XData = X;
            this.GrObj.YData = Y;
        end
        
        
        function Update(this,x,y,CornersIdx,Orientation)
            this.Xo = x;
            this.Yo = y;
            this.cornersIdx = CornersIdx;
            this.orientation = Orientation;
            this.DisplayGrObj()
        end
        
        function Remove(this)
            delete(this.GrObj)
        end
        
        function SetVisibility(this,state)
            this.GrObj.Visible = state;
        end
        
        
        
        function SelectHandle(this,src,event)
           disp('awesome')
           this.ObjDrag = true;
           this.parent.SetObjDragTrue()
        end
        
        
        
        function DragLine(this,x,y)
           this.parent.Drag(x,y,this.cornersIdx,this.orientation);
        end
            
        end
        
end
    
    
    