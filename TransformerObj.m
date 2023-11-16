classdef TransformerObj < ComponentObj
    
   
    properties
        
        nSec
        bSecBiasFlag
        bPrimBias
        TurnH
        PrimaryYOffset
        A2, B2
        A3, B3
        A4, B4
        A5, B5
        A6, B6
    end
    
    
    methods
        
        function this  = TransformerObj(SchManager, compName,compXo,compYo,nSec,bPrimBias,bSecBias)
            
            %put inputx dlg
            this@ComponentObj(SchManager,compName,compXo,compYo,EComponentType.Transformer)
            this.GrObj = hggroup('Parent',SchManager.SchematicAxes,'Tag',compName);
            this.TurnH = 2;
            if nargin < 5 || isempty(nSec) || isempty(bPrimBias) || isempty(bSecBias)
                [nSec,bPrimBias,bSecBias] = TrfConfigureDlg();
            end
            this.nSec = nSec;
            this.bSecBiasFlag = bSecBias;
            this.bPrimBias = bPrimBias;
            
            this.CreateGrObj() % Populate The  graphicObj for Resistor
            this.DisplayGrObj()
            
            this.GrObj.ButtonDownFcn = @this.ClickOnComponent;
            
            if ~SchManager.isuifigure()
                 this.GrObj.UIContextMenu = this.cmenu;
            end
        end
        
        
        function CreateGrObj(this)
%             X = [2 0 0 2]; 
%             Y = [6 6 -6 -6];
%             box = patch(X, Y, 'white', 'EdgeColor','none','Parent',this.GrObj);
%             box.HitTest = 'off';
%             box.UserData.Defaults.XData = X;
%             box.UserData.Defaults.YData = Y;
            
            
            % total height = delta * periods * 2            
            
            [X,Y] = this.getPrimary();
            primary = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
            primary.HitTest = 'off';
            primary.UserData.Defaults.XData = X;
            primary.UserData.Defaults.YData = Y;
            this.A1 = [min(X),max(Y)];
            this.B1 = [min(X),min(Y)];
            
           
           
           for i = 1 : this.nSec
               [X,Y] = this.GetSecondary(i);
               secondary.(['s',num2str(i)]) = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
               secondary.(['s',num2str(i)]).HitTest = 'off';
               secondary.(['s',num2str(i)]).UserData.Defaults.XData = X;
               secondary.(['s',num2str(i)]).UserData.Defaults.YData = Y;
           end
           
           
           if this.bSecBiasFlag 
                ymin = min(secondary.(['s',num2str(this.nSec)]).YData);
                [X,Y] = this.GetSecondaryBias(ymin);
                SecBias = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
                SecBias.HitTest = 'off';
                SecBias.UserData.Defaults.XData = X;
                SecBias.UserData.Defaults.YData = Y;
           end
           
           if this.bPrimBias
               yminPrim = min(primary.YData)
               if this.bSecBiasFlag 
                   ymin = min(SecBias.YData);
               else
                   ymin = min(secondary.(['s',num2str(this.nSec)]).YData);
               end
                [X,Y] = this.getPrimaryBias(yminPrim,ymin);
                primBias = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
                primBias.HitTest = 'off';
                primBias.UserData.Defaults.XData = X;
                primBias.UserData.Defaults.YData = Y;
           end
           
           
           ymin = inf;
           if this.bSecBiasFlag
               ymin = min(SecBias.YData);
           else
               if this.bPrimBias
                    ymin = min(primBias.YData);
               end
            ymin = min([ymin,secondary.(['s',num2str(this.nSec)]).YData]);
           end
           ymax = max(primary.YData);
           X = [0 0];
           Y = [ymax ymin];  
           core = line(X,Y,'Parent',this.GrObj,'LineWidth',1.5,'Tag','body');
           core.HitTest = 'off';
           core.UserData.Defaults.XData = X;
           core.UserData.Defaults.YData = Y;
           
           
           
            
