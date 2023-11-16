classdef SchematicManager < handle
    
   properties
     Fig
     SchematicAxes
     XYRatio
     cmenu
     %Maps
     componentNameTypeMap
     componentNameObjMap
     componentNameAliasMap % not used
     componentNameListenerMap
     
     
     currentLineObj
     currentCompObj
     
     SelectionRectangle
     
     Xpos
     Ypos
     
     %flags
     DrawConnectionFlag = false;
     selectMultiObjectFlag = false;
     MultiSelectionFlag = false;
     AllowComponentDragAndDrop
     
     %Lists
     componentList
     connectionList
     
     componentParametersDef

     Mode
     
     DDB
     Listeners
     
   end
   
   events
       UnselectAllComponents
   end
   
   
   methods
      
       function this  = SchematicManager(Ax,Fig,myDDB)
           this.Fig = Fig;
           this.SchematicAxes = Ax;
           this.DDB = myDDB;
           this.SchematicAxes.ButtonDownFcn = @this.ButtonDownFcn;
           this.componentNameTypeMap = containers.Map('KeyType','char','ValueType','char'); 
           this.componentNameObjMap = containers.Map('KeyType','char','ValueType','any'); 
           this.componentNameListenerMap = containers.Map('KeyType','char','ValueType','any'); 
           this.AllowComponentDragAndDrop = true;
           this.GetXYSchematicRatio();
           if ~this.isuifigure()
                this.SetContextMenu();
           else
               this.SetToolbar
           end
           this.DefineComponentParam()
           this.Listeners{1} = addlistener(this,'UnselectAllComponents',@this.TriggerUnselectAllComponentsEvent);
       end
       
       function SaveCallBack(this,src,event)
            this.Save()
       end
       
       function Save(this)
           
            this.CreateComponentList()
            this.CreateConnectionList()
            
       end
       
       function [CompList,ConnList] = ExportCompConnList(this)
           CompList = this.componentList;
           ConnList= this.connectionList;
       end
       
       function CreateComponentList(this)
           this.ClearComponentList()
           components = keys(this.componentNameTypeMap);
           idx = 1;
           for nComp = 1: numel(components)
               compName = components{nComp};
               type = this.componentNameTypeMap(compName);
               if strcmp(type,'Line')
                   continue
               end
               component = this.componentNameObjMap(compName);
               this.componentList{idx,1} = compName;
               this.componentList{idx,2} = type;
               this.componentList{idx,3} = component.Xo;
               this.componentList{idx,4} = component.Yo;
               this.componentList{idx,5} = component.Parameters;
               this.componentList{idx,6} = component.ObjOrientation;
               ConnList = {};
               for nConn = 1 : numel(component.ConnectionLineList)
                   conn = component.ConnectionLineList{nConn}.Name;
                   ConnList = [ConnList,conn];
               end
               this.componentList{nComp,7} = ConnList;
               AdditionalInfo = {};
               if strcmp(type,'Transformer')
                    AdditionalInfo{1} =  component.nSec;
                    AdditionalInfo{2} =  component.bPrimBias;
                    AdditionalInfo{3} =  component.bSecBiasFlag;
               end
               this.componentList{nComp,8} = AdditionalInfo;
               idx = idx + 1;
           end
           
       end
       
       function ClearComponentList(this)
            this.componentList = [];
       end
       
       function CreateConnectionList(this)
           this.ClearConnectionList()
           connections = keys(this.componentNameTypeMap);
            idx = 1;
           for nConn = 1: numel(connections)
               connName = connections{nConn};
               type = this.componentNameTypeMap(connName);
               if ~strcmp(type,'Line')
                   continue
               end
               connection = this.componentNameObjMap(connName);
               this.connectionList{idx,1} = connName;
               this.connectionList{idx,2} = connection.ObjAName;
               this.connectionList{idx,3}=  connection.AnchorObjA;
               this.connectionList{idx,4} = connection.ObjBName;
               this.connectionList{idx,5} = connection.AnchorObjB;
               this.connectionList{idx,6} = connection.AllCorners;
               this.connectionList{idx,7} = connection.UserOverwrite;
               
               idx = idx + 1;
           end
       end
       
       function ClearConnectionList(this)
            this.connectionList = [];
       end
       
       function UpdateConnectionList(this)
       
       end
       
       function UpdateComponentList(this)
       
       end
       
       function SetYXAxLimits(this,xlim,ylim)
            this.SchematicAxes.Xlim = xlim;
            this.SchematicAxes.Ylim = ylim;
       end
       
      
       function Open(this,ComponentList,ConnectionList)
           
           
           nConnFileds = size(ConnectionList,2);
           for ncomp = 1 : size(ComponentList,1) 
              name = ComponentList{ncomp,1};
              if isempty(name)
                  continue
              end
              type = ComponentList{ncomp,2}; 
              Xo = ComponentList{ncomp,3};
              Yo = ComponentList{ncomp,4};
              AdditionalInfo = ComponentList{ncomp,8};
              this.AddComponents(type,name,Xo,Yo,AdditionalInfo)
              Orientation = ComponentList{ncomp,6};
              obj = this.componentNameObjMap(name);
              for OrienIdx = 1 : Orientation-1
                  obj.RotateObj()
              end
           end
           
           for nconn = 1 : size(ConnectionList,1)
               connName = ConnectionList{nconn,1};
               ObjAName = ConnectionList{nconn,2};
               AnchorObjA = ConnectionList{nconn,3};
               ObjBName = ConnectionList{nconn,4};
               AnchorObjB = ConnectionList{nconn,5};
               AllCorners = ConnectionList{nconn,6};
               
               if isempty(ObjAName) || isempty(ObjBName)
                   continue  % TO DO: delete the null Line from the componentNameObjMap
               end
               this.AddConnection(ObjAName,AnchorObjA,ObjBName,AnchorObjB,connName)
               obj = this.componentNameObjMap(connName);
               if nConnFileds >6
                obj.UserOverwrite = ConnectionList{nconn,7};
               end
               obj.DrawFromConnectionList(AllCorners)
           end
           
           this.UpdateConnectionLines()
           
       end
           
       
       function UnselectComponents(this,ExceptionProp,PropVal)
           if nargin < 3
              PropVal = [];
              ExceptionProp = [];
           end
           [value,objList] = this.FindObjbyProperty({'ObjSelected'},{true});
            if value
                for i = 1 : numel(objList)
                    obj = objList{i};
                    if isempty(ExceptionProp)
                        obj.SetSelectionStatus(false)
                    elseif ~ischar(PropVal{1}) && obj.(ExceptionProp{1}) == PropVal{1}
                        continue
                    elseif ischar(PropVal{1}) && strcmp(obj.(ExceptionProp{1}),PropVal{1})
                        continue
                    else
                        obj.SetSelectionStatus(false)
                    end
                end 
                notify(this,'UnselectAllComponents')
            end
       end
       
       
       function ButtonDownFcn(this,src,event)
