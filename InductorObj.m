classdef InductorObj < ComponentObj
    
   
    properties
    end
    
    
    methods
        
        function this  = InductorObj(SchManager, compName,compXo,compYo)
            this@ComponentObj(SchManager,compName,compXo,compYo,EComponentType.Inductor)
            this.GrObj = hggroup('Parent',SchManager.SchematicAxes,'Tag',compName);
            this.CreateGrObj() % Populate The  graphicObj for Resistor
            this.DisplayGrObj()    
            this.GrObj.ButtonDownFcn = @this.ClickOnComponent;
            if ~SchManager.isuifigure()
                 this.GrObj.UIContextMenu = this.cmenu;
            end
        end
        
        
        function CreateGrObj(this)
            X = [2 0 0 2]; 
            Y = [6 6 -6 -6];
            box = patch(X, Y, 'white', 'EdgeColor','none','Parent',this.GrObj);
            box.HitTest = 'off';
            box.UserData.Defaults.XData = X;
            box.UserData.Defaults.YData = Y;
            
            delta = 2;
            periods = 3;
            Y0 = 6;

            CalcY = @(fi) Y0-delta./pi().*fi;
            CalcX = @(fi,A) abs(A.*sin(fi)); 

            fi = 0:pi/50:periods*2*pi;
            Y = CalcY(fi);
            X = CalcX(fi,2);

            X = [0,X,0];
            Y = [8,Y,-8];

            edge = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            edge.HitTest = 'off';
            edge.UserData.Defaults.XData = X;
            edge.UserData.Defaults.YData = Y;
            
            X = 3;
            Y = 0;
            label = text(X,Y,this.Name,'FontWeight','normal','FontSize',10,'FontUnit','pixels','Parent',this.GrObj);
            label.UserData.Defaults.Xo = X;
            label.UserData.Defaults.Yo = Y;
            label.HitTest = 'off';
            
            this.A1 = [0,8];
            this.B1 = [0,-8];
            [pA,pB] = this.CreateAnchorPoint();
            
            
            this.GrSubObj{1} = box;
            this.GrSubObj{2} = edge;
            this.GrSubObj{3} = pA;
            this.GrSubObj{4} = pB;
            this.GrSubObj{5} = label;
            
            this.Xlim = 2;
            this.Ylim = 8;
            
        end
        
        

    end
 
    
end