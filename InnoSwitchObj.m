classdef InnoSwitchObj < ComponentObj
    
   
    properties
        A2, B2,
        A3, B3,
        A4, B4,
        A5, B5,
        A6, B6,
        A7, B7,
        A8, B8,
    end
    
    
    methods
        
        function this  = InnoSwitchObj(SchManager, compName,compXo,compYo,ControllerType)
            
            this@ComponentObj(SchManager,compName,compXo,compYo,ControllerType)
            this.GrObj = hggroup('Parent',SchManager.SchematicAxes,'Tag',compName);
            this.CreateGrObj() % Populate The  graphicObj 
            this.DisplayGrObj()
            this.GrObj.ButtonDownFcn = @this.ClickOnComponent;
            
            if ~SchManager.isuifigure()
                 this.GrObj.UIContextMenu = this.cmenu;
            end
        end
        
        
        function CreateGrObj(this)
            this.Xlim = 27;
            this.Ylim = 8;
            PH= 16;  % Pin Height
            
             X = [-70 -70 +70 +70];
             Y  = [+10 -10 -10 +10];   
            outbody = patch('XData',X,'YData',Y,'FaceColor','white','EdgeColor','black','LineWidth',1.5,'Parent',this.GrObj,'Tag','body');
            outbody.HitTest = 'off';
            outbody.UserData.Defaults.XData = X;
            outbody.UserData.Defaults.YData = Y; 
            
            X = [-48 -48 -30 -30];
            Y  = [+5 -5 -5 +5];   
            primController = patch('XData',X,'YData',Y,'FaceColor','white','EdgeColor','black','LineWidth',1.5,'Parent',this.GrObj,'Tag','body');
            primController.HitTest = 'off';
            primController.UserData.Defaults.XData = X;
            primController.UserData.Defaults.YData = Y; 
            
            
            
             X = [-20 -20 +65 +65];
            Y  = [+5 -5 -5 +5];   
            secondController = patch('XData',X,'YData',Y,'FaceColor','white','EdgeColor','black','LineWidth',1.5,'Parent',this.GrObj,'Tag','body');
            secondController.HitTest = 'off';
            secondController.UserData.Defaults.XData = X;
            secondController.UserData.Defaults.YData = Y; 
            
            
            %fluxlink
            X = [-30 -20];
            Y  = [0 0];   
            
            %mosfet
            X = [X, NaN,-62 -62 -56 -56 -62 -62] ;
            Y = [Y, NaN,+PH  +5  +5   -5  -5  -PH];
            
            this.A1 = [-62,PH];
            this.B1 = [-62,-PH];
            [DrainAnch,SourceAnch] = this.CreateAnchorPoint();
            
            lableDPin = this.CreateLable(-62+1,PH-3,'D');
            lableSPin = this.CreateLable(-62+1,-PH+3,'S');
            
            %Gate
            X = [X, NaN,-53 -53] ;
            Y = [Y, NaN,+5   -5];
            
            %conn
            X = [X, NaN,-53 -48];
            Y = [Y, NaN,0   0]; 
            
            %VPin
            X1 = [-39 -39];
            Y1 = [+PH +5];
            X = [X, NaN, X1]; 
            Y = [Y, NaN, Y1];

            x = X1(1)+1;
            y = PH-2;
            lableVPin = this.CreateLable(x,y,'V');
            
            %BPPPin
            X1 = [-42 -42];
            Y1 = [-PH -5];
            X = [X, NaN, X1]; 
            Y = [Y, NaN, Y1];

            x = X1(1)+1;
            y = -PH+3;
            lableBPPPin = this.CreateLable(x,y,'BPP');
            
            this.A2 = [-39, PH];
            this.B2 = [-42, -PH];
            [VPinAnch,BPPPinAnch] = this.CreateAnchorPoint(2);
            
            %FWDPin
            Space = 14;
            SecStart = -20;  
            X1 = (SecStart+Space*0.5)*[1 1];
            Y1 = [+PH +5];
            X = [X, NaN,X1];
            Y = [Y, NaN,Y1];

            x = X1(1)+1;
            y = PH-3;
            lableFWDPin = this.CreateLable(x,y,'FWD');
             
            this.A3 = [X1(1), Y1(1)];
            this.B3 = [];
            [FWDPinAnch,~] = this.CreateAnchorPoint(3);
            this.B3 = [-X1(1), Y1(1)];
            
            %SRPin
            X1 = (SecStart+Space*1.5)*[1 1];
            Y1 = [+PH +5];
            X = [X, NaN, X1];
            Y = [Y, NaN, Y1];

            x = X1(1)+1;
            y = PH-3;
            lableSRPin = this.CreateLable(x,y,'SR');
            
            this.A4 = [X1(1), Y1(1)];
            this.B4 = [];
            [SRPinAnch,~] = this.CreateAnchorPoint(4);
            this.B4 =[-X1(1), Y1(1)];
            
            %BPSPin
            X1 = (SecStart+Space*2.5)*[1 1]; 
            Y1 = [+PH +5];
            X = [X, NaN, X1];
            Y = [Y, NaN, Y1];

            x = X1(1)+1;
            y = PH-3;
            lableBPSPin = this.CreateLable(x,y,'BPS');

            
            this.A5 = [X1(1), Y1(1)];
            this.B5 = [];
            [BPSPinAnch,~] = this.CreateAnchorPoint(5);
            this.B5 = [-X1(1), Y1(1)];
            
            %GNDPin
            X1 = (SecStart+Space*3.5)*[1 1];  
            Y1 = [+PH +5];
            X = [X, NaN, X1];
            Y = [Y, NaN,Y1];

            this.A6 = [X1(1), Y1(1)];
            x = X1(1)+1;
            y = PH-3;
            lableGNDPin = this.CreateLable(x,y,'GND');
            
            %ISPin
            X1 = (SecStart+Space*3.5)*[1 1]; 
            Y1 = -[PH 5];
            X = [X, NaN, X1];
            Y = [Y, NaN, Y1];

            this.B6 = [X1(1), Y1(1)];
            x = X1(1)+1;
            y = -PH+3;
            lableISPin = this.CreateLable(x,y,'IS');
            
            [GNDPinAnch,ISPinAnch] = this.CreateAnchorPoint(6);
            
            %FBPin
            X1 = (SecStart+Space*4.5)*[1 1]; 
            Y1 = [+PH +5];
            X = [X, NaN, X1];
            Y = [Y, NaN, Y1];

            x = X1(1)+1;
            y = PH-3;
           if this.Family == EComponentType.InnoSwitch3Pro
                lableVOPin = this.CreateLable(x,y,'VO'); 
           else
                lableFBPin = this.CreateLable(x,y,'FB');
           end
            
            this.A7 = [X1(1), Y1(1)];
            this.B7 = [];
            [FBPinAnch,~] = this.CreateAnchorPoint(7);
            this.B7 = [-X1(1), Y1(1)];
            
            %VOUTPin
            X1 = (SecStart+Space*5.5)*[1 1]; 
            Y1 = [+PH +5];
            X = [X, NaN, X1];
            Y = [Y, NaN, Y1];
            
            x = X1(1)+1;
            y = PH-3;
            
           if this.Family == EComponentType.InnoSwitch3Pro
                lableVDBPin = this.CreateLable(x,y,'VD/B'); 
           else
                lableVOPin = this.CreateLable(x,y,'VO');
           end
            
            
            
            this.A8 = [X1(1), Y1(1)];
            this.B8 = [];
            [VOUTPinAnch,~] = this.CreateAnchorPoint(8);
            this.B8 = [-X1(1), Y1(1)];
            
            x = -100;
            y = 0;
            lable = this.CreateLable(x,y,string(this.Family),8);

            
            conn =  line(X,Y,'Parent',this.GrObj,'Tag','body');
            conn.HitTest = 'off';
            conn.UserData.Defaults.XData = X;
            conn.UserData.Defaults.YData = Y; 
            
            
            i = 1;
            this.GrSubObj{i} = outbody;             i = i + 1;
            this.GrSubObj{i} = primController;      i = i + 1;
            this.GrSubObj{i} = secondController;    i = i + 1;
            this.GrSubObj{i} = DrainAnch;           i = i + 1;
            this.GrSubObj{i} = SourceAnch;          i = i + 1;
            this.GrSubObj{i} = conn;                i = i + 1;
            this.GrSubObj{i} = VPinAnch;            i = i + 1;
            this.GrSubObj{i} = BPPPinAnch;          i = i + 1;
            this.GrSubObj{i} = FWDPinAnch;          i = i + 1;
            this.GrSubObj{i} = SRPinAnch;           i = i + 1;
            this.GrSubObj{i} = BPSPinAnch;          i = i + 1;
            this.GrSubObj{i} = GNDPinAnch;          i = i + 1;
            this.GrSubObj{i} = FBPinAnch;           i = i + 1;
            this.GrSubObj{i} = VOUTPinAnch;         i = i + 1;
            this.GrSubObj{i} = ISPinAnch;           i = i + 1;
            this.GrSubObj{i} = lable;               i = i + 1;
            this.GrSubObj{i} = lableDPin;           i = i + 1;
            this.GrSubObj{i} = lableSPin;           i = i + 1;
            this.GrSubObj{i} = lableVPin;           i = i + 1;
            this.GrSubObj{i} = lableBPPPin;         i = i + 1;
            this.GrSubObj{i} = lableFWDPin;         i = i + 1;
            this.GrSubObj{i} = lableSRPin;          i = i + 1;
            this.GrSubObj{i} = lableBPSPin;         i = i + 1;
            this.GrSubObj{i} = lableGNDPin;         i = i + 1;
            this.GrSubObj{i} = lableISPin;          i = i + 1;
            
           if this.Family == EComponentType.InnoSwitch3Pro
                this.GrSubObj{i} = lableVOPin;     i = i + 1;
                this.GrSubObj{i} = lableVDBPin;    i = i + 1;
           else
                this.GrSubObj{i} = lableFBPin;     i = i + 1;
                this.GrSubObj{i} = lableVOPin;     i = i + 1;
           end


            
            
            
        end
        
        function lable = CreateLable(this,x,y,Text,FontSize)
            if nargin<5 || isempty(FontSize)
                FontSize = 6;
            end
            lable = text(x,y,Text,'FontWeight','normal','FontSize',FontSize,'FontUnit','pixels','Parent',this.GrObj); 
            lable.UserData.Defaults.Xo = x;
            lable.UserData.Defaults.Yo = y;
            lable.HitTest = 'off';
        end
        
    end
 
    
end