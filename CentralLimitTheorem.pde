// Central Limit Theorem using Processing.
// November 2012


///////////////////////////////////////
//// Declare and initialize variables.

// Pegs variables.
int N = 11;            // there are N+1 rows and N+2 vertical bars
int rad = 10;          // radius of pegs and balls.  
int peg_dist = 16;     // distance between pegs.
int pegX, pegY;        // hold the coords used for drawing the pegs.

// Variables for falling ball.
int bin_num = 0;     // holds the x value of the column 
                     // in which the ball fell.                     
int thresholdY = 0;  // holds the bottom of the pegs; tells
                     // the program when the ball needs to just 
                     // fall straight down.  
float dir = 0;       // holds the value being added to the
                     // x coordinate.
float x, y;          // x, y coords for the falling ball.
int rectY, rectX;    // hold the coords used for drawing
                     // the bars which represent the PDF.
float tick = 0;      // keep track of how many x/y increments
                     // occurred.
int col_count = -1;  // we count up to the column (from -1)
                     // for each falling ball.
int colFall = 0;     // holds the x value for the final column


// Variable for user input.
// Speed.
float SPEED_MAX = peg_dist;    // Max is 2^4.
float SPEED_MIN = 0;           // Min is 2^0.
float speed = 0;
float speed_factor = 1;        // # by which we change the speed.
int stats_flag = 0;            // 0: display nothing
                               // 1: display %-age
                               // 2: display #s
int STATS_MAX = 2;             // Used for resetting the stats_flag.


// Variables for stats.
int[] binArray = new int[N+1];  // holds the # of balls which fell
                                // into each of the N+1 columns
int numBalls = 0;               // holds the overall # of balls, 
                                // useful for stats.
float[] stats = new float[N+1]; // Contains %-age data for each column.
String s;                       // Holds text for printing stats.


// Variables for up and down unicode characters.
String sUp = "2191";            // Unicode for the up arrow.
int nUp = unhex(sUp);
char[] cUp = Character.toChars(nUp);
String chUp = new String(cUp);

String sDown = "2193";          // Unicode for the down arrow.
int nDown = unhex(sDown);
char[] cDown = Character.toChars(nDown);
String chDown = new String(cDown);
  
  
  
// Processing consists of a setup loop and a draw loop. Setup
// runs once. Draw is an infinite while loop although it can be
// interrupted by the user via the keyboard, mouse, etc.
void setup()
{
  size(400, 500);
  
  x = width/2;        // starting point for x
  y = 0;              // starting point for y  
  colFall = (width/2)-((N+2)*peg_dist);
  
  // Initialize the speed.
  speed = pow(2, speed_factor);
  
  // Use a moderate frame rate.
  frameRate(60);
}


void draw()
{
  //////////////////////////////////////////////////////
  // We re-draw everything each time through the loop.
  
  // Draw gray background.
  background(100);
  
  // Draw the pegs. This function keeps the diagonal 
  // distance constant between pegs.  
  //drawPegs(0,200,40);    // green pegs
  drawPegs(51, 255, 255);  // cyan pegs
  
  //////////////////////////////////////////////////////
  // Draw falling ball(s).
  // By returning the column number, this function 
  // provides a means for drawing the bars.
  bin_num = drawFallingBall();
  
  // Define the first rectangle as the left-most rectangle. 
  rectX = (width/2)-((N+2)*peg_dist);
  
  // Draw rectangles for each element in binArray.
  for (int i = 0; i <= N;i++)
  {
    rectY = height - binArray[i];
    // 7 is a good number for rounded corners
    // Add 10 to the height in case we end up rounding the corners
    // of the rectangles.
    fill(255);
    rect(rectX+peg_dist, rectY, 2*peg_dist, binArray[i]+9, 7);
    rectX += 2*peg_dist;
  }
  
  // Track heights of the bars.
  if (bin_num >= 0)
  {
    binArray[bin_num]++;
    numBalls++;
  }  
  
  // Re-use the rectangle x values for the %-age text.
  rectX = (width/2)-((N+2)*peg_dist)+peg_dist+10;
  
  // Display the %-age of each column.
  if (numBalls > 0)
  {
    for (int i = 0; i <= N;i++)
    {
      switch(stats_flag)
      {
        case 0:
        {
          s = "";
          break;
        }
        case 1:
        {
          // Calculate percentages, store to a string.
          stats[i] = ((float)(binArray[i]))/((float)(numBalls));
          s = String.format("%.2f", stats[i]);
          break;
        }
        case 2:
        {
          // Store the count to a string.
          s = String.format("%s", str(binArray[i]));
          break;
        }
        default:
        {
          s = "";
          break;
        }
      }
      fill(255);
      text(s, rectX, thresholdY+30);
      rectX += 2*peg_dist;
    }
  }  
    
  // Display controls in the upper left corner.
  fill(0);            // Makes the following text black.  
  text("change speed: ", 10, 3*peg_dist/2);
  text(chUp, 102, 3*peg_dist/2);
  text(chDown, 110, 3*peg_dist/2);
  text("toggle stats: tab", 10, 5*peg_dist/2);
  text("quit: esc", 10, 7*peg_dist/2);
  
    
  // Display stats in the upper right corner.
  text("count: " + str(numBalls), width*2/3+50, 3*peg_dist/2);
  text("speed: " + str((int)speed_factor), width*2/3+50, 5*peg_dist/2); 
}


