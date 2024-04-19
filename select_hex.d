
module select_hex;

import honeycomb;
import std.stdio;
import std.conv: roundTo;
import std.math.rounding: floor;


struct D2_NDC
{
    float x;
    float y; 
}

//   |  \________|/          |  \________|/          |  \________|/
//   |XX/        |\          |XX/        |\          |XX/        |\ 
//   |X/         | \         |X/         | \         |X/         | \ 
//   |/          |  \________|/          |  \________|/          |  \    
//   |\          |XX/        |\          |XX/        |\          |XX/
//   | \         |X/         | \         |X/         | \         |X/
//   |  \________|/          |  \________|/          |  \________|/
//   |XX/        |\          |XX/        |\          |XX/        |\ 
//   |X/         | \         |X/         | \         |X/         | \ 
//   |/          |  \________|/          |  \________|/          |  \    
//   |\          |XX/        |\          |XX/        |\          |XX/
//   | \         |X/         | \         |X/         | \         |X/
//   |  \________|/__________|__\________|/__________|__\________|/__
// 
//            opposite 
//           __________
//           |......../         
//           |......./        
//           |....../  if angle > tan(60) then mouse clicked         
//           |...../   inside the triangle         
//  adjacent |..../            
//           |.../             
//           |../ 60 degrees   
//           |./  
//           |/
//           +         
//           leftPoint



//   |  /        |\          |  /        |\          |  /        |\ 
//   | /         |X\         | /         |X\         | /         |X\ 
//   |/          |XX\________|/          |XX\________|/          |XX\
//   |\          |  /        |\          |  /        |\          |  /
//   |X\         | /         |X\         | /         |X\         | /
//   |XX\________|/          |XX\________|/          |XX\________|/__
//   |  /        |\          |  /        |\          |  /        |\ 
//   | /         |X\         | /         |X\         | /         |X\ 
//   |/          |XX\________|/          |XX\________|/          |XX\    
//   |\          |  /        |\          |  /        |\          |  /
//   |X\         | /         |X\         | /         |X\         | /
//   |XX\________|/__________|XX\________|/__________|XX\________|/__
//
//           + leftPoint
//           |\      
//           |.\
//           |..\ 300 degrees
//           |...\
//           |....\     if angle < tan(300) then mouse clicked
//  adjacent |.....\    inside the triangle
//           |......\ 
//           |.......\     
//           |________\
// 
//            opposite         


bool clickedInSmallTriangle(D3_point mouseClick, D3_point hexCenter, float radius)
{
    immutable float tanOf60  =  1.7320508;
    immutable float tanOf300 = -1.7320508;

    float leftPointX = hexCenter.x - radius;
    float leftPointY = hexCenter.y;    

    float adjacent = mouseClick.x - leftPointX;
    float opposite = mouseClick.y - leftPointY;
	
    // tan(theta) = opposite / adjacent     
	
    float angle = opposite / adjacent;  // opposite is positive for hex sides /  (leaning Southwest to Northeast)
	                                     // opposite is negative for hex sides \  (leaning Northwest to Southeast)
    if (angle >= 0.0)            
        return (angle > tanOf60);    // angle is positive
    else                           
        return (angle < tanOf300);	 // angle is negative		
}






















/+
A hexboard will be passed in my reference (for speed sake) consisting of NDC coordinates and a screen
coordinate pair consisting of an x and y value of where the mouse was clicked  

+/


                                                    // mouse click
