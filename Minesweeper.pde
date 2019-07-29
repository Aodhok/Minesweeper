import controlP5.*;

int N_DEFAULT = 0;
int B_DEFAULT = 0;
int txtSize, the_size=14;

//colours for the game 
color BACK  = color(187, 187, 187);
color GRID  = color(205, 150, 145);
color BOMB  = color(186,  74, 110);
color FLAG  = color( 12, 171, 171);
color TEXTS = color(112,  59, 105);

char H = 'h';
char O = 'o';
char F = 'f';

ControlP5 cp5;
Grid grid = new Grid(N_DEFAULT, B_DEFAULT);
NewGame newGame;  //new game

void setup() 
{
  //window size
  size(450, 450);

  //frame rate
  frameRate(60);
  
  //create text for the screen
  txtSize = 14;
  textFont(createFont("Times New Roman", txtSize));
  textAlign(CENTER, CENTER);
  stroke(BOMB);
  
  //instance of new game
  newGame = new NewGame();
  
  cp5 = new ControlP5(this);
  
  cp5.addSlider("Size")
    .setPosition(10,100)
    .setSize(20,200)
    .setRange(10,30)
    .setValue(0)
    .setNumberOfTickMarks(5) 
    ;
    
  cp5.addSlider("Bombs")
    .setPosition(415,100)
    .setSize(20,200)
    .setRange(10,50)
    .setValue(0)
    .setNumberOfTickMarks(5) 
    ;    
}

void draw() 
{
  //displaying the game
  background(BACK);
  grid.display();
  newGame.display();
}

void mousePressed() 
{
  //how the mouse clicks works
  grid.mousePress();
  newGame.clicked();
}

class Grid 
{
  //creating variables for the grids
  int ww, hh;
  int n;
  int n_total;
  int bombs;
  int margin = the_size*3;  
  boolean lost;
  boolean won;
  int firstCellPressed = -1;
  ArrayList<Cell> cells = new ArrayList<Cell>();

  Grid(int n, int bombs) 
  {
    //creating bombs
    init(n, bombs);
  }

  void init(int n, int bombs) 
  {
    //start initalising bombs
    firstCellPressed = -1;
    
    lost = false;
    won = false;
    
    this.n = n;
    this.bombs = bombs;
    n_total = n*n;
    
    ww = n*the_size + margin*2;
    hh = n*the_size + margin*3;
    
    // reset and create cells
    cells.clear();
    for (int i = 0; i < n_total; i++) 
    {
      cells.add(new Cell(i%n, floor(i/n), i));
    }   
  }
  
  void firstClick(int first) 
  {
    //used java because couldn't get it working in processing code
    firstCellPressed = first;
    
    //exclude cell's index clicked and neighbours
    ArrayList<Integer> ix = new ArrayList<Integer>();
    ix.add(first);
    for (int z = 0; z < 8; z++) 
    {
      if (cells.get(first).vicini[z] > -1 ) 
      {
        ix.add(cells.get(first).vicini[z]);
      }
    }
    Integer[] ixs = ix.toArray(new Integer[ix.size()]);
    //randomly choose the positions of the bombs
    boolean[] bb = new boolean[n_total];
    for (int i = 0; i < bb.length; i++) 
    {
      bb[i] = i < bombs ? true : false;
    }
    bb = arrayShuffle(bb);    
    ArrayList<Boolean> bbs = new ArrayList<Boolean>();
    for (int i = 0; i < bb.length; i++) 
    {
      bbs.add(bb[i]); //<>//
    }
    //add cells' indexes excluded before
    
    for (int i = 0; i < ixs.length; i++) 
    {
      bbs.add(ixs[i], false); //<>//
    }
    //set bombs
    for (int i = 0; i < n_total; i++) 
    {
      cells.get(i).bomb = bbs.get(i);
    }
    //determine value of cells
    for (int i = 0; i < n_total; i++) 
    {
      if (cells.get(i).bomb) 
      {
        cells.get(i).value = -1;
        continue;
      }
      for (int z = 0; z < 8; z++) 
      {
        if (cells.get(i).vicini[z] > -1 && cells.get(cells.get(i).vicini[z]).bomb ) 
        {
          cells.get(i).value++;
        }
      }
    }
  }

  void display() 
  {
    int n_revealed = 0;
    int n_flag = 0;
    
    for (int i = 0; i < n_total; i++) 
    {
      cells.get(i).display();
      if (cells.get(i).type== O && !cells.get(i).bomb) 
      {
        n_revealed++;
      } 
      else if (cells.get(i).type == F) 
      {
        n_flag++;
      }
    }
    
    if (n_revealed == n_total - bombs) 
    {
      won = true;
    }
    
    //create win, lose and flags text
    fill(TEXTS);    
    if (lost) 
    {
      text("LOST :(", 210, 30);
    } 
    else if (won) 
    {
      text("WON :P", 210, 30);
    } 
    else
    {
      text("FLAGS: " + n_flag + "/" + bombs, 210, 30);      
    }
  }

