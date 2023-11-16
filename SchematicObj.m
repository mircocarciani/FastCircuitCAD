classdef SchematicObj <  handle

    
    properties
        Fig
        GrObj
        Ylim
        Xlim
        Manager
        DDB
    end
    
    methods
        
        function this = SchematicObj(myDDB)
            this.Ylim = [-120,120];
            this.Xlim = this.Ylim*440/183;
            this.DDB = myDDB;
        end
        
        
        
        function StartApp(this)
            if isempty(this.Fig)
                this.CreateGrObj()
            elseif ~isempty(this.Fig) && isempty(this.GrObj) 
                this.StartSchematicFromApp()
            else
                this.StartSchematicFromFormedGUI()
            end
            this.Manager = SchematicManager(this.GrObj,this.Fig,this.DDB);
        end
        
        
        
        function CreateGrObj(this)
            this.Fig = figure;
            this.Fig.Tag = 'Figure';
            this.Fig.WindowButtonMotionFcn = @this.WindowButtonMotionFcn;
            this.Fig.WindowButtonUpFcn = @this.WindowButtonUpFcn;
%           this.Fig.ButtonDownFcn = @this.ButtonDownFcn;
            this.Fig.WindowKeyPressFcn = @this.WindowKeyPressFcn;
            this.Fig.WindowKeyReleaseFcn  =@this.WindowKeyReleaseFcn;
            this.Fig.WindowScrollWheelFcn = @this.WindowScrollWheelFcn;
            this.Fig.OuterPosition = [50 50 1403 982]; 
            
            this.GrObj = axes(this.Fig);
            this.GrObj.Tag = 'Schematic';
            this.GrObj.XLim = this.Xlim;
            this.GrObj.YLim = this.Ylim;
%             this.GrObj.XAxis.Visible = 'off';
%             this.GrObj.YAxis.Visible = 'off';
            this.GrObj.Units  = 'normalized';
            this.GrObj.Position = [0.01,0.01,0.98,0.98];
        end
        
        
        
        function StartSchematicFromApp(this)
            fig = this.Fig;
            fig.Tag = 'Figure';
            fig.WindowButtonMotionFcn = @this.WindowButtonMotionFcn;
            %fig.WindowButtonDownFcn = @this.WindowButtonDownFcn;
            fig.WindowButtonUpFcn = @this.WindowButtonUpFcn;
            fig.WindowKeyPressFcn = @this.WindowKeyPressFcn;
            fig.WindowKeyReleaseFcn  =@this.WindowKeyReleaseFcn;
            fig.WindowScrollWheelFcn = @this.WindowScrollWheelFcn;
%             fig.Interruptible = 'off';
%             fig.BusyAction = 'cancel';
            fig.Name = 'Schematic';
            fig.NumberTitle = 'off';
            this.GrObj = axes(fig);
            this.GrObj.Units  = 'pixels';
            this.GrObj.Position = [10,10,this.Fig.Position(3)-20,this.Fig.Position(4)-20];
            this.GrObj.Tag = 'Schematic';
            this.GrObj.XLim = this.Xlim;
            this.GrObj.YLim = this.Ylim;
            this.GrObj.XAxis.Visible = 'off';
            this.GrObj.YAxis.Visible = 'off';
            this.GrObj.Units  = 'normalized';
            %this.GrObj.Position = [0.01,0.01,0.98,0.98];
        end
        
        function StartSchematicFromFormedGUI(this)
            fig = this.Fig;
            fig.Tag = 'Figure';
            fig.WindowButtonMotionFcn = @this.WindowButtonMotionFcn;
            fig.WindowButtonUpFcn = @this.WindowButtonUpFcn;
            fig.WindowKeyPressFcn = @this.WindowKeyPressFcn;
            fig.WindowKeyReleaseFcn  =@this.WindowKeyReleaseFcn;
            fig.WindowScrollWheelFcn = @this.WindowScrollWheelFcn;
            
            this.GrObj.Tag = 'Schematic';
            this.GrObj.XLim = this.Xlim;
            this.GrObj.YLim = this.Ylim;
            this.GrObj.XAxis.Visible = 'off';
            this.GrObj.YAxis.Visible = 'off';
            this.GrObj.Toolbar.Visible = 'on';
        end
        
        
        
        function SetFigure(this,Fig)
               this.Fig = Fig;
        end
        

        
        
       
        function WindowButtonMotionFcn(this, src, event)
            if isempty(src.CurrentObject) || (src.CurrentObject ~= this.Manager.SchematicAxes && ~any(src.CurrentObject == this.Manager.SchematicAxes.Children) && ~strcmp(src.CurrentObject.Tag,'LineHandle'))
                return
            end
            
            pos = get(this.GrObj,'CurrentPoint');