%            disp(event.IntersectionPoint)
%            return
%            keyboard
        %  if user clicks on blank space all objects are deselected   
             this.UnselectComponents()
             
            if this.selectMultiObjectFlag
                if isempty(this.SelectionRectangle)
                    pos = get(this.SchematicAxes,'CurrentPoint');
                    x = pos(1,1);  % x grid with delta X  = 1
                    y = pos(1,2);  % y grid with delta Y  = 1
                    [X,Y] = SchematicManager.getXYfromPos(x,y,0.1,0.1);
                     this.SelectionRectangle = patch('XData',X,'YData',Y,'FaceColor','none','EdgeColor','r','LineStyle',':');
                     return
               end
            end
            
           PreList = this.GetObjListbyClass('LineObj');
           for i = 1 : numel(PreList)
              obj = PreList{i};
              for j = 1 : obj.nHandles
                obj.HandlesList{j}.SetVisibility('Off')
              end
           end
       end
       
      function SetToolbar(this)
            SchematicTB = axtoolbar(this.SchematicAxes,{'zoomin','zoomout','pan'});
            btn = axtoolbarbtn(SchematicTB,'push');
            btn.Icon = 'multiselect.png';
            btn.Tooltip = 'Multi-Select';
            btn.ButtonPushedFcn  = @this.SelectMultipleObjects;
        end
       
       function SetContextMenu(this)
        this.cmenu = uicontextmenu;
        try
            this.SchematicAxes.UIContextMenu = this.cmenu;
        catch
            
        end
            menu1 = uimenu('Parent',this.cmenu,'Label','Multi-Select','Callback',@this.SelectMultipleObjects);
            menu1 = uimenu('Parent',this.cmenu,'Label','Clear all','Callback',@this.RemoveAllCallBack);
            menu1 = uimenu('Parent',this.cmenu,'Label','Save','Callback',@this.SaveCallBack);
       end
       
       
       
       
       function GetXYSchematicRatio(this)
            this.XYRatio = 183/440;
       end
       
       
       function AddComponents(this,type,name,Xo,Yo,AdditionalInfo)
           if nargin < 3 || isempty(name)
               name = 'NaN';
           end
           if nargin < 4
               Xo = 0;
           end
           if nargin <5
               Yo = 0;
           end
           if nargin < 6
               AdditionalInfo = [];
           end
               
           switch type
               case 'Inductor'
                   VerifiedName = this.VerifyName(name,'Inductor');
                   Obj = InductorObj(this, VerifiedName,Xo,Yo);
               case 'Resistor'
                   VerifiedName = this.VerifyName(name,'Resistor');
                   Obj = ResistorObj(this, VerifiedName,Xo,Yo);
               case 'Capacitor'
                   VerifiedName = this.VerifyName(name,'Capacitor');
                   Obj = CapacitorObj(this, VerifiedName,Xo,Yo,EComponentType.Capacitor);
               case 'ElectrolyticCapacitor'
                   VerifiedName = this.VerifyName(name,'Capacitor');
                   Obj = CapacitorObj(this, VerifiedName,Xo,Yo,EComponentType.ElectrolyticCapacitor);
               case 'Diode'
                   VerifiedName = this.VerifyName(name,'Diode');
                   Obj = DiodeObj(this, VerifiedName,Xo,Yo);
               case 'Zener'
                   VerifiedName = this.VerifyName(name,'Zener');
                   Obj = ZenerObj(this, VerifiedName,Xo,Yo);
               case 'Mosfet'
                   VerifiedName = this.VerifyName(name,'Mosfet');
                   Obj = MosfetObj(this, VerifiedName,Xo,Yo);
               case 'Node'
                   VerifiedName = this.VerifyName(name,'Node');
                   Obj = NodeObj(this, VerifiedName,Xo,Yo);
               case 'Pin'
                   VerifiedName = this.VerifyName(name,'Pin');
                   Obj = PinObj(this, VerifiedName,Xo,Yo);
               case 'Line'
                   VerifiedName = this.VerifyName(name,'Line');
                   Obj = LineObj(this, VerifiedName);
               case 'Fuse'
                   VerifiedName = this.VerifyName(name,'Fuse');
                   Obj = FuseObj(this, VerifiedName,Xo,Yo);
               case 'CMChoke'
                   VerifiedName = this.VerifyName(name,'CMChoke');
                   Obj = CommonModeChokeObj(this, VerifiedName,Xo,Yo);
               case 'Transformer'
                   if isempty(AdditionalInfo)
                        nSec = [];bPrimBias = [];bSecBias =[]; 
                   else
                       nSec = AdditionalInfo{1};
                       bPrimBias = AdditionalInfo{2};
                       bSecBias = AdditionalInfo{3};
                   end
                   VerifiedName = this.VerifyName(name,'Transformer');
                   Obj = TransformerObj(this, VerifiedName,Xo,Yo,nSec,bPrimBias,bSecBias);
               case 'Bridge'
                   VerifiedName = this.VerifyName(name,'Bridge');
                    Obj = BridgeObj(this, VerifiedName,Xo,Yo);
               case 'InnoSwitch3CE'
                   VerifiedName = 'InnoSwitch3CE';
                   Obj = InnoSwitchObj(this, VerifiedName,Xo,Yo,EComponentType.InnoSwitch3CE);
               case 'InnoSwitch3EP'
                   VerifiedName = 'InnoSwitch3EP';
                   Obj = InnoSwitchObj(this, VerifiedName,Xo,Yo,EComponentType.InnoSwitch3EP);
               case 'InnoSwitch3CP'
                   VerifiedName = 'InnoSwitch3CP';
                   Obj = InnoSwitchObj(this, VerifiedName,Xo,Yo,EComponentType.InnoSwitch3CP);
               case 'InnoSwitch3Pro'
                   VerifiedName = 'InnoSwitch3Pro';
                   Obj = InnoSwitchObj(this, VerifiedName,Xo,Yo,EComponentType.InnoSwitch3Pro);
               case 'Ground'
                   VerifiedName = this.VerifyName(name,'Ground');
                   Obj = GNDObj(this, VerifiedName,Xo,Yo);
                case 'PotentialReference'
                   VerifiedName = this.VerifyName(name,'PotentialReference');
                   Obj = PotentialRefObj(this, VerifiedName,Xo,Yo);
               otherwise
                   warning('Component does not Exist')
                   return
           end
           this.componentNameTypeMap(VerifiedName) = type;
           %this.componentNameAliasMap(VerifiedName) = VerifiedName;  % alias to Name   When intialiazed alias = name
           this.componentNameObjMap(VerifiedName) = Obj;
           this.componentNameListenerMap(VerifiedName) = Obj.Listener;
           this.SortAxesChildren('AnchorPointFisrt')
           
       end
       
       function AddConnection(this,CompA,AnchoreCompA,CompB,AnchoreCompB,ConnName)
           if nargin < 6
               ConnName = 'NaN';
           end
           this.InitilizeConnection(ConnName)
           foundA = isKey(this.componentNameObjMap,CompA);
            if foundA
                objA = this.componentNameObjMap(CompA);
            else
                warning('Component 1 not found')
            end
            foundB = isKey(this.componentNameObjMap,CompB);
            if foundB
                objB = this.componentNameObjMap(CompB);
            else
                warning('Component 2 not found')
            end
            this.currentLineObj.SetObjA(objA)
            this.currentLineObj.SetAnchorA(AnchoreCompA)
            this.currentLineObj.SetObjB(objB)
            this.currentLineObj.SetAnchorB(AnchoreCompB)
            
            this.currentLineObj.ConnectByAnchore()
            
            %this.currentLineObj.CreateGrObj()
            this.currentLineObj.Draw();
            this.currentLineObj = [];  % clearing the palceholder
       end
       
       
       function InitilizeConnection(this,name)
           if nargin <2
            name = 'NaN';
           end
           VerifiedName = this.VerifyName(name,'Line');
           Line = LineObj(this, VerifiedName);
           Line.CreateGrObj();
           this.currentLineObj = Line;  % latest line drawn
           this.componentNameTypeMap(VerifiedName) = 'Line';
           this.componentNameObjMap(VerifiedName) = Line;
           this.componentNameListenerMap(VerifiedName) = {};
           this.SortAxesChildren('AnchorPointFisrt')
       end
       
       function RemoveSchematicObjectsByClassAndObj(this,Obj,class)
           a =1;
           Anchors = findobj(Ax,'Tag','AnchorPoint');
           
       end
       
       function RemoveSchematicObjectsByName(this,name)
            found = isKey(this.componentNameObjMap,name);
            if found
                Obj = this.componentNameObjMap(name);
                if isa(Obj,'ComponentObj')
                    LineList  = Obj.ConnectionLineList;
                    for i = numel(LineList):-1:1
                        LineName  = LineList{i}.Name;
                        this.RemoveSchematicObjectsByName(LineName)
                    end
                end
                if isa(Obj,'LineObj')
                    if ~isempty(Obj.ObjA)
                        Obj.ObjA.UpdateConnectionLineList(Obj,'Remove')
                    end
                    if ~isempty(Obj.ObjB)
                        Obj.ObjB.UpdateConnectionLineList(Obj,'Remove')
                    end
                end
                this.RemoveObjAnchorePoints(Obj)
                this.RemoveObjfromMaps(name)
            else
                warning('Object not found')
                return
            end
            obj = findobj(this.SchematicAxes,'Tag',name);
            delete(obj);
       end
       
       function RemoveAllCallBack(this,src,event)
            this.RemoveAll()
       end
       
       function RemoveAll(this)
           KeyList = keys(this.componentNameObjMap);
           for i = 1: numel(KeyList)
               key = KeyList{i};
               Obj = this.componentNameObjMap(key);               
               this.RemoveObjAnchorePoints(Obj);
               this.RemoveObjfromMaps(key)
               
               obj = findobj(this.SchematicAxes,'Tag',key);
               delete(obj)
           end 
       end
       
       function RemoveObjfromMaps(this,key)
               remove(this.componentNameListenerMap,key)
               remove(this.componentNameObjMap,key)
               remove(this.componentNameTypeMap,key)
       end
       
       function RemoveObjAnchorePoints(this,Obj)
           subObjList  = Obj.GrSubObj;
           for  j  = 1:numel(subObjList)
                if strcmp(subObjList{j}.Tag,'AnchorPoint') %|| strcmp(subObjList{j}.Tag,'AnchorPoint')
                    this.findAndDeleteAxChildren(subObjList{j})
                end
           end
       end
       
       function findAndDeleteAxChildren(this,obj)
      
           for i = 1 : numel(this.SchematicAxes.Children)
                if eq(this.SchematicAxes.Children(i),obj)
                    delete(this.SchematicAxes.Children(i))
                    return
                end
           end
       end
       
       
     function  UpdateConnectionLines(this)
        this.SwitchAllNodesOff()
        this.SwitchOnConnectionNodes()
     end
       
       
      function SwitchOnConnectionNodes(this)
          
          
        compKeys = keys(this.componentNameObjMap);
          
        for compKeyidx = 1:numel(compKeys)
            comp = this.componentNameObjMap(compKeys{compKeyidx});
            if isa(comp,'LineObj')
                continue
            end
            if numel(comp.ConnectionLineList)==1
                continue
            else
                LineList = comp.ConnectionLineList;
            end
            for i = 1: numel(LineList)
                LineRef = LineList{i};
                for j = 1: numel(LineList)
                    LineTarget = LineList{j};
                    if eq(LineTarget,LineRef)
                        continue
                    end
                    LineObj.CheckForInterconnections(LineRef,LineTarget)
                end
            end
            
        end
            
            
        
        LineList = this.GetObjListbyClass('LineObj');
        for i = 1: numel(LineList)
           LineRef = LineList{i};
           for j = 1 : numel(LineList)
               Line = LineList{j};
               if eq(Line,LineRef)
                   continue
               end
               LineObj.CheckForInterconnections(LineRef,Line);
           end
           
            
        end
      end
        
      
      function SwitchAllNodesOff(this)
          LineList = this.GetObjListbyClass('LineObj');
        for i = 1: numel(LineList)
           Line = LineList{i};
           for j = 1 : numel(Line.AllCorners)
                Line.SwithNodeVisibility(['Node',num2str(j)],'off')
           end
        end
      end 
      
      function objList = GetObjListbyClass(this,class)
          objList = {};
          keyList  = keys(this.componentNameObjMap);
          for i = 1: numel(keyList)
             obj = this.componentNameObjMap(keyList{i});
             if isa(obj,class)
              objList{end+1} = obj;
             end
          end
      end
       
       function VerifiedName = VerifyName(this,name,type)
               switch type
                   case 'Inductor'
                        prefix = 'L';
                   case 'Resistor'
                        prefix = 'R';
                   case 'Capacitor'
                        prefix = 'C';
                   case 'Diode'
                        prefix = 'D';
                   case 'Zener'
                        prefix = 'Z';
                   case 'Mosfet'
                       prefix = 'Q';
                   case 'Node'
                        prefix = 'N'; 
                   case 'Line'
                       prefix = 'W';
                   case 'Pin'
                       prefix = 'P';
                   case 'Fuse'
                       prefix = 'F';
                   case 'CMChoke'
                       prefix = 'CM';
                   case 'Transformer'
                       prefix = 'TR';
                   case 'Bridge'
                       prefix = 'BR';
                   case 'Ground'
                       prefix = 'GND';
                   case 'PotentialReference'
                       prefix = 'PR';
               end
 
           bRet = false;
           i = 1;
           
           while ~bRet       
                bRet = ~isKey(this.componentNameTypeMap,name) && ~strcmp(name,'NaN');
                if bRet 
                    VerifiedName = name;
                    break
                end
                name = [prefix,num2str(i)];
                i =  i + 1; 
           end
       end
       
       
       
       
       function [bRet,ObjList] = FindObjbyProperty(this, Props, PropValues)
           ObjList  = values(this.componentNameObjMap);
           bRet = false;
           nProp = 1;
           if ~iscell(Props)
               Props = {Props};
           end
           if ~iscell(PropValues)
               PropValues = {PropValues};
           end
           while nProp <= numel(Props)
               prop = Props{nProp};
               propValue = PropValues{nProp};
               [ObjList,bRet] = this.FilterObjbyProperty(ObjList,prop,propValue);
               nProp = nProp + 1;
           end
       end
       
       
       function [ObjList,bRet] = FilterObjbyProperty(this,List,prop,propValue)
           ObjList = {};
            bRet = false;
            for i = 1: numel(List)
               obj  = List{i};
               propList = properties(obj);
               idx = ismember(propList,prop);
               if any(idx)
                   if ~ischar(propValue) && obj.(propList{idx}) == propValue
                       ObjList{end+1} = obj; 
                       bRet = true;
                   elseif ischar(propValue) && strcmp(obj.(propList{idx}),propValue)
                       ObjList{end+1} = obj; 
                       bRet = true;
                       
                   end
               end
            end
       end
        
       
       function List = FindObjByCoordianteRange(this,xmin,xmax,ymin,ymax)
            List = {};
           PreList = GetObjListbyClass(this,'ComponentObj');
           for i = 1 : numel(PreList)
              obj = PreList{i};
              if obj.Xo < xmax && obj.Xo > xmin && obj.Yo < ymax && obj.Yo > ymin 
                  List{end+1} = obj;
              end
           end
       end
       
       
       function  [obj] = FindAnchorsByCoordinate(this,x,y)
           objList = findobj(this.SchematicAxes,'Tag','AnchorPoint');
           %objList = [objList,findobj(this.SchematicAxes,'Tag','AnchorPointB')];
           obj = [];
           for i = 1 : numel(objList)
                anchorPoint = objList(i);
                anchorPoint.EdgeColor = 'none';
                anchorPoint.FaceColor = 'none';
                if x < max(anchorPoint.XData) && x > min(anchorPoint.XData)
                  if y < max(anchorPoint.YData) && y > min(anchorPoint.YData)
                        obj = anchorPoint;
                      break
                  end
                end  
           end
       
       end
       
       function ClearCurrentLine(this)
            this.currentLineObj = [];
       end
       
       
       function connectObjects(this,obj1,obj2)
           
           if ~NodeObj.IsNode(obj1) && ~NodeObj.IsNode(obj2)
               needAddNode = true;
               % Need to insert one (invisible?) node in the middle
           else
               needAddNode = false;
           end
       end
       
       function SortAxesChildren(this,type)
           Ax = this.SchematicAxes;
           ChildrenList = Ax.Children;
           switch type
               case 'AnchorPointFisrt'
                  Anchors = findobj(Ax,'Tag','AnchorPoint');
                  %AnchorBs = findobj(Ax,'Tag','AnchorPointB');
                  ChildrenList = RemoveAxChildrenbyTag(this,ChildrenList,'AnchorPoint');
                  Ax.Children = [Anchors;ChildrenList];
                  
               case 'SelectedLineFirst'
                   Ax = this.SchematicAxes;
                   [bRet,ObjList] = this.FindObjbyProperty({'ObjSelected','Family'},{true,EComponentType.Line});
                   for i = 1 : numel(ObjList)
                       LineObj  = ObjList{i};
                       Name = LineObj.Name;
                       Line = findobj(Ax,'Tag',Name);
                       ChildrenList = [Line;RemoveAxChildrenbyTag(this,ChildrenList,Name)];
                       this.SchematicAxes.Children = ChildrenList;
                   end
           end
       end
       
       function ChildrenList = RemoveAxChildrenbyTag(this,ChildrenList,myTag)
          nElement = numel(ChildrenList);
          for i = nElement : -1 : 1
              if strcmp(ChildrenList(i).Tag,myTag)
                  ChildrenList(i) = [];
                  continue
              end
          end
       end
       
       
       function HighlightAllAnchorPoint(this)
           Ax = this.SchematicAxes;
           ChildrenList = Ax.Children; 
           nElement = numel(ChildrenList);
          for i = 1: nElement
              if strcmp(ChildrenList(i).Tag,'AnchorPoint')
                  ChildrenList(i).FaceColor = 'red';
                  ChildrenList(i).EdgeColor = 'red';
                  continue
              end
