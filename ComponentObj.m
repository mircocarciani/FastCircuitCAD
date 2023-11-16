classdef ComponentObj < handle 
   
    properties
       Xo
       Yo
       Xlim
       Ylim
       Name
       GrObj
       GrSubObj
       Parameters = struct()
       Family
       A1 % Object start (x,y) coordinate 
       B1 % Object end (x,y) coordinate
       Manager
       ObjSelected = false;
       ObjDrag = false;
       ObjOrientation
       AnchorASelected = false;
       AnchorBSelected = false;
       ConnectionLineList
       cmenu
       submenus
       Class = 'Component'
       Listener
    end
    
    events
        ComponentSelected
    end

    
    
    methods
        
        % Constructor
        function this = ComponentObj(SchematicManger,compName,compXo,compYo,family)
            this.Name = compName;
            this.Family = family;
            this.Xo = compXo;
            this.Yo = compYo;
            this.Manager = SchematicManger;
            this.ObjOrientation = 1;
            if ~SchematicManger.isuifigure()
                this.cmenu = uicontextmenu;
                this.submenus{1} = uimenu(this.cmenu,'Label','Rename','Callback',@this.RenameComponent);
            end
            this.Listener = addlistener(this,'ComponentSelected',@this.TriggerComponentSelectedEvent);
            this.InitiliazeComponentParameters()
        end
        
    
        function DisplayGrObj(this,action)  %once the graphic object has been created, we have got to move it to the right position int he schematic
            if nargin<2
                action = 'none';
            end
            if strcmp(action,'Rotate')
                this.RotateAnchorPoints()
            end
            
            for i = 1: numel(this.GrSubObj)
                subObj = this.GrSubObj{i};
                if isa(subObj,'matlab.graphics.primitive.Text')
                    this.AdjustLableOnRotation(subObj)
                    %if strcmp(action,'Rotate')
                     %   this.RotateSubObj(subObj)
                    %end
                    this.DisplayLabelObj(subObj)
                else
                    if strcmp(action,'Rotate')
                        this.RotateSubObj(subObj)
                    end
                	this.DisplayComponentObj(subObj)
                end
            end
            
            for  i = 1 : numel(this.ConnectionLineList)
                Line = this.ConnectionLineList{i};         
                Line.UpdateLinePosition(this.ObjOrientation);
            end
            drawnow limitrate
        end
        
        function Paste(this)
            xoffset = 10;
            yoffset = -10;
            if this.Family == EComponentType.Capacitor
                info = {this.CapacitorType};
            elseif this.Family == EComponentType.Transformer
                info = {this.nSec,this.bPrimBias,this.bSecBias};
            else
                info = [];
            end
            this.Manager.AddComponents(string(this.Family),this.Name,this.Xo+xoffset,this.Yo+yoffset,info) 
        end
        
        function DisplayLabelObj(this,obj)
              %obj.Position(1) = obj.Position(1) + this.Xo;
              %obj.Position(2) = obj.Position(2) + this.Yo;
              obj.Position(1) = obj.UserData.Defaults.XData + this.Xo;
              obj.Position(2) = obj.UserData.Defaults.YData + this.Yo;
              obj.Visible = 'On';
        end
        
%         function UpdateAttachedLine(this)
%             orientation  = this.ObjOrientation;
%         for i = 1: numel(this.ConnectionLineList)
%             LineObj = this.ConnectionLineList{i};
%             if a = 1;
%             else
%                 continue
%             end
%         end
%        end
            
        
        function RotateAnchorPoints(this)
                [this.A1(1),this.A1(2)] = rotate_figure(this.A1(1),this.A1(2),pi/2); % rotating the anchor points
                [this.B1(1),this.B1(2)] = rotate_figure(this.B1(1),this.B1(2),pi/2);
                this.A1 = round(this.A1);
                this.B1 = round(this.B1);
        end
        
        function DisplayComponentObj(this,obj)
                obj.XData = obj.UserData.Defaults.XData + this.Xo;
                obj.YData = obj.UserData.Defaults.YData + this.Yo;
                obj.Visible = 'On';
        end
        
        
        function ClickOnComponent(this,src,event)
            this.Manager.UnselectComponents({'Name'},{this.Name})   % the input arguments are the exceptionProp and exceptionProp value
            if event.Button == 1  % if left mouse click 
                notify(this,'ComponentSelected')
                if  ~this.ObjSelected
                    this.SetSelectionStatus(true)
                    return
                end
                
                if this.ObjSelected
                    this.ObjDrag = true;
                end
            end
        end
        
        function UpdateConnectionLineList(this,Line,Action)
            if strcmp(Action,'Add')
                this.ConnectionLineList{end+1} = Line;
            end
            if strcmp(Action,'Remove')
                for i = numel(this.ConnectionLineList): -1 : 1
                    LineObj = this.ConnectionLineList{i};
                    if strcmp(LineObj.Name, Line.Name)
                        this.ConnectionLineList(i) = [];
                    end
                end
            end
            
        end
        
        function SelectAnchorPoint(this,src,event)
            if event.Button ~= 1
                return
            end
            Anchor = src.UserData.Tag;
