classdef CapacitorObj < ComponentObj
    
   
    properties
        CapacitorType
    end
    
    
    methods
        
        function this  = CapacitorObj(SchManager, compName,compXo,compYo,Family)
               
            this@ComponentObj(SchManager,compName,compXo,compYo,Family)
            this.GrObj = hggroup('Parent',SchManager.SchematicAxes,'Tag',compName);
            %this.CapacitorType = info{1};
            this.CreateGrObj()
            this.DisplayGrObj() % Populate The  graphicObj for Resistor
            
            this.GrObj.ButtonDownFcn = @this.ClickOnComponent;
            
            if ~SchManager.isuifigure()
                 this.GrObj.UIContextMenu = this.cmenu;
            end
        end
        
        
        function CreateGrObj(this)
            plateWidth = 3;
            
            
            X = [plateWidth -plateWidth -plateWidth plateWidth];
            Y = [1 1 -1 -1];
            dielectric = patch('XData',X,'YData',Y,'FaceColor','white','Parent',this.GrObj,'EdgeColor','none');
            dielectric.HitTest = 'off';
            dielectric.UserData.Defaults.XData = X;
            dielectric.UserData.Defaults.YData = Y;
            
            %TopConnection
            X = [0 0];  
            Y = [6 1];
            
            %BottomConnection
            X = [X,NaN, 0 0];  
            Y = [Y,NaN,-1 -6];
            
           % Top Plate
            X = [X,NaN, -plateWidth  plateWidth ];    
            Y = [Y,NaN, 1  1 ];
  
            if contains(string(this.Family),'Electrolytic')
                [X1,Y1] = this.BottomPlateElectrolic(plateWidth,-plateWidth,-1,-3);
                X = [X,NaN,X1];
                Y = [Y,NaN,Y1];
            else
                X = [X,NaN,-plateWidth  plateWidth];    
                Y = [Y,NaN, -1 -1];
            end

            Cap = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            Cap.HitTest = 'off';
            Cap.UserData.Defaults.XData = X;
            Cap.UserData.Defaults.YData = Y;
            
          
            X = 4; 
            Y = 0;
            label = text(X,Y,this.Name,'FontWeight','normal','FontSize',8,'FontUnit','pixels','Parent',this.GrObj);
            label.UserData.Defaults.Xo = X;
            label.UserData.Defaults.Yo = Y;
            label.HitTest = 'off';
            
            
            this.A1 = [0,6];
            this.B1 = [0,-6];
            [pA,pB] = this.CreateAnchorPoint();
            
            
            this.GrSubObj{1} = dielectric;
            this.GrSubObj{2} = Cap;
            this.GrSubObj{3} = pA;
            this.GrSubObj{4} = pB;
            this.GrSubObj{5} = label;
            
            
            this.Xlim = 3;
            this.Ylim = 6;
            
        end
        
        function [X,Y] = BottomPlateElectrolic(this, xmax,xmin,ymax,ymin)
            
            delta = xmax-xmin;
            X0  = -delta + xmin;
            A  = (ymax - ymin)*2/(2-sqrt(3));
            Y0 = -1 - A;  
            
            CalcX = @(fi) X0 + delta./(pi()/3).*fi;
            CalcY = @(fi,A) Y0 + abs(A.*sin(fi)); 

            fi = pi/3 : pi/1000 : 2*pi/3;
            X = CalcX(fi);
            Y = CalcY(fi,A);
            
            
        end
        
    end
 
    
end