  void mousePress() 
  {    
    if (!won && !lost) 
    {
      for (int i = 0; i < n_total; i++) 
      {
        if (cells.get(i).isUnderMouse()) 
        {
          if (firstCellPressed < 0) firstClick(i);
          
          if (cells.get(i).type == H) 
          {            
            if (mouseButton == LEFT)//open and unflag the cells
            {
              cells.get(i).type = O;
              if (cells.get(i).value == 0) 
              {
                // check all adjacent empty cells
                checkEmpties(i);              
              } 
              else if (cells.get(i).bomb) 
              {
                lost = true;
              }            
            } 
            else if (mouseButton == RIGHT)//flag cells
            {
            cells.get(i).type = F;
            }            
          } 
          else if (cells.get(i).type == F && mouseButton == LEFT)
          {
          cells.get(i).type = H;
          }      
        break;          
        }
      }
    }
  }

  void checkEmpties(int ii) 
  {
    //checking for empty adjacent cells
    for (int i = 0; i < 8; i++) 
    {
      if ( cells.get(ii).vicini[i] > -1 && cells.get(cells.get(ii).vicini[i]).type == H ) 
      {
        cells.get(cells.get(ii).vicini[i]).type = O;
        
        if (cells.get(cells.get(ii).vicini[i]).value == 0) 
        {
          checkEmpties(cells.get(ii).vicini[i]);
        }
      }
    }
  }

  boolean[] arrayShuffle(boolean[] array) 
  {
    int index;
    boolean temp;
    for (int i = array.length - 1; i > 0; i--) 
    {
      index = floor(random(i+1));
      temp = array[index];
      array[index] = array[i];
      array[i] = temp;
    }
    return array;
  }

  class Cell 
  {    
    int x;
    int y;
    
    int[] id = new int[3];
    int value = 0;
    char type = H;
    boolean bomb = false;
    
    //nearby cells
    int[] vicini = new int[8];
    
    Cell(int i, int j, int t) 
    { 
      //check bombs around cell
      id[0] = i;
      id[1] = j;
      id[2] = t;
      
      x = margin + id[0]*the_size;
      y = margin + id[1]*the_size;

      vicini[0] = id[1] - 1 >= 0                   ? t - n     : -1;
      vicini[1] = id[1] + 1 <  n                   ? t + n     : -1;
      vicini[2] = id[0] - 1 >= 0                   ? t - 1     : -1;
      vicini[3] = id[0] + 1 <  n                   ? t + 1     : -1;
      vicini[4] = id[1] - 1 >= 0 && id[0] - 1 >= 0 ? t - n - 1 : -1;
      vicini[5] = id[1] - 1 >= 0 && id[0] + 1 <  n ? t - n + 1 : -1;
      vicini[6] = id[1] + 1 <  n && id[0] - 1 >= 0 ? t + n - 1 : -1;
      vicini[7] = id[1] + 1 <  n && id[0] + 1 <  n ? t + n + 1 : -1;
    }
    
    void display() 
    {
      //display the grid completed with bombs and numbers
      pushStyle();      
      if (type == H) fill(GRID);
      else if (type == F) fill(GRID, 100);
      else fill(BACK);
      rect(x, y, the_size, the_size);
      
      if (type == O || lost) 
      {
        if (value > 0) 
        {
          fill(0);
          text(value, the_size/2 + x, the_size/2 + y);
        } 
        else if (bomb) 
        {
          fill(BOMB);
          text('B', the_size/2 + x, the_size/2 + y);            
        }
      } 
      else if (type == F || won && bomb) 
      {
        if (type == H) type = F;
        fill(FLAG);
        text('F', the_size/2 + x, the_size/2 + y);
      }
      popStyle();
    }
    
    boolean isUnderMouse() 
    {
      if (mouseX > x && mouseX < x + the_size && mouseY > y && mouseY < y + the_size) 
      {
        return true;
      }
      return false;      
    }
  }  
}

class NewGame 
{
  //creating new game
  float x, y;    
  float w, h;
  
  NewGame() 
  {
    x = 210;
    y = 435;
    w = 75;
    h = 25;
  }
  
  void display() 
  {
    //displaing new game button
    pushStyle();
    noStroke();
    rectMode(CENTER);
    fill(255, 150);
    rect(x, y, w, h);
    fill(TEXTS);
    text("New Game", x, y);
    popStyle();
  }
  
  void clicked() 
  {
    //reseting variables
    if (mousePressed && isUnderMouse()) 
    {
        grid.init(N_DEFAULT, B_DEFAULT);
    }
  }
 
  boolean isUnderMouse() 
  {
    if ( abs(mouseX - x) < w/2 && abs(mouseY - y) < h/2 ) 
    {
      return true;
    }
    return false;      
  }  
}

void Size(int s) 
{
  if(s==10)
  {
    N_DEFAULT=10;
    the_size=35;
  }
  else if(s==15)
  {
    N_DEFAULT=15;
    the_size=24;
  }
  else if(s==20)
  {
    N_DEFAULT=20;
    the_size=18;
  } 
  else if(s==25)
  {
    N_DEFAULT=25;
    the_size=15;
  }
  else if(s==30)
  {
    N_DEFAULT=30;
    the_size=12;
  }
}

void Bombs(int s) 
{
  if(s==10)
  {
    B_DEFAULT=10;
  }
  else if(s==20)
  {
    B_DEFAULT=20;
  }
  else if(s==30)
  {
    B_DEFAULT=30;
  } 
  else if(s==40)
  {
    B_DEFAULT=40;
  }
  else if(s==50)
  {
    B_DEFAULT=50;
  }
}