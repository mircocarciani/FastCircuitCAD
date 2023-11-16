classdef ZenerObj < ComponentObj
    
   
    properties
    end
    
    
    methods
        
        function this  = ZenerObj(SchManager, compName,compXo,compYo)
            
            this@ComponentObj(SchManager,compName,compXo,compYo,EComponentType.Zener)
            this.GrObj = hggroup('Parent',SchManager.SchematicAxes,'Tag',compName);
            this.CreateGrObj() % Populate The  graphicObj for Resistor
            this.DisplayGrObj()
            this.GrObj.ButtonDownFcn = @this.ClickOnComponent;
            if ~SchManager.isuifigure()
                 this.GrObj.UIContextMenu = this.cmenu;
            end
        end
        
        
        function CreateGrObj(this)
              
            X = [0 0];
            Y = [6 2];

            X = [X, NaN, -3 -2 2 3];
            Y = [Y, NaN, 0  2 2  4];

            
            X = [X, NaN, 0 0];
            Y = [Y, NaN, -2 -6];
            
            X = [X,NaN, 0 -2 2 0];
            Y = [Y, NaN, 2 -2 -2 2];
            zener = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            zener.HitTest = 'off';
            zener.UserData.Defaults.XData = X;
            zener.UserData.Defaults.YData = Y;
            
            
            X = 3;
            Y = 0;
            label = text(X,Y,this.Name,'FontWeight','normal','FontSize',8,'FontUnit','pixels','Parent',this.GrObj); 
            label.UserData.Defaults.Xo = X;
            label.UserData.Defaults.Yo = Y;
            label.HitTest = 'off';

            
            this.A1 = [0,6];
            this.B1 = [0,-6];
            [pA,pB] = this.CreateAnchorPoint();
            
            
            this.GrSubObj{1} = zener;
            this.GrSubObj{2} = pA;
            this.GrSubObj{3} = pB;
            this.GrSubObj{4} = label;
            
            this.Xlim = 2;
            this.Ylim = 6;
        end
        
    end
 
    
end