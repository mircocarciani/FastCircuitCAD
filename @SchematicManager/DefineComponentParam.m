function DefineComponentParam(this)           
        this.componentParametersDef.Capacitor.PN = '';
        this.componentParametersDef.Capacitor.Type = '';
        this.componentParametersDef.Capacitor.C = [];
        this.componentParametersDef.Capacitor.Esr = [];
        this.componentParametersDef.Capacitor.Vrated = [];
        this.componentParametersDef.Capacitor.Irated = [];
        this.componentParametersDef.Capacitor.Height = [];
        this.componentParametersDef.Capacitor.Width = [];
        this.componentParametersDef.Capacitor.Length = [];
        this.componentParametersDef.Capacitor.Diameter = [];
        this.componentParametersDef.Capacitor.Type = '';
        this.componentParametersDef.Capacitor.Manifacturer = '';
            
        this.componentParametersDef.Resistor.R = [];
        this.componentParametersDef.Resistor.Pmax = [];
        this.componentParametersDef.Resistor.Tol = [];
        
        this.componentParametersDef.Inductor.R = [];
        this.componentParametersDef.Inductor.Pmax = [];
        this.componentParametersDef.Inductor.Tol = [];
        
        this.componentParametersDef.Diode.PN = [];
        this.componentParametersDef.Diode.Type = '';
        this.componentParametersDef.Diode.VF = [];
        this.componentParametersDef.Diode.VRated = [];
        this.componentParametersDef.Diode.IRated = [];
        this.componentParametersDef.Diode.Manifacturer = '';
        
        this.componentParametersDef.Zener.Type = '';
        this.componentParametersDef.Zener.PN = '';
        this.componentParametersDef.Zener.Vrated = [];
        this.componentParametersDef.Zener.Irated = [];
        this.componentParametersDef.Zener.Pmax = [];
        this.componentParametersDef.Zener.Iz = [];
        this.componentParametersDef.Manifacturer = '';
        
        this.componentParametersDef.Bridge.PN='';
        this.componentParametersDef.Bridge.VF = [];
        this.componentParametersDef.Bridge.Vrated = []; 
        this.componentParametersDef.Bridge.Irated = [];
        this.componentParametersDef.Bridge.Manifacturer = '';
        
       this.componentParametersDef.Fuse.PN = '' ;
       this.componentParametersDef.Fuse.Type = '';
       this.componentParametersDef.Fuse.Vrated = [];
       this.componentParametersDef.Fuse.Irated = [];
       this.componentParametersDef.Fuse.VBreakingCapacity = [];
       this.componentParametersDef.Fuse.I2t = [];
       this.componentParametersDef.Fuse.Manifacturer = '';
        
       this.componentParametersDef.Thermistor.PN = '';
       this.componentParametersDef.Thermistor.R  = []; 
       this.componentParametersDef.Thermistor.Irated  = []; 
       this.componentParametersDef.Thermistor.Manifacturer = '';
       
       this.componentParametersDef.CMChoke.PN = '';
       this.componentParametersDef.CMChoke.R  = []; 
       this.componentParametersDef.CMChoke.Irated  = []; 
       this.componentParametersDef.CMChoke.Manifacturer = '';
       
       this.componentParametersDef.Varistor.PN = '';
       this.componentParametersDef.Varistor.Type = '';
       this.componentParametersDef.Varistor.Vrated = [];
       this.componentParametersDef.Varistor.Max_Clamping_Voltage = [];
       this.componentParametersDef.Varistor.Max_Clamping_Current = [];
       this.componentParametersDef.Varistor.Erated = [];
       this.componentParametersDef.Varistor.Manifacturer = '';
       
       this.componentParametersDef.FusibleResistor.PN = '';
       this.componentParametersDef.FusibleResistor.Type = '';
       this.componentParametersDef.FusibleResistor.R = '';
       this.componentParametersDef.FusibleResistor.Tol = '';
       this.componentParametersDef.FusibleResistor.Prated = '';

      
       this.componentParametersDef.InnoSwitch.PN  = '';
       this.componentParametersDef.InnoSwitch.Size  = '';
       this.componentParametersDef.InnoSwitch.HCode  = '';
       this.componentParametersDef.InnoSwitch.BVDSS  = [];
       
       this.componentParametersDef.TOPSwitch.PN  = '';
       this.componentParametersDef.TOPSwitch.Size  = '';
       this.componentParametersDef.TOPSwitch.HCode  = '';
       this.componentParametersDef.TOPSwitch.BVDSS  = [];
       
       this.componentParametersDef.LinkSwitch.PN  = '';
       this.componentParametersDef.LinkSwitch.Size  = '';
       this.componentParametersDef.LinkSwitch.HCode  = '';
       this.componentParametersDef.LinkSwitch.BVDSS  = [];
       
       this.componentParametersDef.TinySwitch.PN  = '';
       this.componentParametersDef.TinySwitch.Size  = '';
       this.componentParametersDef.TinySwitch.HCode  = '';
       this.componentParametersDef.TinySwitch.BVDSS  = [];
       
       this.componentParametersDef.InnoSwitch.PN  = '';
       this.componentParametersDef.InnoSwitch.Size  = '';
       this.componentParametersDef.InnoSwitch.HCode  = '';
       this.componentParametersDef.InnoSwitch.BVDSS  = [];
       
       this.componentParametersDef.MOSFET.PN  = '';
       this.componentParametersDef.MOSFET.Type  = '';
       this.componentParametersDef.MOSFET.ID_Max = [];
       this.componentParametersDef.MOSFET.VDS_Max = [];
       this.componentParametersDef.MOSFET.VGTH = [];
       this.componentParametersDef.MOSFET.Rdson = [];
       this.componentParametersDef.MOSFET.Manifacturer  = '';
       
       
       this.componentParametersDef.IGBT.PN = '';
       this.componentParametersDef.IGBT.Type  = '';
       this.componentParametersDef.IGBT.IC_Max = [];
       this.componentParametersDef.IGBT.VCE_Max = [];
       this.componentParametersDef.IGBT.VGE = [];
       this.componentParametersDef.IGBT.Rdson = [];
       this.componentParametersDef.IGBT.Manifacturer  = '';
       
       this.componentParametersDef.Pin.To = '';
       this.componentParametersDef.Pin.From = '';
       
       
       
       this.componentParametersDef.Transformer.PN = '';
       this.componentParametersDef.Transformer.Type  = '';
       this.componentParametersDef.Transformer.IC_Max = [];
       this.componentParametersDef.Transformer.VCE_Max = [];
       this.componentParametersDef.Transformer.VGE = [];
       this.componentParametersDef.Transformer.Rdson = [];
       this.componentParametersDef.Transformer.Manifacturer  = '';
      
       
 end