%             a = [pos(1,1),pos(1,2)];
%           disp(a)
%           disp(this.GrObj.CurrentPoint)
%             return
            x_int = round(pos(1,1));  % x grid with delta X  = 1
            y_int = round(pos(1,2));  % y grid with delta Y  = 1
            if x_int > this.Xlim(2) ||  x_int < this.Xlim(1) 
               return %limit violation
            end
            if y_int > this.Ylim(2) || y_int < this.Ylim(1) 
                return %limit violation
            end 
            if this.Manager.selectMultiObjectFlag
               if ~isempty(this.Manager.SelectionRectangle)
                   Xo = this.Manager.SelectionRectangle.XData(1);
                   Yo = this.Manager.SelectionRectangle.YData(1);
                   [X,Y] = SchematicManager.getXYfromPos(Xo,Yo,x_int - Xo,y_int - Yo);
                   this.Manager.SelectionRectangle.XData = X;
                   this.Manager.SelectionRectangle.YData = Y;
               end 
                return
            end
            obj = this.Manager.FindAnchorsByCoordinate(x_int,y_int);
            if isempty(obj)
                % do nothing    
            else
                obj.EdgeColor = 'red';
                obj.FaceColor = 'red';
                return
            end
            
            [value,objList] = this.Manager.FindObjbyProperty('ObjDrag',true);
            if value && this.Manager.AllowComponentDragAndDrop
                if ~this.Manager.MultiSelectionFlag && ~isa(objList{1},'LineObj') && ~isa(objList{1},'LineHandle')
                    obj = objList{1};
                    obj.Xo = x_int;
                    obj.Yo = y_int;
                    obj.DisplayGrObj()
                    drawnow  limitrate
                    return
%                 elseif ~this.Manager.MultiSelectionFlag && isa(objList{1},'LineHandle') 
%                     obj = objList{1};
%                     obj.DragLine(x,y)

                elseif ~this.Manager.MultiSelectionFlag && isa(objList{1},'LineObj')
                    obj = objList{1};
                    obj.UserOverwrite = true;
                    objH = obj.FindHandle();
                    objH.DragLine(x_int,y_int);
                else
                    Xpos = this.Manager.Xpos;
                    Ypos = this.Manager.Ypos;
                    this.Manager.Xpos = x_int;
                    this.Manager.Ypos = y_int;
                    for i = 1 : numel(objList)
                        obj = objList{i};
                        if ~isa(obj,'LineObj')
                            Xo = obj.Xo;
                            Yo = obj.Yo;
                            obj.Xo =    round(x_int - Xpos + Xo);
                            obj.Yo = round(y_int - Ypos + Yo);
                            obj.DisplayGrObj()
                        end
                    end
                    return
                end               
            end
            if ~isempty(this.Manager.currentLineObj) && this.Manager.DrawConnectionFlag
              Line = this.Manager.currentLineObj;
                if ~isempty(Line.ObjA)
                    if x_int > Line.A(1)
                        x = x_int - 1.5;
                    else
                        x = x_int + 1.5;
                    end
                    if y_int > Line.A(2)
                        y = y_int - 1.5;
                    else
                        y = y_int + 1.5;
                    end
                    Line.ConnectBy2PointsCoordinates(Line.A(1),Line.A(2),x,y)
                    Line.UpdateStraightLineDisplay(Line.A,Line.B)
                    drawnow  limitrate
                    return
                end
            end
        end
        
        function SetXYLimits(this,xlim,ylim)
            this.Xlim = xlim;
            this.Ylim = ylim;
            this.Manager.SetYXAxLimits(xlim,ylim)
        end

        
        
