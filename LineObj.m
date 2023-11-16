classdef LineObj< handle
   
    properties
       Family
       Class = 'Line'
       Name
       ObjA
       ObjAName
       AnchorObjA
       ObjB
       ObjBName
       AnchorObjB
       A %  [x,y] point where the line starts and connects to the obj
       A_p %  [x,y] point where the line starts
       B %  [x,y] point where the line ends and connects to the obj
       B_p %  [x,y] point where the line ends
       MiddlePoints % [C D E F G H etc]
       AllCorners
       C % Possible additional [x,y] point where the line presetns the first corner 
       D % % Possible additional [x,y] point where the line presetns the second corner
       ObjSelected  = false;
       ObjDrag = false;
       Manager
       GrObj
       GrSubObj
       CPointConnShapeType                                                                                                                                      
       UserOverwrite
       AnchorOffset
       NodeList
       nHandles
       
       HandlesList
       showHandles;
       
       Listener
       %X;
       %Y;
    end
    
    
    methods
        
        % Constructor
        function this = LineObj(Manager,Name)
            this.Name = Name;
            this.Manager = Manager; 
            this.AnchorOffset = 0;
            this.UserOverwrite = false;
            this.Family = EComponentType.Line;
            this.Listener = {};
        end
       
        function ConnectByAnchore(this)
           this.SetAnchorACoordiantes()
           this.SetAnchorBCoordiantes()
           %this.ConnectBy2PointsCoordinates(this.A(1),this.A(2),this.B(1),this.B(2))
        end
        
        function SetAnchorACoordiantes(this)
            objAnchor = this.AnchorObjA;
            if ~isempty(this.AnchorObjA) 
                a = this.ObjA.(objAnchor);
                this.A(1) = a(1) + this.ObjA.Xo;
                this.A(2) = a(2) + this.ObjA.Yo;

            else
                this.A(1) = 0;
                this.A(2) = 0;
            end
        end
        
        function SetAnchorBCoordiantes(this)
            objAnchor = this.AnchorObjB;
            if ~isempty(this.AnchorObjB)
                b = this.ObjB.(objAnchor);
                this.B(1) = b(1) + this.ObjB.Xo;
                this.B(2) = b(2) + this.ObjB.Yo; 
            else
                this.B(1) = 0;
                this.B(2) = 0;  
            end
            
        end
        
        
        function ConnectBy2PointsCoordinates(this,Ax,Ay,Bx,By)
            this.A = [Ax,Ay];
            this.B = [Bx,By];
        end
        
        function CreateCoordinateVector(this)