%             if strcmp(src.Tag,'AnchorPointA')
%                 Anchor = 'A';
%                  %if ~this.AnchorASelected
%                     %this.AnchorASelected = true;
%                 %end
%             elseif strcmp(src.Tag,'AnchorPointB')
%                 Anchor = 'B';
%                % if ~this.AnchorBSelected
%                   %  this.AnchorBSelected = true;
%                 %end
%             end
            
            if ~isempty(this.Manager.currentLineObj)
                Line = this.Manager.currentLineObj;
                if isempty(Line.ObjA)
                    Line.SetObjA(this);
                    Line.SetAnchorA(Anchor);
                    Line.SetAnchorACoordiantes()
                else
                    Line.SetObjB(this);
                    Line.SetAnchorB(Anchor);
                    Line.SetAnchorBCoordiantes()
                    Line.ConnectByAnchore()
                    Line.Draw();
                    disp('it Works up to here')
                    this.Manager.currentLineObj = [];
%                     this.Manager.DrawConnectionFlag = false;
                end
            end
            this.Manager.SortAxesChildren('AnchorPointFisrt')
        end
  
        function DeSelectAnchorPoints(this,src,event)
             this.AnchorASelected = false;
             this.AnchorBSelected = false; 
        end
        
        
        function RotateObj(this)
            if this.ObjOrientation < 4 
               this.ObjOrientation = this.ObjOrientation + 1;
           else
               this.ObjOrientation = rem(this.ObjOrientation + 1,4);
            end
           this.DisplayGrObj('Rotate')
           drawnow limitrate
        end
       
        
        function RotateSubObj(this,obj)
            [xprim,yprim] = rotate_figure(obj.UserData.Defaults.XData, obj.UserData.Defaults.YData, pi/2);  % polar transformation
            obj.UserData.Defaults.XData = xprim;
            obj.UserData.Defaults.YData = yprim;
            
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
                    X = obj.UserData.Defaults.Xo;
                    Y = obj.UserData.Defaults.Yo;
            else
%                     Y = this.Xlim + 1 + height/2;
%                     X = -width/2; 
                    Y = obj.UserData.Defaults.Xo + 1 + height/2;
                    X = obj.UserData.Defaults.Yo  - width/2;
            end
            obj.UserData.Defaults.XData = X;
            obj.UserData.Defaults.YData = Y;
        end
        
        
        function  [pA,pB] = CreateAnchorPoint(this,idx)
            pA = [];
            pB = [];
            if nargin<2
                idx = 1;
            end
            sidx = num2str(idx);
            AnchorTagA = ['A',sidx];
            AnchorTagB = ['B',sidx];

            r = 1.5;
            fi = 0:pi/10:2*pi;
            
            if ~isempty(this.(AnchorTagA))
                
                A = this.(AnchorTagA);
                X = r * cos(fi)+ A(1);
                Y = r * sin(fi)+ A(2);
                pA = patch('XData',X,'YData',Y,'FaceColor','none','EdgeColor','none','Tag','AnchorPoint','Parent',this.Manager.SchematicAxes);
                pA.UserData.Defaults.XData = X;
                pA.UserData.Defaults.YData = Y;
                pA.UserData.Tag = AnchorTagA;
                pA.HitTest = 'on';
                pA.ButtonDownFcn = @this.SelectAnchorPoint;
            end

            if ~isempty(this.(AnchorTagB))
                B = this.(AnchorTagB);
                X = r * cos(fi) + B(1);
                Y = r * sin(fi) +  B(2);
                pB = patch('XData',X,'YData',Y,'FaceColor','none','EdgeColor','none','Tag','AnchorPoint','Parent',this.Manager.SchematicAxes);
                pB.UserData.Defaults.XData = X;
                pB.UserData.Defaults.YData = Y;
                pB.UserData.Tag = AnchorTagB;
                pB.HitTest = 'on';
                pB.ButtonDownFcn = @this.SelectAnchorPoint;
            end