%             X = 0;
%             Y = 10;
%             label = text(X,Y,this.Name,'FontWeight','normal','FontSize',10,'FontUnit','pixels','Parent',this.GrObj);
%             label.UserData.Defaults.XData = X;
%             label.UserData.Defaults.YData = Y;
%             label.HitTest = 'off';             
%             this.A = [0,8];
%             this.B = [0,-8];
            AnchorsList = {}
            %this.GrSubObj{1} = box;
            idx = 1; % first winding
            this.GrSubObj{idx} = primary;
            this.(['A',num2str(idx)]) = [min(primary.XData),max(primary.YData)]; 
            this.(['B',num2str(idx)]) = [min(primary.XData),min(primary.YData)];
            [pA,pB] =  CreateAnchorPoint(this,idx);
            this.GrSubObj{end+1} = pA;
            this.GrSubObj{end+1} = pB;
            
            idx = idx + 1;  % next widning
            
            SwindingList = fieldnames(secondary);
            for i = 1:numel(SwindingList)
                winding = secondary.(SwindingList{i});
                this.GrSubObj{end+1} = winding;
                this.(['A',num2str(idx)]) = [max(winding.XData),max(winding.YData)]; 
                this.(['B',num2str(idx)]) = [max(winding.XData),min(winding.YData)];
                [pA,pB] =  CreateAnchorPoint(this,idx);
                this.GrSubObj{end+1} = pA;
                this.GrSubObj{end+1} = pB;
                
                idx = idx + 1;  % next widning
            end
            
            if this.bPrimBias
                this.GrSubObj{end+1} = primBias;
                this.(['A',num2str(idx)]) = [min(primBias.XData),max(primBias.YData)]; 
                this.(['B',num2str(idx)]) = [min(primBias.XData),min(primBias.YData)];
                [pA,pB] =  CreateAnchorPoint(this,idx);
                this.GrSubObj{end+1} = pA;
                this.GrSubObj{end+1} = pB;
                idx = idx + 1; % next widning
            end
            
           
            if this.bSecBiasFlag
               this.GrSubObj{end+1} = SecBias;
               this.(['A',num2str(idx)]) = [max(SecBias.XData),max(SecBias.YData)]; 
                this.(['B',num2str(idx)]) = [max(SecBias.XData),min(SecBias.YData)];
                [pA,pB] =  CreateAnchorPoint(this,idx);
                this.GrSubObj{end+1} = pA;
                this.GrSubObj{end+1} = pB;
                
           end
            
            this.GrSubObj{end+1} = core;

           
             %this.GrSubObj{4} = secondary.s3;
%             this.GrSubObj{5} = label;
            
            this.Xlim = 2;
            this.Ylim = 8;    
        end
        
        
        
        
        function [X,Y] = getPrimary(this)
            periods = 8;
            Y0 = 0;
            X0 = -6;
            
            [X,Y] = this.getWindingDatapoints(periods,Y0,X0);
            
            
            X = [-8 -6 X -6 -8];
            Y = [0 0 Y min(Y) min(Y)];
            
            
            this.PrimaryYOffset =  abs(min(Y)/2);
            Y = Y + this.PrimaryYOffset ; % offsetting the primary along y by half its height
        end
        
        function  [X,Y] = GetSecondary(this,i)
            persistent yend
            if ~exist('yend','var') || isempty(yend) 
                yend = 0;
            end
            if i == 1
                yend = 0;
            end
            
            periods = 8;
            Y0 = yend;
            X0 = 6;
           [X,Y] = this.getWindingDatapoints(periods,Y0,X0,true);
           
            
          X = [8 6 X 6 8];
          Y = [max(Y) max(Y) Y min(Y) min(Y)];
          
          if  i == 1
            Y = Y + this.PrimaryYOffset; 
          else
           % Y = Y %+ this.PrimaryYOffset - yend * (i-1);
          end
          
          delta = 4;
          yend = min(Y) - delta * 2; 
        end
        
        
        
        function [X,Y] = getPrimaryBias(this, yminPrim,yminSec)
            periods = 4;
            delta = 4;
            if yminPrim == yminSec
                Y0 = - this.PrimaryYOffset - delta * 4 ;
            else
                Y0  = yminSec + periods*2*this.TurnH;
            end
            X0 = -6;
            [X,Y] = this.getWindingDatapoints(periods,Y0,X0);
            
            
