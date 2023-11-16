classdef GNDObj < ComponentObj
    
   
    properties
    end
    
    
    methods
        
        function this  = GNDObj(SchManager, compName,compXo,compYo)
            
            this@ComponentObj(SchManager,compName,compXo,compYo,EComponentType.Ground)
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
            Y = [4 0];
            edge1 = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            edge1.HitTest = 'off';
            edge1.UserData.Defaults.XData = X;
            edge1.UserData.Defaults.YData = Y;
            
            
            X = [-3 3];
            Y = [0 0];
            plate1 = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            plate1.HitTest = 'off';
            plate1.UserData.Defaults.XData = X;
            plate1.UserData.Defaults.YData = Y;
            
            
            
            X = [-2 2];
            Y = [-2 -2];
            plate2 = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            plate2.HitTest = 'off';
            plate2.UserData.Defaults.XData = X;
            plate2.UserData.Defaults.YData = Y;
            
            
            
            X = [-1 1];
            Y = [-4 -4];
            plate3 = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            plate3.HitTest = 'off';
            plate3.UserData.Defaults.XData = X;
            plate3.UserData.Defaults.YData = Y;
            
             
            this.A1 = [0,4];
            this.B1 = []; % left empty not to create the Pin
            [pA,~] = this.CreateAnchorPoint();
            this.B1 = [0,4]; % fake assigment, need  this because of the code structure. TO REVISIT
             
            this.GrSubObj{1} = edge1;
            this.GrSubObj{2} = plate1;
            this.GrSubObj{3} = plate2;
            this.GrSubObj{4} = plate3;
            this.GrSubObj{5} = pA;
            
            this.Xlim = 3;
            this.Ylim = 4;
            
        end
        
    end
 
    
end