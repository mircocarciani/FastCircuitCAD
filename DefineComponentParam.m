function DefineComponentParam(this,family)

switch family
    case 'Capacitor'
        this.DataBase.PN = '';
        this.DataBase.Type = '';
        %Define Capacitor Parameters
        this.DataBase.C = [];
        this.DataBase.Esr = [];
        this.DataBase.Vrated = [];
        this.DataBase.Irated = [];
        this.DataBase.Height = [];
        this.DataBase.Width = [];
        this.DataBase.Length = [];
        this.DataBase.Diameter = [];
        this.DataBase.Manifacturer = '';
        
    case 'Resistor'    
        this.DataBase.R = [];
        this.DataBase.Pmax = [];
        this.DataBase.Tol = [];
        
    case 'Diode'
        this.DataBase.PN = [];
        this.DataBase.Type = '';
        this.DataBase.VF = [];
        this.DataBase.VRated = [];
        this.DataBase.IRated = [];
        this.DataBase.Manifacturer = '';
        
    case 'Zener'
        this.DataBase.Type = '';
        this.DataBase.PN = '';
        this.DataBase.Vrated = [];
        this.DataBase.Irated = [];
        this.DataBase.Pmax = [];
        this.DataBase.Iz = [];
        this.DataBase.Manifacturer = '';
        
    case 'Integrated Bridge'
        this.DataBase.PN='';
        this.DataBase.VF = [];
        this.DataBase.Vrated = []; 
        this.DataBase.Irated = [];
        this.DataBase.Manifacturer = '';
        
    case 'Fuse' 
       this.DataBase.PN = '' ;
       this.DataBase.Type = '';
       this.DataBase.Vrated = [];
       this.DataBase.Irated = [];
       this.DataBase.VBreakingCapacity = [];
       this.DataBase.I2t = [];
       this.DataBase.Manifacturer = '';
       
    case 'Thermistor'
       this.DataBase.PN = '';
       this.DataBase.R  = []; 
       this.DataBase.Irated  = []; 
       this.DataBase.Manifacturer = '';
       
    case 'Varistor'
       this.DataBase.PN = '';
       this.DataBase.Type = '';
       this.DataBase.Vrated = [];
       this.DataBase.Max_Clamping_Voltage = [];
       this.DataBase.Max_Clamping_Current = [];
       this.DataBase.Erated = [];
       this.DataBase.Manifacturer = '';
       
       Case 'Fusibleresistor'
       this.DataBase.PN = '';
       this.DataBase.Type = '';
       this.DataBase.R = '';
       this.DataBase.Tol = '';
       this.DataBase.Prated = '';
       
    case 'InnoSwitch'
       this.DataBase.PN  = '';
       this.DataBase.Size  = '';
       this.DataBase.HCode  = '';
       this.DataBase.BVDSS  = [];
       
    case 'TOPSwitch'
       this.DataBase.PN  = '';
       this.DataBase.Size  = '';
       this.DataBase.HCode  = '';
       this.DataBase.BVDSS  = [];
       
    case 'LinkSwitch'
       this.DataBase.PN  = '';
       this.DataBase.Size  = '';
       this.DataBase.HCode  = '';
       this.DataBase.BVDSS  = [];
    case 'TinySwitch'
       this.DataBase.PN  = '';
       this.DataBase.Size  = '';
       this.DataBase.HCode  = '';
       this.DataBase.BVDSS  = [];
       
    case 'Mosfet'
       this.DataBase.PN  = '';
       this.DataBase.Type  = '';
       this.DataBase.ID_Max = [];
       this.DataBase.VDS_Max = [];
       this.DataBase.VGTH = [];
       this.DataBase.Rdson = [];
       this.DataBase.Manifacturer  = '';
       
    case 'IGBT'
       this.DataBase.PN = '';
       this.DataBase.Type  = '';
       this.DataBase.IC_Max = [];
       this.DataBase.VCE_Max = [];
       this.DataBase.VGE = [];
       this.DataBase.Rdson = [];
       this.DataBase.Manifacturer  = '';
end
 end