%             CalcY = @(fi) Y0-delta./pi().*fi;
%             CalcX = @(fi,A) abs(A.*sin(fi)); 
%             
%            fi = 0:pi/50:periods*2*pi;
%            Y = CalcY(fi);
%            X = CalcX(fi,this.TurnH) - 6;
           
           X = [-8 -6 X -6 -8];
           Y = [max(Y) max(Y) Y min(Y) min(Y)];
        end
        
        
        function [X,Y] = GetSecondaryBias(this,Y0)
            delta = 4;
            Y0 = Y0 - delta * 2 ;
            X0 = 6;
            periods = 4;
            [X,Y] = this.getWindingDatapoints(periods,Y0,X0,true);
           
           X = [8 6 X 6 8];
           Y = [max(Y) max(Y) Y min(Y) min(Y)];
        end
        
        
        
        function AdjustLableOnRotation(this,obj) % to rewrite for trf
            width = obj.Extent(3);
            height = obj.Extent(4);
            
            if this.ObjOrientation == 1
                    X = this.Xlim + 1;    
                    Y = 0;            
            elseif this.ObjOrientation == 2
                    Y = this.Xlim + 1 + height/2;
                    X = -width/2;
            elseif this.ObjOrientation == 3
                    X = this.Xlim + 1;
                    %X = -this.Xlim - 1 - width;   
                    Y = 0;
            else
                    Y = this.Xlim + 1 + height/2;
                    %Y = this.Xlim + 1 + height/2;
                    X = -width/2; 
            end
            obj.UserData.Defaults.XData = X;
            obj.UserData.Defaults.YData = Y;
        end
        
        
        function [Xout,Yout] = getWindingDatapoints(this,periods,Y0,X0,invertX)
            if nargin < 5
                invertX = false;
            end
            fi1 = pi/2;
            fi2 = -pi/2;
            fiv = fi1:-fi1/90:fi2;
            x = this.TurnH * cos(fiv);
            if invertX
                x = -x;
            end
            
            y = this.TurnH * sin(fiv) - this.TurnH + Y0;
            
            X = [];
            Y = [];
            for  i = 1: periods
                X = [X,x];
                Y = [Y,y-(this.TurnH * (i-1) * 2)];
            end
          
            Xout = X + X0;
            Yout = Y;
        end
%         function [pA,pB] =  CreateAnchorPoint(this,i)
%             if nargin<2
%                 i = 1;
%             end
%             
%             sidx = num2str(i);
%             
%             r = 1.5;
%             fi = 0:pi/50:2*pi;
%             AnchorTagA = ['A',sidx];
%             A = this.(AnchorTagA);
%             X = r * cos(fi)+ A(1);
%             Y = r * sin(fi)+ A(2);
%             pA = patch('XData',X,'YData',Y,'FaceColor','none','EdgeColor','none','Tag','AnchorPoint','Parent',this.Manager.SchematicAxes);
%             pA.UserData.Defaults.XData = X;
%             pA.UserData.Defaults.YData = Y;
%             pA.UserData.Tag = AnchorTagA;
%             pA.HitTest = 'on';
%             pA.ButtonDownFcn = @this.SelectAnchorPoint;
%             
%             AnchorTagB = ['B',sidx];
%             B = this.(AnchorTagB);
%             X = r * cos(fi) + B(1);
%             Y = r * sin(fi) +  B(2);
%             pB = patch('XData',X,'YData',Y,'FaceColor','none','EdgeColor','none','Tag','AnchorPoint','Parent',this.Manager.SchematicAxes);
%             pB.UserData.Defaults.XData = X;
%             pB.UserData.Defaults.YData = Y;
%             pB.UserData.Tag = AnchorTagB;
%             pB.HitTest = 'on';
%             pB.ButtonDownFcn = @this.SelectAnchorPoint;
%         end
        
        

    end
 
    
end