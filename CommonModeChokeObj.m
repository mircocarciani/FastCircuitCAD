classdef CommonModeChokeObj < ComponentObj
    
   
    properties
        A2
        B2
    end
    
    
    methods
        
        function this  = CommonModeChokeObj(SchManager, compName,compXo,compYo)
            this@ComponentObj(SchManager,compName,compXo,compYo,EComponentType.CMChoke)
            this.GrObj = hggroup('Parent',SchManager.SchematicAxes,'Tag',compName);
            this.CreateGrObj() % Populate The  graphicObj for Resistor
            this.DisplayGrObj()
            this.GrObj.ButtonDownFcn = @this.ClickOnComponent;
            
            if ~SchManager.isuifigure()
                 this.GrObj.UIContextMenu = this.cmenu;
            end
        end
        
        
        function CreateGrObj(this)
%             X = [3 -3 -3 3]; 
%             Y = [4 4 -4 -4];
%             box = patch(X, Y, 'white', 'EdgeColor','none','Parent',this.GrObj);
%             box.HitTest = 'off';
%             box.UserData.Defaults.XData = X;
%             box.UserData.Defaults.YData = Y;
            
            delta = 3;
            periods = 1.5;
            Y0 = 4;
            CalcY = @(fi) Y0-delta./pi().*fi;
            CalcX = @(fi,A) abs(A.*sin(fi)); 
             
            
            
            
            
            fi = 0:pi/50:periods*2*pi;
            Y = CalcY(fi);
            X = CalcX(fi,2) - 4 ;
            Inductor1 = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            Inductor1.HitTest = 'off';
            Inductor1.UserData.Defaults.XData = X;
            Inductor1.UserData.Defaults.YData = Y;
            
            
            
            
            X = [-10,-10 -4, X, -4, -10, -10];
            Y = [8,  6, 6, Y, -6, -6, -8];
            Connection1 = line(X,Y,'Parent',this.GrObj,'LineWidth',1,'Tag','body');
            Connection1.HitTest = 'off';
            Connection1.UserData.Defaults.XData = X;
            Connection1.UserData.Defaults.YData = Y;
            
            
            
            Y = CalcY(fi);
            X = -CalcX(fi,2) + 4 ;
            Inductor2 = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            Inductor2.HitTest = 'off';
            Inductor2.UserData.Defaults.XData = X;
            Inductor2.UserData.Defaults.YData = Y;
            
            
            
            X = [10, 10, 4, X ,4, 10, 10];
            Y = [8,  6, 6 , Y, -6, -6, -8]; 
            Connection2 = line(X,Y,'Parent',this.GrObj,'LineWidth',1,'Tag','body');
            Connection2.HitTest = 'off';
            Connection2.UserData.Defaults.XData = X;
            Connection2.UserData.Defaults.YData = Y;
            
            
            
            X = [-0.5 , -0.5];
            Y = [4 , -4];
            edge3 = line(X,Y,'Parent',this.GrObj,'LineWidth',1,'Tag','body');
            edge3.HitTest = 'off';
            edge3.UserData.Defaults.XData = X;
            edge3.UserData.Defaults.YData = Y;
            
            
            X = [0.5 , 0.5];
            Y = [4 , -4];
            edge4 = line(X,Y,'Parent',this.GrObj,'LineWidth',1,'Tag','body');
            edge4.HitTest = 'off';
            edge4.UserData.Defaults.XData = X;
            edge4.UserData.Defaults.YData = Y;
            
            
            
            X = 8;
            Y = 0;
            label = text(X,Y,this.Name,'FontWeight','normal','FontSize',8,'FontUnit','pixels','Parent',this.GrObj);
            label.UserData.Defaults.Xo = X;
            label.UserData.Defaults.Yo = Y;
            label.HitTest = 'off';
            
            this.A1 = [10,8];
            this.B1 = [10,-8];
            this.A2 = [-10,8];
            this.B2 = [-10,-8];
            
            [pA1,pB1] = this.CreateAnchorPoint(1);
            
            [pA2,pB2] = this.CreateAnchorPoint(2);
            
            
%             this.GrSubObj{1} = box;
            this.GrSubObj{1} = Inductor1;
            this.GrSubObj{2} = Inductor2;
            this.GrSubObj{3} = Connection1;
            this.GrSubObj{4} = Connection2;
            this.GrSubObj{5} = edge3;
            this.GrSubObj{6} = edge4;
            this.GrSubObj{7} = pA1;
            this.GrSubObj{8} = pB1;
            this.GrSubObj{9} = pA2;
            this.GrSubObj{10} = pB2;
            this.GrSubObj{11} = label;
            
            this.Xlim = 6;
            this.Ylim = 10;
            
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