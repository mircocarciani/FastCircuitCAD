classdef ESchematicInteractionType
    
    enumeration
        ViewOnly  % Picture mode
        Draw % draw the schematic
        Interact % Component position cannot be modified. compents can still be clicked
        Notebook % note can be written over the schematic
    end
end