%         this.X = [this.A(1),this.B(2)]
%         this.Y = 
        end
            
        function AddPointCoordinate(this,x,y)
            this.Xvecotr = [this.X,x];
            this.Yvecotr = [this.Y,y];
        end
        
        function SetObjA(this,FromOBj)
            this.ObjA = FromOBj;
            this.ObjAName = FromOBj.Name;
            FromOBj.UpdateConnectionLineList(this,'Add')
        end
        
        function SetObjB(this,ToObj)
            this.ObjB = ToObj;
            this.ObjBName = ToObj.Name;
            ToObj.UpdateConnectionLineList(this,'Add')
        end
        
        function SetAnchorA(this,anchor)
            this.AnchorObjA = anchor;
        end
        
        function SetAnchorB(this,anchor)
            this.AnchorObjB = anchor;
        end
        
        function CreateGrObj(this)
            pA = this.A;
            pB = this.B;
            
            if isempty(pA)
                pA = [0,0];
            end
            if isempty(pB)
                pB = [0,0];
            end
            this.GrObj = hggroup('Parent',this.Manager.SchematicAxes,'Tag',this.Name);
            this.GrObj.ButtonDownFcn = @this.SelectObj;
            X = [pA(1),pB(1)];
            Y  = [pA(2),pB(2)];
           Line = line(X,Y,'Color','black','LineWidth',0.75,'Parent',this.GrObj);
           Line.HitTest = 'off';
           this.GrSubObj{1} = Line; 
        end
        
        function RemoveLineHandle(this,idx)
            Hdl = this.HandlesList{idx};
            for childIdx = numel(this.GrObj.Children) : -1 : 1
                child = this.GrObj.Children(childIdx);
                if eq(child,Hdl.GrObj)
                    delete(this.GrObj.Children(childIdx))
                    break
                end
            end
            this.HandlesList(idx) = [];
        end
        
        
        function AddLineHandlesOnDrag(this)
            
            
        end
        
        
        function AssignLineHandles(this,NewCornerPos)
            if nargin < 2r
                NewCornerPos = [];
            end
            PointsVect = this.AllCorners;
            nCornermax = (size(PointsVect,1) -1);
            
            H2del = numel(this.HandlesList) - nCornermax;
            if H2del > 0
                for j =  numel(this.HandlesList) : -1 : nCornermax + 1  
                    this.RemoveLineHandle(j);
                end
            end
            if ~isempty(NewCornerPos)
               NewLineHdl = LineHandle(0,0, this, [],[]);
               if  NewCornerPos==1
                    this.HandlesList = [{NewLineHdl},this.HandlesList];
               else
                    this.HandlesList = [this.HandlesList,{NewLineHdl}];
               end
            end
            for  i = 1 : nCornermax
                P1 = PointsVect(i,:);                
                P2 = PointsVect(i+1,:);
                [x,y] = this.FindSegmentCentre(P1,P2);
                [bRetVal,Or] = this.IsMouseInBetween([x,y],P1,P2);
                if ~bRetVal
                    error('something''s worng')
                end
                PIdx = all(ismember(PointsVect,P1),2);
                PIdx = PIdx +  all(ismember(PointsVect,P2),2);
                 if numel(this.HandlesList) >= i
                    this.HandlesList{i}.Update(x,y, PIdx,Or);
                 else
                     this.HandlesList{i} = LineHandle(x,y, this, PIdx,Or);
                 end
                if this.ObjSelected
                    this.HandlesList{i}.SetVisibility('On')
                end  
            end
            this.nHandles = numel(this.HandlesList);
        end
        
        
        function UpdateLineHandles(this,offsetPos)
            for idx = 1 : this.nHandles
                hdl = this.HandlesList{idx};
                corners = this.AllCorners;
                if numel(offsetPos)==1 && offsetPos == 1
                    corners = corners(2:end , :);
                elseif numel(offsetPos)==1 && offsetPos > 1
                    corners = corners(1:end-1 , :);
                elseif numel(offsetPos)==2
                    corners = corners(2:end-1 , :);
                end
                corners = corners(logical(hdl.cornersIdx) , :);
                assert(size(corners,2)==2);
                P1 = corners(1,:);                
                P2 = corners(2,:);
                [x,y] = this.FindSegmentCentre(P1,P2);
                if offsetPos == 0
                    bRetVal = true;
                    Or = hdl.orientation;
                    PIdx = hdl.cornersIdx;
                else
                    [bRetVal,Or] = this.IsMouseInBetween([x,y],P1,P2);
                    PIdx = all(ismember(this.AllCorners,P1),2);
                    PIdx = PIdx +  all(ismember(this.AllCorners,P2),2);
                end
                if ~bRetVal
                    error('something''s worng')
                end
                
                this.HandlesList{idx}.Update(x,y, PIdx,Or);
            end
        end
        
        
        function CreateLineHandles(this)
            PointsVect = this.AllCorners;
            nCornermax = (size(PointsVect,1) -1);
            for  i = 1 : nCornermax
                P1 = PointsVect(i,:);                
                P2 = PointsVect(i+1,:);
                [x,y] = this.FindSegmentCentre(P1,P2);
                [bRetVal,Or] = this.IsMouseInBetween([x,y],P1,P2);
                if ~bRetVal
                    error('something''s worng')
                end
                PIdx = all(ismember(PointsVect,P1),2);
                PIdx = PIdx +  all(ismember(PointsVect,P2),2);
                this.HandlesList{i} = LineHandle(x,y, this, PIdx,Or);
                if this.ObjSelected
                    this.HandlesList{i}.SetVisibility('On')
                end  
            end
            this.nHandles = numel(this.HandlesList);
        end
        
        
        function [x,y] = FindSegmentCentre(this,P1,P2)
           if P1(1) == P2(1)
              x = P1(1);
              y = max([P1(2),P2(2)])  - (max([P1(2),P2(2)]) - min([P1(2),P2(2)])) * 0.5;  
           elseif P1(2) == P2(2)
               y = P1(2);
               x =  max([P1(1),P2(1)]) - (max([P1(1),P2(1)]) - min([P1(1),P2(1)])) * 0.5;
           else
               warning('this should not happen')
               x =  max([P1(1),P2(1)]) - (max([P1(1),P2(1)]) - min([P1(1),P2(1)])) * 0.5;
               y = max([P1(2),P2(2)])  - (max([P1(2),P2(2)]) - min([P1(2),P2(2)])) * 0.5;  
           end
            
        end
        
        
        function AssignNodes(this)
            for i =1: numel(this.AllCorners(:,1)) 
                 name = ['Node',num2str(i)];
                if ~this.FindNode(name)
                    this.AddNode(this.AllCorners(i,1),this.AllCorners(i,2),name)
                else
                    this.UpdateNode(this.AllCorners(i,1),this.AllCorners(i,2),name)
                end   
            end
            for i = numel(this.AllCorners) + 1 : numel(this.NodeList)
                name = ['Node',num2str(i)];
                this.RemoveNode(name)
            end
        end
            
        
        function AddNode(this,x,y,Name)
            visible = 'off';
            Node = NodeObj(this,Name,x,y,visible);
            this.NodeList{end+1} = Node;
        end
        
        
        function RemoveNode(this,Name)
            [bRet,obj] = FindNode(this,Name);
            if ~bRet
                return
            end
            % deleting  the obj from GrObj
            for i = numel(this.GrObj.Children): -1 :1 
                child = this.GrObj.Children(i);
                if eq(child,obj.GrObj)
                    this.DeleteNodeFromList(Name) % need to delect the saved calss object first than the patch obj.
                    delete(this.GrObj.Children(i))
                    return
                end
            end
        end
        
        
        function DeleteNodeFromList(this,Name)
            for i  = numel(this.NodeList) : -1: 1
                obj = this.NodeList{i};
                if strcmp(obj.GrObj.Tag,Name)
                    this.NodeList(i) = [];
                end
            end
        end
        
        
        function UpdateNode(this,x,y,Name)
            [bRet,obj] = FindNode(this,Name);
            if bRet
                obj.Update(x,y)
            end
        end
        
        
        function [bRet,obj] = FindNode(this,Name)
            bRet = false;    
            for i  =1 : numel(this.NodeList)
               obj = this.NodeList{i};
                if strcmp(obj.GrObj.Tag,Name)
                     bRet = true;
                     return
                end
            end  
            obj = [];
        end
          
        
        function UpdateStraightLineDisplay(this,A,B)
            % plot function which is used to update the straight line
            % position when the moving the mouse aroundt the schematic
            Line = this.GrSubObj{1};
            X = [A(1),B(1)];
            Y  = [A(2),B(2)];

           Line.XData = X;
           Line.YData = Y;
           Line.LineStyle = ':';
           Line.Color = 'blue';
           this.GrSubObj{1} = Line; 
        end
        
        
        function UpdateLineWithStraightSegment(this,P,where)
            % plot function which is used to update the straight line
            % position when the moving the mouse aroundt the schematic
            Line = this.GrSubObj{1};
            X = Line.XData();
            Y = Line.YData;
            switch where
                case 'start'
                   X = [P(1),X(2:end)];
                   Y =[P(2),Y(2:end)];
                   
                   
                case 'finish'
                    X = [X(1:end-1),P(1)];
                    Y = [Y(1:end-1),P(2)];
            end
                    
           Line.XData = X;
           Line.YData = Y;
           Line.LineStyle = ':';
           Line.Color = 'blue';
           this.GrSubObj{1} = Line; 
        end
        
        
        function UpdateLinePosition(this,orientation)
            % fucntiont that modifies the line possition when there has
            % been a change in the position of the objects the line is
            % attached to
            this.ConnectByAnchore()
            if this.UserOverwrite && this.HasMiddleCorner
                  this.UpdateFrozenLine('segmentedLine',orientation);
            else
            if ~this.HasMiddleCorner
                this.UserOverwrite = false;
            end
            this.Draw();
            end
        end
        
        function Val =  HasMiddleCorner(this)
            Val = numel(this.AllCorners(:,1)) > 2;
        end
        
        
        function Draw(this)
            %Plot function which determines the final shape of the
            %connection between ObjA and ObjB
            this.CalculateApBp()
            if this.A_p(1) == this.B_p(1) || this.A_p(2) == this.B_p(2)
                this.RegisterMiddlePoints([],[]);
                [X,Y] = LineObj.CalculateXYvectors(this.AllCorners); 
            else 
                [Xs,Ys] =  AddMiddlePoints(this);
                this.RegisterMiddlePoints(Xs,Ys);
                [X,Y] = LineObj.CalculateXYvectors(this.AllCorners);
            end
            this.ResetLineHandles
           
            %this.AssignLineHandles()
            this.AssignXYpoints(X,Y)    
        end
        
        
        function ResetLineHandles(this)
            % Remove LineHdl
             RemoveAllLineHandles(this)
            % Create New LineHdl
            CreateLineHandles(this)
        end
        
        
        function UpdateFrozenLine(this,type,orientation)
            switch type
                case 'straightLine'
                    this.CalculateApBp()
                    if all(this.A_p == this.AllCorners(1,:))  % B has been moved
                        this.UpdateLineWithStraightSegment(this.B_p,'finish');
                    elseif all(this.B_p == this.AllCorners(end,:)) % A has been moved
                        this.UpdateLineWithStraightSegment(this.B_p,'start');
                    end
            
                case 'segmentedLine'
                     this.CalculateApBp()
                     if all(this.A_p == this.AllCorners(1,:))  % B has been moved
                         P_old = this.AllCorners(end,:);
                         tag = 'B';
                    elseif all(this.B_p == this.AllCorners(end,:)) % A has been moved
                        P_old = this.AllCorners(1,:);
                        tag = 'A';
                     end
                     
                     
                     
                     if orientation == 1 || orientation == 3 % vertical
                         idx = ismember(this.AllCorners(:,1),P_old(1));
                         if strcmp(tag,'B')
                             %if sum(idx) == 1
                             if this.AllCorners(end-1,1) ~= P_old(1)
                                this.AllCorners(end,:)  = this.B_p;
