classdef PinObj < ComponentObj
    
   
    properties
    end
    
    
    methods
        
        function this  = PinObj(SchManager, compName,compXo,compYo)
            
            this@ComponentObj(SchManager,compName,compXo,compYo,EComponentType.Pin)
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
            Y = [2 0];
            
            
            edge1 = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5);
            edge1.HitTest = 'off';
            edge1.UserData.Defaults.XData = X;
            edge1.UserData.Defaults.YData = Y;
            
            
            X = [1 -1 -1  1];
            Y = [0 0 -2 -2];
            body = patch('XData',X,'YData',Y,'FaceColor','none','EdgeColor','black','Parent',this.GrObj,'Tag','body');
            body.HitTest = 'off';
            body.UserData.Defaults.XData = X;
            body.UserData.Defaults.YData = Y;
            
            
            X = 3;
            Y = 0;
            label = text(X,Y,this.Name,'FontWeight','normal','FontSize',8,'FontUnit','pixels','Parent',this.GrObj); 
            label.UserData.Defaults.Xo = X;
            label.UserData.Defaults.Yo = Y;
             label.HitTest = 'off';

             
            this.A1 = [0,2];
            this.B1 = []; % left empty not to create the Pin
            [pA,~] = this.CreateAnchorPoint();
            this.B1 = [0,2]; % fake assigment, need  this because of the code structure. TO REVISIT
             
            this.GrSubObj{1} = body;
            this.GrSubObj{2} = edge1;
            this.GrSubObj{3} = pA;
            this.GrSubObj{4} = label;
            
            this.Xlim = 1;
            this.Ylim = 2;
            
        end
        
    end
 
    
end