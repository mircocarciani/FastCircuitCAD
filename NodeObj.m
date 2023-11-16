classdef NodeObj< handle
   
    properties
       Xo
       Yo
       NodeLabel
       GrObj
       Parameters
       Family
       r % radius 
       Line
       A % four Ancor points
       B 
       C
       D
       visible
       
    end
    
    
    methods
        
        % Constructor
        function this = NodeObj(myLine,NodeLabel,NodeXo,NodeYo,visible)
            this.Line = myLine;
            this.r = 0.8;
            this.NodeLabel = NodeLabel;
            this.Xo = NodeXo;
            this.Yo = NodeYo;
            this.visible  = visible;
            this.CreateGrObj(myLine.GrObj);
            this.DisplayGrObj()
            %this.GrObj.ButtonDownFcn = @MouseDown;
        end
       
        function CreateGrObj(this,parent)
%             this.r = 1;
%             fi = 0:pi/50:2*pi;
%             X = this.r * cos(fi) + this.Xo;
%             Y = this.r * sin(fi)  + this.Yo;
            X= 0;
            Y = 0;
            this.GrObj = patch(X,Y,'black','Parent',parent,'LineWidth',1,'Tag',this.NodeLabel);
            this.GrObj.HitTest = 'on';
            this.GrObj.Visible = this.visible;
            
%            X = 3 + this.Xo;
%            Y = 3 + this.Yo;
%            Label = text(X,Y,this.Name,'FontWeight','normal','FontSize',10,'FontUnit','pixels','Parent',this.GrObj);
%             this.A = [this.r  ,0];
%             this.B = [0       ,this.r ];
%             this.C = [-this.r ,0];
%             this.D = [0       ,-this.r ];
        end
        
        
        function DisplayGrObj(this)
            [x,y] =  DrawCircle(this.r);
            this.GrObj.XData = x + this.Xo;
            this.GrObj.YData = y + this.Yo;
        end
        
        
        function Update(this,x,y)
            this.Xo = x;
            this.Yo = y;
            this.DisplayGrObj()
        end
        
        function SetVisibility(this,state)
            this.GrObj.Visible = state;
        end
        
        
    end
    
    
    
    methods (Static)
       
        function bRet = IsNode(Obj)       
            bRet = isa(Obj,'NodeObj');
        end
        
    end
    
end