%                                 if this.B_p(2) ~= P_old(2)
                                    this.AllCorners = [this.AllCorners(1:end-1,:);[this.B_p(1),this.AllCorners(end-1,2)];this.AllCorners(end,:)]; 
%                                 end
                             else
                                this.AllCorners(end-1,1) = this.B_p(1);
                                this.AllCorners(end,:)  = this.B_p;
                             end
                            
                         else
                             %if sum(idx) == 1
                             if this.AllCorners(2,1) ~= P_old(1)
                                this.AllCorners(1,:)  = this.A_p;
                                if this.A_p(2) ~= P_old(2)
                                    this.AllCorners = [this.AllCorners(1,:);[this.A_p(1),this.AllCorners(2,2)];this.AllCorners(2:end,:)]; 
                                end
                             else
                                this.AllCorners(2,1) = this.A_p(1);
                                this.AllCorners(1,:)  = this.A_p;
                             end
                         end
                     else % horizontal
                         idx = ismember(this.AllCorners(:,2),P_old(2));
                         if strcmp(tag,'B')
                            %if sum(idx) == 1
                            if this.AllCorners(end-1,2) ~= P_old(2)
                                this.AllCorners(end,:)  = this.B_p;
                                this.AllCorners = [this.AllCorners(1:end-1,:);[this.AllCorners(end-1,1),this.B_p(2)];this.AllCorners(end,:)]; 
                            else
                                this.AllCorners(idx,2) = this.B_p(2);
                                this.AllCorners(end,:)  = this.B_p;
                            end
                         else  % A moved
                             %if sum(idx) == 1 
                             if this.AllCorners(2,2) ~= P_old(2)
                                 this.AllCorners(1,:)  = this.A_p;
                                this.AllCorners = [this.AllCorners(1,:);[this.AllCorners(2,1),this.A_p(2)];this.AllCorners(2:end,:)]; 
                             else
                                this.AllCorners(2,2) = this.A_p(2);
                                this.AllCorners(1,:)  = this.A_p;
                             end
                         end
                     end
                     
                    [X,Y] = LineObj.CalculateXYvectors(this.AllCorners);
                    this.ResetLineHandles();
                    this.AssignXYpoints(X,Y);  
            end
         end
                   
            
       
        function RemoveAllLineHandles(this)
            for idx =   numel(this.HandlesList): -1 : 1
                this.RemoveLineHandle(idx)
            end
        end
        
        
       function Drag(this,x,y,Idx,Orientation)
