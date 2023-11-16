# FastCircuitCAD
MATLAB implementation of a circuit CAD designer

## How to run it
to start the application run `main` from the MATLAB command window.

## Place components
Components can be added by means of specific keyboard shorcuts.

| Key | Component             |
|-----|-----------------------|
| R   | Resistor              |
| C   | Capacitor             |
| L   | Inductor              |
| D   | Diode                 |
| Z   | Zener-Diode           |
| Q   | NPN Mosfet            |
| T   | Tranformer            |
| M   | Common Mode Choke     |
| F   | Fuse                  |
| B   | Full Bridge Rectifier |
| G   | Ground Connector      |
| P   | Pin Connector         |

When a new component is added, it is automatically placed in the center of the canvas.

## Move components
Components can be individually selected by a left mouse click on the component.
The current selection is hihglighted in red. Once the component is selected it can be moved around the canvas by a drag and drop action.
To deselect a component click in a blank area of the canvas.

## Connect components
Each component has 1 or more terminations (open ends), these are hihglighted with a red circle when the mouse hoovers over the component's termination.
To draw a connection between two component's termination, first press the key `W` of the keyboard, then click on the termination you want to connect.
A straight blue dotted line is now be glued to the mouse pointer. To complete the termination left click on the second compoenent's termination you want to connect.
The final connection is drawn as a solid segmented line.

## Modifying routing
Should the routing overlap other compoents or simply subotimal, each connection can be manually modified.
First, left click on the connection to modify. The connection should now display handles as blue diamond on the long edges of the connection.
By drag and drop action on the connection handles, the routing can be altered. to deselect the connection left click on the white part of the canvas.


## Other actions
Other general action can be performed
- Delete a component or/and connection
Select the component/connection. Press the `del` key on the keyboard. **NB:** when deleting a component with connection attached to it. the connections are automatically deleted.
- Rotate a component.
Select the component first (left click on the component). Press the key combination `Crtl` + `R`
- Mirror a coponent

   Rename a component
Select the compoent, right mouse click and select `rename` from the context menu.

- Select multiple compoenents
Right mouse click on the blank part of the canvas. Select `Multi-select` from the context menu.

- Clear the canvas
Right mouse click on the blank part of the canvas. Select `Clear all` from the context menu.

- Save (TBI)

- Load (TBI)
