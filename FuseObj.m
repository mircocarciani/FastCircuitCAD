classdef FuseObj < ComponentObj
    
   
    properties
    end
    
    
    methods
        
        function this  = FuseObj(SchManager, compName,compXo,compYo)
            
            this@ComponentObj(SchManager,compName,compXo,compYo,EComponentType.Fuse)
            this.GrObj = hggroup('Parent',SchManager.SchematicAxes,'Tag',compName);
            this.CreateGrObj() % Populate The  graphicObj for Resistor
            this.DisplayGrObj()
            this.GrObj.ButtonDownFcn = @this.ClickOnComponent;
            
            if ~SchManager.isuifigure()
                 this.GrObj.UIContextMenu = this.cmenu;
            end
        end
        
        
        function CreateGrObj(this)
            
            
            delta = 3;
            periods = 1;
            Y0 = 3;

            CalcY = @(fi) Y0-delta./pi().*fi;
            CalcX = @(fi,A) A.*sin(fi); 

            %fuse connection
            fi = 0:pi/50:periods*2*pi;
            Y = CalcY(fi);
            X = CalcX(fi,2);
            
           % left circle
           [x,y] =  DrawCircle(1);
            X1 = x;
            Y1 = y + 3;
            X = [X,NaN,X1];
            Y = [Y,NaN,Y1];
            
            
            %right circle
            [x,y] =  DrawCircle(1);
            X1 = x;
            Y1 = y - 3;
            X = [X,NaN,X1];
            Y = [Y,NaN,Y1];
            
            
            fuse = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            fuse.HitTest = 'off';
            fuse.UserData.Defaults.XData = X;
            fuse.UserData.Defaults.YData = Y;
             
            
            X = 3;
            Y = 0;
            label = text(X,Y,this.Name,'FontWeight','normal','FontSize',8,'FontUnit','pixels','Parent',this.GrObj); 
            label.UserData.Defaults.Xo = X;
            label.UserData.Defaults.Yo = Y;
            label.HitTest = 'off';
             
             
            this.A1 = [0,3];
            this.B1 = [0,-3];
            [pA,pB] = this.CreateAnchorPoint();
             
             

            this.GrSubObj{1} = fuse;
            this.GrSubObj{2} = pA;
            this.GrSubObj{3} = pB;
            this.GrSubObj{4} = label;
            
            this.Xlim = 1;
            this.Ylim = 2;
            
        end
        
    end
 
    
end