%             pA1 = [];
%             pB1 = [];
%             
%            if ~isempty(this.A1)
%                 r = 1.5;
%                 fi = 0:pi/50:2*pi;
%                 X = r * cos(fi)+ this.A1(1);
%                 Y = r * sin(fi)+ this.A1(2);
%                 pA1 = patch('XData',X,'YData',Y,'FaceColor','none','EdgeColor','none','Tag','AnchorPoint','Parent',this.Manager.SchematicAxes);
%                 pA1.UserData.Defaults.XData = X;
%                 pA1.UserData.Defaults.YData = Y;
%                 pA1.UserData.Tag = 'A1';
%                 pA1.HitTest = 'on';
%                 pA1.ButtonDownFcn = @this.SelectAnchorPoint;
%            end
%             
%             if ~isempty(this.B1)
%                 X = r * cos(fi) + this.B1(1);
%                 Y = r * sin(fi) +  this.B1(2);
%                 pB1 = patch('XData',X,'YData',Y,'FaceColor','none','EdgeColor','none','Tag','AnchorPoint','Parent',this.Manager.SchematicAxes);
%                 pB1.UserData.Defaults.XData = X;
%                 pB1.UserData.Defaults.YData = Y;
%                 pB1.UserData.Tag = 'B1';
%                 pB1.HitTest = 'on';
%                 pB1.ButtonDownFcn = @this.SelectAnchorPoint;
%             end
        end
        
        
        function RenameComponent(this,src,event)
            prompt = 'Enter new component Name';
            dlgtitle = 'Rename Component';
            newName = inputdlg(prompt,dlgtitle);
            oldName = this.Name;
            if isempty(newName)
                return
            end
            
            ExistingNames = keys(this.Manager.componentNameTypeMap);
            if any(ismember(ExistingNames,newName))
                warndlg('Name already in use')
                return
            end
            this.Name = newName{1};
            this.Manager.RemoveObjfromMaps(oldName)
            this.Manager.componentNameListenerMap(newName{1}) = this.Listener;
            this.Manager.componentNameTypeMap(newName{1}) = char(this.Family);
            this.Manager.componentNameObjMap(newName{1}) = this;
            this.GrSubObj{end}.String = this.Name;
            this.GrObj.Tag = this.Name;
            
            % change  reference names in attached lines
            
            for  i  = 1: numel(this.ConnectionLineList)
                LineObj  =  this.ConnectionLineList{i};
                if strcmp(LineObj.ObjAName,oldName)
                    LineObj.ObjAName = this.Name;
                end
                if strcmp(LineObj.ObjBName,oldName)
                    LineObj.ObjBName = this.Name;
                end
            end
            
        end
        
        
        function SetSelectionStatus(this,status)
            assert(islogical(status))
            this.ObjSelected = status;
            if status
                this.highlightComponent()
            else
                this.dehighlightComponent()
            end
        end
        
        function highlightComponent(this)
            disp([this.Name,' selected'])
            for i = 1: numel(this.GrSubObj)
                if strcmp(this.GrSubObj{i}.Tag,'body')
                    if isa(this.GrSubObj{i},'matlab.graphics.primitive.Line')
                    this.GrSubObj{i}.Color = 'red';
                    elseif isa(this.GrSubObj{i},'matlab.graphics.primitive.Patch')
                        this.GrSubObj{i}.EdgeColor = 'red';
                    else
                        warning('WrongClass')
                    end
                end
            end
        end
        
        
        function dehighlightComponent(this)
            disp([this.Name,' unselected'])
             for i = 1: numel(this.GrSubObj)
                if strcmp(this.GrSubObj{i}.Tag,'body')
                    if isa(this.GrSubObj{i},'matlab.graphics.primitive.Line')
                    this.GrSubObj{i}.Color = 'black';
                    elseif isa(this.GrSubObj{i},'matlab.graphics.primitive.Patch')
                        this.GrSubObj{i}.EdgeColor = 'black';
                    else
                        warning('WrongClass')
                    end
                end
            end
        end
        
        
        function InitiliazeComponentParameters(this)
            if any(ismember(fieldnames(this.Manager.componentParametersDef),string(this.Family)))
                this.Parameters = this.Manager.componentParametersDef.(string(this.Family));
            else
                this.Parameters = [];
            end
        end
        
        function TriggerComponentSelectedEvent(this,src,event)
            %this.Manager.DDB.Gui.ComponentSelected(src)
        end
        
    end
    
end