%            for i = 1: numel(Idx)
%                if Idx(i)
%                    if strcmp(Orientation,'ver')
%                         this.AllCorners(i,1) = x;
%                    else
%                         this.AllCorners(i,2) = y;
%                    end
%                end
%            end
            if strcmp(Orientation,'ver')
                this.AllCorners(logical(Idx),1) = x;
            else
                this.AllCorners(logical(Idx),2) = y;
            end

           [X,Y] = this.CalculateXYvectors(this.AllCorners);
           NewCornerPos = 0;
           if this.A_p(1) ~= X(1) || this.A_p(2) ~= Y(1)
               this.AllCorners = [this.A_p;this.AllCorners];
               [X,Y] = this.CalculateXYvectors(this.AllCorners);
               NewCornerPos = 1;
           elseif this.B_p(1) ~= X(end) || this.B_p(2) ~= Y(end)
               this.AllCorners = [this.AllCorners;this.B_p];
               [X,Y] = this.CalculateXYvectors(this.AllCorners);
               NewCornerPos = numel(this.AllCorners);
           elseif (this.B_p(1) ~= X(end) || this.B_p(2) ~= Y(end)) &&  (this.A_p(1) ~= X(1) || this.A_p(2) ~= Y(1))
               this.AllCorners = [this.A_p;this.AllCorners;this.B_p];
               [X,Y] = this.CalculateXYvectors(this.AllCorners);
               NewCornerPos = [1,numel(this.AllCorners)];
           end
           
           
           this.AssignXYpoints(X,Y)
           this.UpdateLineHandles(NewCornerPos);
        end
        
        
        function DrawFromConnectionList(this,allCorners)
            this.AllCorners = allCorners;
            [X,Y] = LineObj.CalculateXYvectors(this.AllCorners);
            this.AssignXYpoints(X,Y)
            RemoveAllLineHandles(this)
            % Create New LineHdl
            CreateLineHandles(this)
        end
        
        
         function RemoveDuplicatedCorners(this)

             [AllCornersNoDouble] = unique(this.AllCorners,'rows','stable');
             if size(AllCornersNoDouble,1) == size(this.AllCorners,1)
                 return
             end
             XrowToDel = false(size(AllCornersNoDouble,1),1);
             YrowToDel = false(size(AllCornersNoDouble,1),1);
             for i  = 1 : numel(AllCornersNoDouble(:,1))
                IdxDoubleX  = ismember(AllCornersNoDouble(:,1),AllCornersNoDouble(i,1));
                Xmax = Utility.Vector_getNumAdiajectTrues(IdxDoubleX);
                IdxDoubleY  = ismember(AllCornersNoDouble(:,2),AllCornersNoDouble(i,2));
                Ymax = Utility.Vector_getNumAdiajectTrues(IdxDoubleY);
                if Xmax > 2
                    sumX = 0;
                   for j = 1 : numel(AllCornersNoDouble(:,1))
                       sumX = (sumX + IdxDoubleX(j)) * IdxDoubleX(j);
                      if sumX > 1 &&  sumX < Xmax
                          XrowToDel(j) = true; 
                      end
                   end
                end
                if Ymax > 2
                    sumY = 0;
                   for j = 1 : numel(AllCornersNoDouble(:,2))
                       sumY = (sumY + IdxDoubleY(j)) * IdxDoubleY(j);
                      if sumY > 1 &&  sumY < Ymax
                          YrowToDel(j) = true; 
                      end
                   end
                end
             end

             RawToDel = XrowToDel | YrowToDel;
             NewCorners = AllCornersNoDouble(~RawToDel,:); 
             this.AllCorners = NewCorners;