%         function ButtonDownFcn(this,src,event)
%           %  keyboard
%           [value,objList] = this.Manager.FindObjbyProperty('ObjSelected',true);
%             if value
%                 for i = 1 : numel(objList)
%                     obj = objList{i};
%                     obj.SetComponentSelectionStatus(false)
%                 end 
%             end
%           
%             if this.Manager.selectMultiObjectFlag
%                 if isempty(this.Manager.SelectionRectangle)
%                     pos = get(this.GrObj,'CurrentPoint');
%                     x = pos(1,1);  % x grid with delta X  = 1
%                     y = pos(1,2);  % y grid with delta Y  = 1
%                     [X,Y] = SchematicManager.getXYfromPos(x,y,0.1,0.1);
%                      this.Manager.SelectionRectangle = patch('XData',X,'YData',Y,'FaceColor','none','EdgeColor','r','LineStyle',':');
%                      return
%                end
%             end
%             
%             
%            PreList = this.Manager.GetObjListbyClass('LineObj');
%            for i = 1 : numel(PreList)
%               obj = PreList{i};
%               for j = 1 : obj.nHandles
%                 obj.HandelsList{j}.SetVisibility('Off')
%               end
%            end 
%         end
        
        
        
        function WindowButtonUpFcn(this,src,event,sr)
            if isempty(src.CurrentObject) || (src.CurrentObject ~= this.Manager.SchematicAxes && ~any(src.CurrentObject == this.Manager.SchematicAxes.Children) && ~strcmp(src.CurrentObject.Tag,'LineHandle'))
                return
            end
            [value,objList] = this.Manager.FindObjbyProperty('ObjDrag',true);
            if value
                 for i = 1 : numel(objList)
                     obj = objList{i};
                     obj.ObjDrag = false;
                     if isa(obj,'LineObj')
                         % Remove LineHdl
                        obj.RemoveAllLineHandles()
                        obj.RemoveDuplicatedCorners()
                        % Create New LineHdl
                        obj.CreateLineHandles()
                        obj.setAllHandlesDragOff()
                        %add remove line hanldes
                        %this.AssignLineHandles();
                     else
                         for lineIdx = 1 : numel(obj.ConnectionLineList)
                             LineObj = obj.ConnectionLineList{lineIdx};
                             if LineObj.UserOverwrite
                                    LineObj.RemoveAllLineHandles()
                                    LineObj.RemoveDuplicatedCorners()
                                    % Create New LineHdl
                                    LineObj.CreateLineHandles()
                                    LineObj.setAllHandlesDragOff()
                             end
                         end                         
                     end
                 end 
                if this.Manager.MultiSelectionFlag
                    this.Manager.MultiSelectionFlag = false;
                end
            end    
            if this.Manager.selectMultiObjectFlag    
               if ~isempty(this.Manager.SelectionRectangle)
                   Xmax = max(this.Manager.SelectionRectangle.XData);
                   Xmin = min(this.Manager.SelectionRectangle.XData);
                   Ymax = max(this.Manager.SelectionRectangle.YData);
                   Ymin = min(this.Manager.SelectionRectangle.YData);
                   List = this.Manager.FindObjByCoordianteRange(Xmin,Xmax,Ymin,Ymax);
                   if ~isempty(List)
                        for i  = 1 : numel(List)
                            List{i}.ObjSelected = true;
                        end
                   end
                   delete(this.Manager.SelectionRectangle)
                   this.Manager.SelectionRectangle = [];
               end
               this.Manager.selectMultiObjectFlag = false;
               disp('Multi Select OFF')
               this.Manager.MultiSelectionFlag = true;
               this.Fig.Pointer = 'arrow';
                pos = get(this.GrObj,'CurrentPoint');
                x = round(pos(1,1));  % x grid with delta X  = 1
                y = round(pos(1,2));  % y grid with delta Y  = 1
                this.Manager.Xpos = x;
                this.Manager.Ypos = y;
           
            end
            this.Manager.UpdateConnectionLines();
        end
        
        
        
        function WindowKeyPressFcn (this,src, keyData)
        global crlKeyPressed shiftKeyPressed
        %Cheking that the axes is in focus
        t = tic;
        if isempty(keyData.Source.CurrentObject) || (keyData.Source.CurrentObject ~= this.Manager.SchematicAxes && ~any(keyData.Source.CurrentObject == this.Manager.SchematicAxes.Children))
            toc(t)
            return
        end
        
            if strcmpi(keyData.Key,'escape')     
                this.Manager.currentCompObj = [];
                if ~isempty(this.Manager.currentLineObj)
                    NameCurrLine = this.Manager.currentLineObj.Name;
                    this.Manager.RemoveSchematicObjectsByName(NameCurrLine)
                    this.Manager.currentLineObj = [];
                end    
            end
            if ~exist('crlKeyPressed','var') || isempty(crlKeyPressed)
                crlKeyPressed = false;
            end
            if strcmpi(keyData.Key,'control') 
                crlKeyPressed = true;
            end
            if ~exist('shiftKeyPressed','var') || isempty(shiftKeyPressed)
                shiftKeyPressed = false;
            end
            if strcmpi(keyData.Key,'shift')
                shiftKeyPressed = true;
            end
            if crlKeyPressed && strcmpi(keyData.Key,'r')  % CTRL + R: Combiation to rotate the component
                 [value,objList] = this.Manager.FindObjbyProperty('ObjSelected',true);
                if value
                    for i = 1 : numel(objList)
                        if ~isa(objList{i},'LineObj')
                            obj = objList{i};
                        	obj.RotateObj()
                        end
                    end
                else
                    disp('Component not found')
                end
                return
            end
            
            if crlKeyPressed && strcmpi(keyData.Key,'c')  % CTRL + C: Combiation to copy a object
                 [value,objList] = this.Manager.FindObjbyProperty('ObjSelected',true);
                if value
                    this.Manager.currentCompObj = [];
                    for i = 1 : numel(objList)
                        if ~isa(objList{i},'LineObj') 
                            obj = objList{i};
                            if isempty(this.Manager.currentCompObj)
                                this.Manager.currentCompObj = {obj};
                            else
                                this.Manager.currentCompObj = [this.Manager.currentCompObj,{obj}];
                            end
                            disp([obj.Name,' added to clipboard'])
                        end
                    end
                else
                    disp('Component not found')
                end
                return
            end
            
            if strcmpi(keyData.Key,'uparrow')
                [value,objList] = this.Manager.FindObjbyProperty('ObjSelected',true);
                if value
                    for i = 1 : numel(objList)
                        if ~isa(objList{i},'LineObj') &&  ~isa(objList{i},'LineHandle')
                            obj = objList{i};
                            obj.Yo =  obj.Yo + 1;
                            obj.DisplayGrObj()
                            drawnow  limitrate
                        end
                    end
                end 
                return
            end
            
            if strcmpi(keyData.Key,'downarrow')
                [value,objList] = this.Manager.FindObjbyProperty('ObjSelected',true);
                if value
                    for i = 1 : numel(objList)
                        if ~isa(objList{i},'LineObj') &&  ~isa(objList{i},'LineHandle')
                            obj = objList{i};
                            obj.Yo =  obj.Yo -1;
                            obj.DisplayGrObj()
                            drawnow  limitrate
                        end
                    end
                end 
                return
            end
            
            if strcmpi(keyData.Key,'leftarrow')
                [value,objList] = this.Manager.FindObjbyProperty('ObjSelected',true);
                if value
                    for i = 1 : numel(objList)
                        if ~isa(objList{i},'LineObj') &&  ~isa(objList{i},'LineHandle')
                            obj = objList{i};
                            obj.Xo =  obj.Xo - 1;
                            obj.DisplayGrObj()
                            drawnow  limitrate
                        end
                    end
                end 
                return
            end
            
            if strcmpi(keyData.Key,'rightarrow')
                [value,objList] = this.Manager.FindObjbyProperty('ObjSelected',true);
                if value
                    for i = 1 : numel(objList)
                        if ~isa(objList{i},'LineObj') &&  ~isa(objList{i},'LineHandle')
                            obj = objList{i};
                            obj.Xo =  obj.Xo + 1;
                            obj.DisplayGrObj()
                            drawnow  limitrate
                        end
                    end
                end 
                return
            end
            
            if crlKeyPressed && strcmpi(keyData.Key,'v')  % CTRL + V: Combiation to paste a copied obj
                if ~isempty(this.Manager.currentCompObj)
                    for i = 1 : numel(this.Manager.currentCompObj)
                            obj = this.Manager.currentCompObj{i};
                        	obj.Paste()
                    end
                else
                    disp('Clipboard is empty')
                end
                return
            end
            
            
            if strcmpi(keyData.Key,'delete')  % DEL: Key to delete the component
                [value,objList] = this.Manager.FindObjbyProperty('ObjSelected',true);
                if value
                    if this.Manager.MultiSelectionFlag
                        this.Manager.MultiSelectionFlag = false;
                    end
                    for i = 1 : numel(objList)
                        obj = objList{i};
                        Name = obj.Name;
                        this.Manager.RemoveSchematicObjectsByName(Name)
                        this.Manager.UpdateConnectionLines()
                    end
                else
                    disp('Select the objet to delete')
                end
                return
            end
            if strcmpi(keyData.Key,'w')
                disp('drawing line')
                this.Manager.DrawConnectionFlag = true;
                this.Manager.InitilizeConnection();
                return
            end          
            if strcmpi(keyData.Key,'r')
                this.Manager.AddComponents('Resistor')
                disp('Added Resistor')
                return
            end 
            if shiftKeyPressed && strcmpi(keyData.Key,'c')
                this.Manager.AddComponents('ElectrolyticCapacitor')
                disp(['Added '  char(ECapacitorType.HighVoltageElectrolytic) ' Capacitor'])
                return
            end 
            
            if shiftKeyPressed && strcmpi(keyData.Key,'i')
                this.Manager.AddComponents('InnoSwitch3EP')
                disp('Added InnoSwitch3EP')
                return
            end 
            
            if strcmpi(keyData.Key,'i')
                this.Manager.AddComponents('InnoSwitch3CE')
                disp('Added InnoSwitch3CE')
                return
            end
            
            if shiftKeyPressed && strcmpi(keyData.Key,'o')
                this.Manager.AddComponents('InnoSwitch3Pro')
                disp('Added InnoSwitch3Pro')
                return
            end
            
            if strcmpi(keyData.Key,'o')
                this.Manager.AddComponents('InnoSwitch3CP')
                disp('Added InnoSwitch3CP')
                return
            end
            
            
            if strcmpi(keyData.Key,'c')
                this.Manager.AddComponents('Capacitor')
                disp(['Added '  char(ECapacitorType.General) ' Capacitor'])
                return
            end
            
            if strcmpi(keyData.Key,'z')
                this.Manager.AddComponents('Zener')
                disp('Added Zener')
                return
            end          
            if strcmpi(keyData.Key,'d')
                this.Manager.AddComponents('Diode')
                disp('Added Diode')
                return
            end 
           if strcmpi(keyData.Key,'l')
                this.Manager.AddComponents('Inductor')
                disp('Added Inductor')
                return
           end           
           if strcmpi(keyData.Key,'q')
                this.Manager.AddComponents('Mosfet')
                disp('Added Mosfet')
                return
           end
           if strcmpi(keyData.Key,'f')
                this.Manager.AddComponents('Fuse')
                disp('Added Mosfet')
                return
           end
           if strcmpi(keyData.Key,'p')
                this.Manager.AddComponents('Pin')
                disp('Added Pin')
                return
           end
           if strcmpi(keyData.Key,'m')
                this.Manager.AddComponents('CMChoke')
                disp('Added Mosfet')
                return
           end
           
           if strcmpi(keyData.Key,'b')
                this.Manager.AddComponents('Bridge')
                disp('Added Bridge Rectifier')
                return
           end
           
           if strcmpi(keyData.Key,'t')
                this.Manager.AddComponents('Transformer')
                disp('Added Transformer')
                return
           end
           
            if shiftKeyPressed && strcmpi(keyData.Key,'g')
                this.Manager.AddComponents('PotentialReference')
                disp('Added Potential Reference')
                return
            end
           
           if strcmpi(keyData.Key,'g')
                this.Manager.AddComponents('Ground')
                disp('Added Ground')
                return
           end
        end
        
        
        
        
        function WindowKeyReleaseFcn (this,src, keyData)
            global crlKeyPressed shiftKeyPressed
            if strcmpi(keyData.Key,'control')
                crlKeyPressed = false;
            end
            if strcmpi(keyData.Key,'shift')
                shiftKeyPressed = false;
            end
        end
        
        
        function WindowScrollWheelFcn(this,src,event)
            global crlKeyPressed
            
            if ~exist('crlKeyPressed','var') || isempty(crlKeyPressed)
                crlKeyPressed = false;
            end
            
            if ~crlKeyPressed
                return
            end
            
            
            ZoomX = round(-event.VerticalScrollCount*10);
            ZoomY = ZoomX; %* this.Manager.XYRatio;
            
            
            XLim = this.Manager.SchematicAxes.XLim;
            YLim = this.Manager.SchematicAxes.YLim;
            
            
            NewXLim = XLim + [-ZoomX,ZoomX];
            NewYLim = YLim + [-ZoomY,ZoomY];
            
            if NewXLim(1) > NewXLim(2)
                NewXLim(1) = -1;
                NewXLim(1) = +1;
            end
            
            if NewYLim(1) > NewYLim(2)
                NewYLim(1) = NewXLim(1) * this.XYRatio;
                NewXLim(1) = NewXLim(2) * this.XYRatio;
            end
            this.Manager.SchematicAxes.XLim  = NewXLim; 
            this.Manager.SchematicAxes.YLim  = NewYLim; 
            
            
            this.Xlim = NewXLim;
            this.Ylim = NewYLim;
        end
        
    end
end