%               if strcmp(ChildrenList(i).Tag,'AnchorPointB')
%                   ChildrenList(i).FaceColor = 'red';
%                   ChildrenList(i).EdgeColor = 'red';
%                   continue
%               end
          end
       end
       
       function DehighlightAllAnchorPoint(this)
           Ax = this.SchematicAxes;
           ChildrenList = Ax.Children; 
           nElement = numel(ChildrenList);
          for i = 1: nElement
              if strcmp(ChildrenList(i).Tag,'AnchorPoint')
                  ChildrenList(i).FaceColor = 'none';
                  ChildrenList(i).EdgeColor = 'none';
                  continue
              end
%               if strcmp(ChildrenList(i).Tag,'AnchorPointB')
%                   ChildrenList(i).FaceColor = 'none';
%                   ChildrenList(i).EdgeColor = 'none';
%                   continue
%               end
          end
       end
       
       function SelectMultipleObjects(this,src,event)
           this.selectMultiObjectFlag = true;
           disp('MultiSelct ON')
          % this.Fig.Pointer = 'crosshair';
       end
       
       function bRet  = isuifigure(this)
           myFig = this.Fig;
            bRet =  matlab.ui.internal.isUIFigure(myFig);
       end
       
       function TriggerUnselectAllComponentsEvent(this,src,event)
        %this.DDB.Gui.ClearCompTableOnComponentUnselect()
       end
       
       %External methods definitions
       DefineComponentParam(this)
   
       
       
   end
   
   
   
   methods(Static)

       function [X , Y] = getXYfromPos(x,y,w,h)
           X = [x, x + w, x + w, x];
           Y = [y, y , y + h, y + h];
       end

   end
       
   
    
    
end