%              [X,Y] = this.CalculateXYvectors(this.AllCorners);
%              this.AssignXYpoints(X,Y)
         end
            
        
        function AssignXYpoints(this,X,Y)
            NewCornerPos = [];
%            if this.A_p(1) == X(1) && this.A_p(2) == Y(1)
%                 
%            else %Need to insert another corner
%                 this.AllCorners = [this.A_p;this.AllCorners];
%                [X,Y] = this.CalculateXYvectors(this.AllCorners);
%                NewCornerPos = 1;
%            end
%            if this.B_p(1) == X(end) && this.B_p(2) == Y(end)
%                
%            else %Need to insert another corner
%                 this.AllCorners = [this.AllCorners;this.B_p];
%                 [X,Y] = this.CalculateXYvectors(this.AllCorners);
%                 NewCornerPos = numel(this.AllCorners);
%            end
            X  = [this.A_p(1),X,this.B_p(1)];
            Y  = [this.A_p(2),Y,this.B_p(2)];
            %this.GrSubObj{1}.XData = X;
            %this.GrSubObj{1}.YData = Y;
            set(this.GrSubObj{1},'XData',X,'YData',Y)
            this.GrSubObj{1}.Color = 'black';
            this.GrSubObj{1}.LineStyle = '-';
            this.AssignNodes()% by default Nodes are invisible
            %this.AssignLineHandles(NewCornerPos);
            %this.Manager.UpdateConnectionLines();
        end
        
        
        function CalculateApBp(this)
            this.A_p = this.A;
            this.B_p = this.B;
            if this.ObjA.ObjOrientation ==1
                if strcmp(LineObj.GetAnchorClass(this.AnchorObjA),'A')
                    this.A_p(2) = this.A_p(2) + this.AnchorOffset;
                else
                    this.A_p(2) = this.A_p(2) - this.AnchorOffset;
                end
            elseif this.ObjA.ObjOrientation == 3
                if strcmp(this.GetAnchorClass(this.AnchorObjA),'A')
                    this.A_p(2) = this.A_p(2) - this.AnchorOffset;
                else
                    this.A_p(2) = this.A_p(2) + this.AnchorOffset;
                end
            elseif this.ObjA.ObjOrientation == 2
                if strcmp(LineObj.GetAnchorClass(this.AnchorObjA),'A')
                    this.A_p(1) = this.A_p(1) - this.AnchorOffset;
                else
                    this.A_p(1) = this.A_p(1) + this.AnchorOffset;
                end
            elseif this.ObjA.ObjOrientation == 4
                if strcmp(LineObj.GetAnchorClass(this.AnchorObjA),'A')
                    this.A_p(1) = this.A_p(1) + this.AnchorOffset;
                else
                    this.A_p(1) = this.A_p(1) - this.AnchorOffset;
                end
            end
            if this.ObjB.ObjOrientation ==1
                if strcmp(LineObj.GetAnchorClass(this.AnchorObjB),'A')
                    this.B_p(2) = this.B_p(2) + this.AnchorOffset;
                else
                    this.B_p(2) = this.B_p(2) - this.AnchorOffset;
                end
            elseif this.ObjB.ObjOrientation == 3
                if strcmp(LineObj.GetAnchorClass(this.AnchorObjB),'A')
                    this.B_p(2) = this.B_p(2) - this.AnchorOffset;
                else
                    this.B_p(2) = this.B_p(2) + this.AnchorOffset;
                end
            elseif this.ObjB.ObjOrientation == 2
                if strcmp(LineObj.GetAnchorClass(this.AnchorObjB),'A') 
                    this.B_p(1) = this.B_p(1) - this.AnchorOffset;
                else
                    this.B_p(1) = this.B_p(1) + this.AnchorOffset;
                end
            elseif this.ObjB.ObjOrientation == 4
                if strcmp(LineObj.GetAnchorClass(this.AnchorObjB),'A')
                    this.B_p(1) = this.B_p(1) + this.AnchorOffset;
                else
                    this.B_p(1) = this.B_p(1) - this.AnchorOffset;
                end
            end
        end

        
        
        
        function RegisterMiddlePoints(this,Xs,Ys)
            if isempty(Xs) || isempty(Ys)
                this.MiddlePoints = [];
            else
                assert(numel(Xs)==numel(Ys))
                z = numel(Xs);
                this.MiddlePoints = zeros(z,2);
                for i = 1 : z
                     this.MiddlePoints(i,:) = [Xs(i),Ys(i)];
                end
            end
            this.AllCorners = [this.A_p;this.MiddlePoints;this.B_p];
        end
        
        function [Xs,Ys] =  AddMiddlePoints(this)
            [Xs,Ys,Type] = LineObj.DecideConnectionShape(this,this.A_p,this.B_p,this.ObjA,this.ObjB, this.AnchorOffset);
            
            this.CPointConnShapeType = Type;
            
            if numel(Xs)==2 || numel(Ys)==2 % two intermediate points
                bret = LineObj.CheckCpos(Xs(1),Ys(1),this.ObjA,this.AnchorObjA,this.A_p);
                bret = bret && LineObj.CheckCpos(Xs(2),Ys(2),this.ObjA,this.AnchorObjA,this.A_p);
                bret = bret && LineObj.CheckCpos(Xs(1),Ys(1),this.ObjB,this.AnchorObjB,this.B_p);
                bret = bret && LineObj.CheckCpos(Xs(2),Ys(2),this.ObjB,this.AnchorObjB,this.B_p);
            else
                bret = LineObj.CheckCpos(Xs,Ys,this.ObjA,this.AnchorObjA,this.A_p);
                bret = bret && LineObj.CheckCpos(Xs,Ys,this.ObjB,this.AnchorObjB,this.B_p);
            end
            if  bret
                return
            end
            [Xs,Ys,Type] = LineObj.ChangeConnType(Type,this.A_p,this.B_p);
            this.CPointConnShapeType = Type;
        end
          
        function SetObjDragTrue(this)
            this.ObjDrag = true;
        end
            
        
        function SetObjDragFlase(this)
            this.ObjDrag = false;
        end
        
        function SelectObj(this,src,event)
            disp('ok')
            if event.Button == 1  % if left mouse click 
                if ~isempty(this.Manager.currentLineObj)
                    Line = this.Manager.currentLineObj;
                   if ~isempty(Line.ObjA) && isempty(Line.ObjB)
                        if numel(this.ObjA.ConnectionLineList) > numel(this.ObjB.ConnectionLineList)
                            CompObj = this.ObjA;
                            Anchor = this.AnchorObjA;
                        else
                            CompObj = this.ObjB;
                            Anchor = this.AnchorObjB;
                        end
                        Line.SetObjB(CompObj);
                        Line.SetAnchorB(Anchor);
                        Line.SetAnchorBCoordiantes()
                        Line.ConnectByAnchore()
                        Line.Draw();
                        disp('it Works up to here')
                        this.Manager.currentLineObj = [];
                        return
                   end
                end  
                this.SetSelectionStatus(true);
                this.Manager.SortAxesChildren('SelectedLineFirst')
            end
        end
        
        
        
        
        function SetSelectionStatus(this,status)   
            this.ObjSelected = status;
            
            if status
                this.TurnOnHandles()
            else
                this.TurnOffHandles()
            end
        end
        
        
        function TurnOnHandles(this)
            for i = 1 : this.nHandles
                  this.HandlesList{i}.SetVisibility('On')
            end
        end
        
        
        function TurnOffHandles(this)
            for i = 1 : this.nHandles
                  this.HandlesList{i}.SetVisibility('Off')
            end
        end
        
        
        function SwithNodeVisibility(this,name,state)
            [bret,obj] = this.FindNode(name);
            if bret
                obj.SetVisibility(state)
            end
        end
        

        function AddAdditionalMiddlePoint(this,pos,x,y,orientation)
            if pos == 1
                part1 = [x,y];
                part2 = this.MiddlePoints;
                if strcmp(orientation,'ver')
                    if x == this.A(1)
                        return
                    end
                   this.MiddlePoints = [part1;part2];
                   this.MiddlePoints(1,2) = this.A(2);
                   this.MiddlePoints(2,1) = x;         
                else

                end
            else
                 part1 = this.MiddlePoints;
                 part2 = [x,y];
                 this.MiddlePoints = [part1;part2];
            end
                 
        end
        
        function ModifyMiddlePointsValue(this,pos,x,y,orientation)
            if strcmp(orientation,'hor')
                this.MiddlePoints(pos,2) = y;
                this.MiddlePoints(pos+1,2) = y;
            elseif strcmp(orientation,'ver')
                this.MiddlePoints(pos-1,1) = x;
                this.MiddlePoints(pos,1) = x;
            end
        end
    
        function [bRetVal,orientation] = IsMouseInBetween(this,mouse,P1,P2)
            bRetVal = (P1(2) == P2(2)) && (mouse(1) >= min([P1(1),P2(1)])) && (mouse(1) <= max([P1(1),P2(1)])); %&& (mouse(2) < P1(2) +2) && (mouse(2) > P1(2) -2) ;
            if bRetVal
                orientation = 'hor';
                return
            else
                bRetVal = (P1(1) == P2(1)) && (mouse(2) >= min([P1(2),P2(2)])) && (mouse(2) <= max([P1(2),P2(2)])); %&& (mouse(1) < P1(1) +2) && (mouse(1) > P1(1) -2);
                orientation = 'ver';
            end
            
            if ~bRetVal
                bRetVal = true;
                orientation = 'hor';
            end
        end
        
        
        function objH = FindHandle(this)
            for i = 1: numel(this.HandlesList)
                objH = this.HandlesList{i};
                if objH.ObjDrag
                    return
                end
            end            
            objH = [];
        end
        
        
        function setAllHandlesDragOff(this)
            for i = 1: numel(this.HandlesList)
                objH = this.HandlesList{i};
                objH.ObjDrag = false;
            end            
        end
    
    
    end

    
    
    
    methods (Static)
       
        function bRet = IsNode(Obj)       
            bRet = isa(Obj,'NodeObj');
        end
        
        
        function [XRange,YRange] = CalculateXYvectors(CornerList)
            XRange = [];
            YRange = [];
            XDiscPos = CornerList(:,1);
            YDiscPos = CornerList(:,2);

            nPosElement = numel(XDiscPos); 
            for i = 1 : nPosElement-1
               X1 = XDiscPos(i);
               X2 = XDiscPos(i+1);
               Y1 = YDiscPos(i);
               Y2 = YDiscPos(i+1);
                
               nX = round((max([X1,X2]) - min([X1,X2]))/1 + 1);
               nY = round((max([Y1,Y2]) - min([Y1,Y2]))/1 + 1);
               
               if nX ~=1 && nY ~=1
                   %keyboard
                   warning('this should not happen')
               end
               
               if nX ==1 && nY ==1
                   %keyboard
                   %warning('this should not happen')
                   
               end
               
               XRange_temp = linspace(X1,X2,nX);
               YRange_temp = linspace(Y1,Y2,nY);
               
               if nX > nY
                  YRange_temp = repmat(YRange_temp,1,nX);                   
               else
                   XRange_temp = repmat(XRange_temp,1,nY);
               end
               XRange = [XRange,XRange_temp];
               YRange = [YRange,YRange_temp];
            end
        end
        
        function bret = CheckCpos(Cx,Cy,Obj,Anchor,ObjAncorPos)
            if numel(Cx)>1 || numel(Cy)>1
                bret = true;
                return
            end
            bret = false;
            if Obj.ObjOrientation == 1
                if strcmp(LineObj.GetAnchorClass(Anchor),'A')
                    if Cy >= ObjAncorPos(2)
                        bret = true;
                    end
                elseif strcmp(LineObj.GetAnchorClass(Anchor),'B')
                    if Cy <= ObjAncorPos(2)
                        bret = true;
                    end
                end  
            end
            
            if Obj.ObjOrientation == 2
                if strcmp(LineObj.GetAnchorClass(Anchor),'A') 
                    if Cx <= ObjAncorPos(1)
                        bret = true;
                    end
                elseif strcmp(LineObj.GetAnchorClass(Anchor),'B') 
                    if Cx >= ObjAncorPos(1)
                        bret = true;
                    end
                end  
            end
            
            
            if Obj.ObjOrientation == 3
                if strcmp(LineObj.GetAnchorClass(Anchor),'A')
                    if Cy <= ObjAncorPos(2)
                        bret = true;
                    end
                elseif strcmp(LineObj.GetAnchorClass(Anchor),'B')
                    if Cy >= ObjAncorPos(2)
                        bret = true;
                    end
                end  
            end
            
            
            if Obj.ObjOrientation == 4
                if strcmp(LineObj.GetAnchorClass(Anchor),'A') 
                    if Cx >= ObjAncorPos(1)
                        bret = true;
                    end
                elseif strcmp(LineObj.GetAnchorClass(Anchor),'B')
                    if Cx <= ObjAncorPos(1)
                        bret = true;
                    end
                end  
            end
        end
        
        
        
        
        function  [Xs,Ys,type] = DecideConnectionShape(ObjLine,A,B,ObjA,ObjB, offset)
            AnchIdxObjA = ObjLine.AnchorObjA(2);
            AnchIdxObjB = ObjLine.AnchorObjB(2);
            
            % objA vertical and ObjB horizontal
            if ObjA.ObjOrientation == 1 || ObjA.ObjOrientation == 3 
                if ObjB.ObjOrientation == 2 || ObjB.ObjOrientation == 4
                    Xs = A(1);
                    Ys = B(2);
                    type = 'XA1YB2';
                    return
                end
            end
            % objA  horizontal and ObjB vertical
            if ObjA.ObjOrientation == 2 || ObjA.ObjOrientation == 4 
                if ObjB.ObjOrientation == 1 || ObjB.ObjOrientation == 3
                    Xs = B(1);
                    Ys = A(2);
                    type = 'XB1YA2';
                end
            end
            % Both Objects are horizontal  % Need two extra points (C and D)
            if ObjA.ObjOrientation == 2 || ObjA.ObjOrientation == 4 
                if ObjB.ObjOrientation == 2 || ObjB.ObjOrientation == 4
                    if  A(1) == max([ObjA.(['A',AnchIdxObjA])(1),ObjA.(['B',AnchIdxObjA])(1)] + ObjA.Xo + offset)
                        connA = 'right';
                    else
                        connA = 'left';
                    end
                    
                    if  B(1) == max([ObjB.(['A',AnchIdxObjB])(1),ObjB.(['B',AnchIdxObjB])(1)] + ObjB.Xo + offset)
                        connB = 'right';
                    else
                        connB = 'left';
                    end
                    
                    if strcmp(connB,connA) % need only 1 point 
                        type = 'XA1YB2';
                        Xs = A(1);
                        Ys = B(2);
                    else  % need two points 
                        Deltax = max([A(1),B(1)]) - min([A(1),B(1)]);
                        if Deltax == 1
                            type = 'XA1YB2';
                            Xs = A(1);
                            Ys = B(2);
                            return
                        end
                        xc = round(min([A(1),B(1)]) +Deltax/2);
                        yc = A(2);
                        xd = xc;
                        yd = B(2);
                        type = '2H_CYADYB';
                        Xs = [xc,xd];
                        Ys = [yc,yd];
                    end
                    return
                end
            end
            % Both Objects are vertical   % Need two extra points (C and D)
            if ObjA.ObjOrientation == 1 || ObjA.ObjOrientation == 3 
                if ObjB.ObjOrientation == 1 || ObjB.ObjOrientation == 3
                    
                    if  A(2) == max([ObjA.(['A',AnchIdxObjA])(2),ObjA.(['B',AnchIdxObjA])(2)] + ObjA.Yo + offset)
                        connA = 'high';
                    else
                        connA = 'low';
                    end
                    
                    if  B(2) == max([ObjB.(['A',AnchIdxObjB])(2),ObjB.(['B',AnchIdxObjB])(2)] + ObjB.Yo + offset)
                        connB = 'high';
                    else
                        connB = 'low';
                    end
                    if strcmp(connB,connA) % need only 1 point 
                        type = 'XA1YB2';
                        Xs = A(1);
                        Ys = B(2);
                    else  % need two points 
                        Deltay = max([A(2),B(2)]) - min([A(2),B(2)]);
                        if Deltay == 1
                            type = 'XA1YB2';
                            Xs = A(1);
                            Ys = B(2);
                            return
                        end
                        yc = round(min([A(2),B(2)]) + Deltay/2);
                        xc = A(1);
                        yd = yc;
                        xd = B(1);
                        type = '2V_CXADXB';
                        Xs = [xc,xd];
                        Ys = [yc,yd];
                    end
                    return
                end
            end
        end
        
        
        
        function [Cx,Cy,type] = ChangeConnType(type,A,B)
            if strcmpi(type,'XA1YB2')
                type = 'XB1YA2';
                Cx = B(1);
                Cy = A(2);
            elseif strcmpi(type,'XB1YA2')
               type = 'XA1YB2';
                Cx = A(1);
                Cy = B(2);
            elseif strcmpi(type,'2H_CYADYB')
                xc = A(1);
                yc = min([A(2),B(2)])-5;
                xd = B(1);
                yd = yc;
                Cx = [xc,xd];
                Cy = [yc,yd];
                type = '2H_CXADXB';
            elseif strcmpi(type,'2V_CXADXB')
                xc = min([A(1),B(1)])-5;
                yc = A(2);
                xd = xc;
                yd = B(2);
                Cx = [xc,xd];
                Cy = [yc,yd];
                type = '2V_CYADYB';
                
            end
        end
        
        
        
        
        function CheckForInterconnections(LineRef,Line)
            if isempty(LineRef.ObjA) || isempty(LineRef.ObjB) || isempty(Line.ObjA) || isempty(Line.ObjB)
                return
            end
            bRet = false;
            if eq(LineRef.ObjA,Line.ObjA)
                if strcmp(LineRef.AnchorObjA,Line.AnchorObjA)
                    bRet = true;
                    start = numel(LineRef.AllCorners(:,1));;
                    finish = 1;
                    step = -1;
                end
            end       
            if eq(LineRef.ObjA,Line.ObjB)
                if strcmp(LineRef.AnchorObjA,Line.AnchorObjB)
                    bRet = true;
                    start = numel(LineRef.AllCorners(:,1));;
                    finish = 1;
                    step = -1;
                end
            end
            if eq(LineRef.ObjB,Line.ObjA)
                if strcmp(LineRef.AnchorObjB,Line.AnchorObjA)
                    bRet = true;
                    start = 1;
                    finish = numel(LineRef.AllCorners(:,1));
                    step = 1;
                end
            end
            if eq(LineRef.ObjB,Line.ObjB)
                if strcmp(LineRef.AnchorObjB,Line.AnchorObjB)
                    bRet = true;
                    start = 1;
                    finish = numel(LineRef.AllCorners(:,1));
                    step = 1;
                end
            end
            
            if ~bRet
                return
            end 

            XLine = Line.GrSubObj{1}.XData;
            YLine = Line.GrSubObj{1}.YData;
            
            
            for i = start : step : finish
                Pref = LineRef.AllCorners(i,:);
               if ~isempty(Pref)
                  Xidx = Pref(1) == XLine;
                  Yidx = Pref(2) == YLine;
                  Res = sum([Xidx;Yidx],1);
                  ResIdx = Res == 2;
                  if any(ResIdx)
                      if i ~= start && i ~= finish    
                            LineRef.SwithNodeVisibility(['Node',num2str(i)],'on')
                      end
                      break
                  else
                     %LineRef.SwithNodeVisibility(['Node',num2str(i)],'off')
                  end
               end
            end
        
        end
        
        
        
        function AnchorClass =  GetAnchorClass(anchor)
            % taking the first char in the char vector. it should be either
            % A or B
            AnchorClass = anchor(1);
            if strcmp(AnchorClass,'A') || strcmp(AnchorClass,'B')
                return
            else
                error('Wrong Anchor Name assigned')
            end
        end
        
        
    end
    
end