classdef MosfetObj < ComponentObj
    
   
    properties
        A2
        B2
    end
    
    
    methods
        
        function this  = MosfetObj(SchManager, compName,compXo,compYo)
            
            this@ComponentObj(SchManager,compName,compXo,compYo,EComponentType.Mosfet)
            this.GrObj = hggroup('Parent',SchManager.SchematicAxes,'Tag',compName);
            this.CreateGrObj() % Populate The  graphicObj for Resistor
            this.DisplayGrObj()
            this.GrObj.ButtonDownFcn = @this.ClickOnComponent;
            if ~SchManager.isuifigure()
                 this.GrObj.UIContextMenu = this.cmenu;
            end
        end
        
        
        function CreateGrObj(this)
            
            
            X = [+3 +3 -1 -1 +3 +3];
            Y = [6  3 3 -3  -3 -6];
                          
            X = [X,NaN, -3  -3];
            Y = [Y,NaN, 3 -3];
            
            X = [X,NaN,-3 -6];
            Y = [Y,NaN,0 0];      
            
            mosfet = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'LineJoin','miter','Tag','body');
            mosfet.HitTest = 'off';
            mosfet.UserData.Defaults.XData = X;
            mosfet.UserData.Defaults.YData = Y;
            
            
            X = [3 1  1 3];
            Y = [-3   -1   -5  -3];
            arrow = patch(X,Y,'black','EdgeColor','none','Parent',this.GrObj,'Tag','body');
            arrow.HitTest = 'off';
            arrow.UserData.Defaults.XData = X;
            arrow.UserData.Defaults.YData = Y;
            
            
            X = 5;
            Y = 0;
            label = text(X,Y,this.Name,'FontWeight','normal','FontSize',10,'FontUnit','pixels','Parent',this.GrObj); 
            label.UserData.Defaults.Xo = X;
            label.UserData.Defaults.Yo = Y;
             label.HitTest = 'off';

             
            this.A1 = [3,6];
            this.B1 = [3,-6];
            [DrainPinAnchor,SourcePinAnchor] = this.CreateAnchorPoint(1);
            
            this.A2 = [-6,10e-6];
            this.B2 = [];
            [GatePinAnchor,~] = this.CreateAnchorPoint(2);
            this.B2 = [-4,0];
            
             
             
            this.GrSubObj{1} = mosfet; %upper leg (drain)
            this.GrSubObj{2} = arrow;  % arrow       
            this.GrSubObj{3} = DrainPinAnchor;
            this.GrSubObj{4} = SourcePinAnchor;
            this.GrSubObj{5} = GatePinAnchor;
            this.GrSubObj{6} = label;
            
            this.Xlim = 3;
            this.Ylim = 8;
        end
        
        
        function AdjustLableOnRotation(this,obj)
            width = obj.Extent(3);
            height = obj.Extent(4);
            
            if this.ObjOrientation == 1
%                     X = this.Xlim + 1;    
%                     Y = 0;            
                     X = obj.UserData.Defaults.Xo;
                     Y = obj.UserData.Defaults.Yo;
            elseif this.ObjOrientation == 2
%                     Y = this.Xlim + 1 + height/2;
%                     X = -width/2;
                     Y = obj.UserData.Defaults.Xo + 1 + height/2;
                     X = obj.UserData.Defaults.Yo  - width/2;
            elseif this.ObjOrientation == 3
                    %X = this.Xlim + 1;  
                    %Y = 0;
                    X = -obj.UserData.Defaults.Xo - width;
                    Y = obj.UserData.Defaults.Yo;
            else
%                     Y = this.Xlim + 1 + height/2;
%                     X = -width/2; 
                    Y = -obj.UserData.Defaults.Xo - height/2;
                    X = obj.UserData.Defaults.Yo  - width/2;
            end
            obj.UserData.Defaults.XData = X;
            obj.UserData.Defaults.YData = Y;
        end
        
        
        function RotateAnchorPoints(this) % Overwritten method from parent class
                [this.A1(1),this.A1(2)] = rotate_figure(this.A1(1),this.A1(2),pi/2); % rotating the anchor points
                [this.B1(1),this.B1(2)] = rotate_figure(this.B1(1),this.B1(2),pi/2);
                [this.A2(1),this.A2(2)] = rotate_figure(this.A2(1),this.A2(2),pi/2); 
                [this.B2(1),this.B2(2)] = rotate_figure(this.B2(1),this.B2(2),pi/2);
                this.A1 = round(this.A1);
                this.B1 = round(this.B1);
                this.A2 = round(this.A2);
                this.B2 = round(this.B2);  
        end
        
    end
 
    
end