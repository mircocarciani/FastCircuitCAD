classdef ResistorObj < ComponentObj
    
   
    properties
        
    end
    
    
    methods
        
        function this  = ResistorObj(SchManager, compName,compXo,compYo)
            
            this@ComponentObj(SchManager,compName,compXo,compYo,EComponentType.Resistor)
            this.GrObj = hggroup('Parent',SchManager.SchematicAxes,'Tag',compName);
            this.CreateGrObj() % Populate The  graphicObj for Resistor
            this.DisplayGrObj()
            this.GrObj.ButtonDownFcn = @this.ClickOnComponent;
            
            if ~SchManager.isuifigure()
                 this.GrObj.UIContextMenu = this.cmenu;
            end
        end
        
        
        function CreateGrObj(this)
            this.Xlim = 2;
            this.Ylim = 6;
            
            
            X = [0 0 1.2 -1.2  1.2 -1.2  1.2 -1.2   0 0 ];
            Y = [6 3 2.5  1.5  0.5  -0.5 -1.5 -2.5  -3 -6];
            res = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'LineJoin','miter','Tag','body');
            res.HitTest = 'off';
            res.UserData.Defaults.XData = X;
            res.UserData.Defaults.YData = Y;
            

            X = 3;
            Y = 0;
            label = text(X,Y,this.Name,'FontWeight','normal','FontSize',8,'FontUnit','pixels','Parent',this.GrObj); 
            label.UserData.Defaults.Xo = X;
            label.UserData.Defaults.Yo = Y;
            
            label.HitTest = 'off';
            
            this.A1 = [0,6];
            this.B1 = [0,-6];
            [pA,pB] = this.CreateAnchorPoint();

            

            this.GrSubObj{1} = res;
            this.GrSubObj{2} = pA;
            this.GrSubObj{3} = pB;
            this.GrSubObj{4} = label;

            
            
            
        end
        
    end
 
    
end