bool getHexThatWasClickedWithMouse( ref HexBoard h)
{
    //writeln("inside getHexThatWasClickedWithMouse");


    //writeln(h.mouseClick.sc.x, ", ", h.mouseClick.sc.y);
    //writeln(h.mouseClick.ndc.x, ", ", h.mouseClick.ndc.y);

    // Take the bottom of the edge of the screen (ie -1.0)  Any screen click on the screen is going to be Bigger in value.
    // So that the mouse click and subtract the edge.  

    // This block of code handles the (rare?) cases where the window is bigger than
    // than the hex board. 



    //   |__\________|/__________|__\________|/__________|__\________|/__
    //   |  /        |\          |  /        |\          |  /        |\ 
    //   | Upper Left|Upper Right| Upper Left|Upper Right| Upper Left| Upper Right
    //   |/__________|__\________|/__________|__\________|/__________|__\
    //   |\          |  /        |\          |  /        |\          |  /
    //   | Lower Left|Lower Right|Lower Left |Lower Right| Lower Left| Lower Right
    //   |__\________|/__________|__\________|/__________|__\________|/__
    //   |  /        |\          |  /        |\          |  /        |\ 
    //   |Upper Left |Upper Right| Upper Left|Upper Right| Upper Left| Upper Right
    //   |/__________|__\________|/__________|__\________|/__________|  \    
    //   |\          |  /        |\          |  /        |\          |  /
    //   |Lower Left |Lower Right| Lower Left|Lower Right| Lower Left| Lower Right
    //   |__\________|/__________|__\________|/__________|__\________|/__	
										
    float offsetFromBottom = h.mouseClick.ndc.y - (-1.0);
	
    uint gridRow = roundTo!uint(floor(offsetFromBottom / h.apothem));

    float offsetFromLeft = h.mouseClick.ndc.x - (-1.0);						
                     
    uint gridCol = roundTo!uint(floor(offsetFromLeft / (h.radius + h.halfRadius)));


    if (h.mouseClick.ndc.x > h.edge.right)  // clicked to the right of the hex board's right edge
    {
        writeln("Clicked outside of the hex board's right edge");
        return false;						
    }
    if (h.mouseClick.ndc.y > h.edge.top)    // clicked above the hex board's top edge
    {
        writeln("Clicked above the hex board's top edge");
        return false;						
    }

    writeln("(gridRow,gridCol) = (", gridRow, ",", gridCol, ")");

    //   |___________|___________|___________|___________|___________|___
    //   |           |           |           |           |           |  
    //   | Upper Left|Upper Right| Upper Left|Upper Right| Upper Left| Upper Right
    //   |___________|___________|___________|___________|___________|___
    //   |           |           |           |           |           |   
    //   | Lower Left|Lower Right|Lower Left |Lower Right| Lower Left| Lower Right
    //   |___________|___________|___________|___________|___________|___
    //   |           |           |           |           |           |  
    //   |Upper Left |Upper Right| Upper Left|Upper Right| Upper Left| Upper Right
    //   |___________|___________|___________|___________|___________|___    
    //   |           |           |           |           |           |   
    //   |Lower Left |Lower Right| Lower Left|Lower Right| Lower Left| Lower Right
    //   |___________|___________|___________|___________|___________|___	


    // We can exclude 3/4 of the hexBoard just by finding the quadrant that was mouse clicked on

    enum Quads { UL, UR, LL, LR }
    Quads quadrant;

    if (gridRow.isEven)
    {
        if (gridCol.isEven)
            quadrant = Quads.LL; // (e,e)
        else
            quadrant = Quads.LR; // (e,o)					
    }
    else // gridRow isOdd
    {
        if (gridCol.isEven)
            quadrant = Quads.UL; // (o,e)
        else
            quadrant = Quads.UR; // (o,o)					
    }

    int hexRow = h.invalid;
    int hexCol = h.invalid;					

    //D3_point NDC;        // will just use the x,y coordinates (not z)
	
    //D2_point hexCenter;  // will just use the x,y coordinates (not z

    struct D2_NDC
    {
        float x;
        float y; 
    }
	
    D3_point hexCenter;
	
    //================================= UL ========================================= 
  
    if (quadrant == Quads.UL)   // Upper Left Quadrant
    { 					
        hexRow = (gridRow-1) / 2;  // UL gridRows = {1, 3, 5, 7,...} mapped to row = {0, 1, 2, 3,...}
        hexCol = gridCol;

        hexCenter = h.hexes[hexRow][hexCol].center;	
		
        //hexCenter.x = h.hexes[hexRow][hexCol].points[0].x; // + (h.radius/2.0);  // move the bottom vertex to right a bit
		//h.hexes[hexRow][hexCol].points[0].x = 2;
        //hexCenter.y = h.hexes[hexRow][hexCol].points[0].y; // + (h.apothem);   // move 
		
        if (clickedInSmallTriangle(h.mouseClick.ndc, hexCenter, h.radius))	 					
        {
            if(hexCol == 0)  // corner case if select small triangle on far left of board  
            {  
                //row = invalid; 
                //col = invalid;
				writeln("Select small triangle on far left of board");
                return false;
            }
            else
            {
                //hexCol -= 1;	
                //writeln("(hexRow, hexCol) = (", hexRow, ", ", hexCol, ")");

                h.selectedHex.row = hexRow;
                h.selectedHex.col = hexCol -= 1;				
                return true;				
            }
        }							
    }	

    //================================= LR ========================================= 
						
    if (quadrant == Quads.LR)    // Lower Right Quadrant
    {
        if (gridRow >= 1)  
        {
            hexRow = (gridRow/2) - 1;    // LR gridRows = {2, 4, 6, 8,...}  mapped to row = {0, 1, 2, 3,...}
            hexCol = gridCol;	          //                0 handled by else block below				
 
            hexCenter = h.hexes[hexRow][hexCol].center;

            if (clickedInSmallTriangle(h.mouseClick.ndc, hexCenter, h.radius))
            {
                //hexRow += 1;
                //hexCol -= 1;
                h.selectedHex.row = hexRow + 1;				
                h.selectedHex.col = hexCol - 1;				
                return true;
            }						    
        }
        else   // degenerate case, only for very bottom row on hexboard
        {							
            hexRow = 0; 
            hexCol = gridCol;
							
            hexCenter = h.hexes[hexRow][hexCol].center;
							
            hexCenter.y = (hexCenter.y - h.perpendicular);
						
            if (clickedInSmallTriangle(h.mouseClick.ndc, hexCenter, h.radius))
            {
                //hexCol -= 1;
                h.selectedHex.row = hexRow;				
                h.selectedHex.col = hexCol - 1;
                return true;				
            }
            else
            {
                hexRow = h.invalid; 
                hexCol = h.invalid;	
                return false;				
            }
        }
    }

    //================================= UR =========================================						
						
    if (quadrant == Quads.UR)    // Upper Right Quadrant
    { 
        hexRow = (gridRow-1) / 2;    // UR gridRows = {1, 3, 5, 7,...} mapped to row = {0, 1, 2, 3,...}
        hexCol = gridCol;					
 
        hexCenter = h.hexes[hexRow][hexCol].center;

        if (clickedInSmallTriangle(h.mouseClick.ndc, hexCenter, h.radius))
        {
            //hexCol -= 1;
            h.selectedHex.row = hexRow;				
            h.selectedHex.col = hexCol - 1;					   
        }
        return true;   // no degenerate case 		
    }													
	
    //================================= LL =========================================						
						
    if (quadrant == Quads.LL)    // Lower Left Quadrant
    { 
        hexRow = gridRow / 2;    // gridRows = {0, 2, 4, 6,...} mapped to row = {0, 1, 2, 3,...}
        hexCol = gridCol;	

        hexCenter = h.hexes[hexRow][hexCol].center;

        if (clickedInSmallTriangle(h.mouseClick.ndc, hexCenter, h.radius))
        { 
            if (gridRow == 0 || gridCol == 0)  // degenerate case, clicked on left side or 
            {                                  // bottom of hexboard outside of any hex
                hexRow = h.invalid, 
                hexCol = h.invalid;
            }
            else
            {
                hexRow -= 1;
                hexCol -= 1;								
            }
        }
    }	

    if ((hexRow != h.invalid) && (hexCol != h.invalid))
    {
        writeln("hex(hexRow,hexCol) = ", hexRow, " ", hexCol, " has been selected");	
        h.selectedHex.row = hexRow;
        h.selectedHex.col = hexCol;						
        //hexBoard.hexes[row][col].selected = true;
    }						




    return true;
}



/+

extern(C) void mouseButtonCallback(GLFWwindow* winMain, int button, int action, int mods) nothrow
{
    try  // try is needed because of the nothrow
    {
        switch(button)
        {
            case GLFW_MOUSE_BUTTON_LEFT:
                if (action == GLFW_PRESS)
                {
                    double xPos, yPos;
 

 






						

                }
                else if (action == GLFW_RELEASE)
                {
                    //mouseButtonLeftDown = false;
                }
			    break;
		    default: assert(0);
        }
    }
    catch(Exception e)
    {
    }
}


+/