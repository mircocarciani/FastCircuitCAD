classdef BridgeObj < ComponentObj
    
   
    properties
        A2
        B2
    end
    
    
    methods
        
        function this  = BridgeObj(SchManager, compName,compXo,compYo)
            
            this@ComponentObj(SchManager,compName,compXo,compYo,EComponentType.Bridge)
            this.GrObj = hggroup('Parent',SchManager.SchematicAxes,'Tag',compName);
            this.CreateGrObj() % Populate The  graphicObj for Resistor
            this.DisplayGrObj()
            this.GrObj.ButtonDownFcn = @this.ClickOnComponent;
            if ~SchManager.isuifigure()
                 this.GrObj.UIContextMenu = this.cmenu;
            end
        end
        
        
        function CreateGrObj(this)
              
            X = [0  -10  0  10];
            Y = [10  0  -10 0];
            outbody = patch('XData',X,'YData',Y,'FaceColor','white','EdgeColor','black','Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            outbody.HitTest = 'off';
            outbody.UserData.Defaults.XData = X;
            outbody.UserData.Defaults.YData = Y;   
            
            
            X = [0 0];
            Y = [8 2];
            edge1 = line(X,Y,'Parent',this.GrObj,'LineWidth',1,'Tag','body');
            edge1.HitTest = 'off';
            edge1.UserData.Defaults.XData = X;
            edge1.UserData.Defaults.YData = Y;
            
            X = [-2 2];
            Y = [2 2];
            edge2 = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            edge2.HitTest = 'off';
            edge2.UserData.Defaults.XData = X;
            edge2.UserData.Defaults.YData = Y;
            
            X = [0 0];
            Y = [-2 -8];
            edge3 = line(X,Y,'Parent',this.GrObj,'LineWidth',1,'Tag','body');
            edge3.HitTest = 'off';
            edge3.UserData.Defaults.XData = X;
            edge3.UserData.Defaults.YData = Y;
            
            
            
            X = [0 -2 2 0];
            Y = [2 -2 -2 2];
            body = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            body.HitTest = 'off';
            body.UserData.Defaults.XData = X;
            body.UserData.Defaults.YData = Y;
            
            
            X = 10;
            Y = 5;
            lable = text(X,Y,this.Name,'FontWeight','normal','FontSize',8,'FontUnit','pixels','Parent',this.GrObj); 
            lable.UserData.Defaults.Xo = X;
            lable.UserData.Defaults.Yo = Y;
            lable.HitTest = 'off';

             
            this.A1 = [0,10];
            this.B1 = [0,-10];
            [pA1,pB1] = this.CreateAnchorPoint(1);
            
            this.A2 = [-10 , 0];
            this.B2 = [10 , 0];
            [pA2,pB2] = this.CreateAnchorPoint(2);
             
            this.GrSubObj{1} = body;
            this.GrSubObj{2} = edge1;
            this.GrSubObj{3} = edge2;
            this.GrSubObj{4} = edge3;
            this.GrSubObj{5} = pA1;
            this.GrSubObj{6} = pB1;
            this.GrSubObj{7} = outbody;
            this.GrSubObj{8} = pA2;
            this.GrSubObj{9} = pB2;
            this.GrSubObj{10} = lable;
            
            this.Xlim = 12;
            this.Ylim = 12;
            
        end
        
        
        
        function RotateAnchorPoints(this)
                [this.A1(1),this.A1(2)] = rotate_figure(this.A1(1),this.A1(2),pi/2); % rotating the anchor points
                [this.B1(1),this.B1(2)] = rotate_figure(this.B1(1),this.B1(2),pi/2);
                this.A1 = round(this.A1);
                this.B1 = round(this.B1);
                
                [this.A2(1),this.A2(2)] = rotate_figure(this.A2(1),this.A2(2),pi/2); % rotating the anchor points
                [this.B2(1),this.B2(2)] = rotate_figure(this.B2(1),this.B2(2),pi/2);
                this.A2 = round(this.A2);
                this.B2 = round(this.B2);
        end
        
    end
 
    
end