//////////////////////////////////////////////////////
// drawPegs
// intput - r, b, and g correspond to the red, blue 
// and green colors passed to the fill command.
void drawPegs(int r, int b, int g)
{
  // Loop over the rows.
  for (int rows = 0; rows <= N;rows++)
  {
    pegX = width/2 - peg_dist*rows;
    pegY = peg_dist*(rows+2);
    
    // Loop over the columns.  
    for (int cols = 0; cols <= rows;cols++)
    {
      fill(r,b,g);
      ellipse(pegX,pegY,rad,rad);
      
      pegX += peg_dist*2;
    }
  }
  thresholdY = pegY;
}


//////////////////////////////////////////////////////
// drawFallingBall
// input - none
// returns - the index of the column in which the 
// falling ball landed.
int drawFallingBall()
{ 
  int ret = -1;
  
  // This keeps track of the number of increments between pegs.
  // It's an easy way to know when to calculate a random value.
  tick += speed;
  
  y += speed;
  
  if (y >= (peg_dist*2) )
  {  
    
    if (y >= thresholdY)
    {
      // We've reached the bottom of the pegs,
      // stop incrementing x.
      dir = 0;
      
      // Determine to which column (i.e. bin) this ball contributes.
      while (x != colFall)
      {
        col_count++;
        
        colFall += (2*peg_dist);
      } 
      
      y +=10;
      
      // Stop drawing a ball once it reaches the bottom.
      if (y > (height-rad))
      {
        y = 0;
        x = width/2;
        colFall = (width/2)-((N+2)*peg_dist);
        
        ret = col_count;
        col_count = -1;
        
        // Any changes from interrupts are applied t0
        // the next falling ball.
        speed = pow(2, speed_factor);
      }
    }
    else
    {
      // Get a new random variable once we've counted
      // up to the distance between pegs.
      if (tick >= (peg_dist))
      {
        // Determine in which direction the ball should
        // be moved by using a uniform random variable.
        if (random(1.0) <= 0.5)
        {
          dir = -speed;
        }
        else
        {
          dir = speed;
        }
        
        // Reset the tick each time we change direction.
        tick = 0;
      }
    }
  }
  
  // Move the ball left or right (as long as our 
  // height is above the last row of pags), otherwise
  // the ball falls straight down.
  x += dir;
  
  // Draw the falling ball, fill with yellow.
  fill(255,255,0);
  ellipse(x,y,rad,rad);
  
  return ret;
}

//////////////////////////////////////////////////////
// Process user input. 
void keyReleased()
{
  int speed_flag = 0;
  
  if (key == CODED)
  {
    if (keyCode == UP)
    {
      // The user pressed up. Increase speed.
      speed_factor++;
      speed_flag = 1;
    }
    else if (keyCode == DOWN)
    {
      // The user pressed down. Decrease speed.
      speed_factor--;
      speed_flag = 1;
    }
    
    // Check the speed factor against its limits.
    if (speed_flag == 1)
    {
      if (pow(2,speed_factor) > SPEED_MAX)
      {
        speed_factor = 4;
      } 
      else if (pow(2,speed_factor) < SPEED_MIN)
      {
        speed_factor = 0;
      }
    }
  }
  
  if (key == TAB)
  {
    // Toggle the stats flag.
    stats_flag++;
    
    // Reset the flag to 0.
    if (stats_flag > STATS_MAX)
    {
      // 
      stats_flag = 0;
    }
  }  
}

