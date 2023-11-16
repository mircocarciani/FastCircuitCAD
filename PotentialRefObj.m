classdef PotentialRefObj < ComponentObj
    
   
    properties
    end
    
    
    methods
        
        function this  = PotentialRefObj(SchManager, compName,compXo,compYo)
            
            this@ComponentObj(SchManager,compName,compXo,compYo,EComponentType.PotentialReference)
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
            
            
            X = [0  3  -3  0];
            Y = [-3 0     0   -3];
            body = patch('XData',X,'YData',Y,'FaceColor','none','EdgeColor','black','Parent',this.GrObj,'Tag','body');
            body.HitTest = 'off';
            body.UserData.Defaults.XData = X;
            body.UserData.Defaults.YData = Y;
            
             
            this.A1 = [0,4];
            this.B1 = []; % left empty not to create the Pin
            [pA,~] = this.CreateAnchorPoint();
            this.B1 = [0,4]; % fake assigment, need  this because of the code structure. TO REVISIT
             
            this.GrSubObj{1} = body;
            this.GrSubObj{2} = edge1;
            this.GrSubObj{3} = pA;
            
            this.Xlim = 1;
            this.Ylim = 3;
            
        end
        
    end
 
    
end