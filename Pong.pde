//Bib. para reproduzir sons
import ddf.minim.*;
//Bib. para ler o que está no serial
import processing.serial.*;
//Porta serial
String serialPortName = "COM7";
Serial arduino;
//Sons
Minim minim;
AudioPlayer wallSound, batSound, backSound;
//img
PImage ball, bat_p1, bat_p2, back, pauseImg;
//Posicao das raquetes
float bat_p1_Position, bat_p2_Position;
//Posicao bola
float ballX, ballY;
//Passo
float vertSpeed, horiSpeed;
//O que recebe do arduino
String[] value;
int p1_score=0;
int p2_score=0;
PFont f;
int count=0;

//Tamanho do campo
int largura = 800;
int altura = 600;
//Pause/reset
int pause, reset;
void setup()
{
  size(largura, altura);
  if (serialPortName.equals("")) scanForArduino();
  else arduino = new Serial(this, serialPortName, 9600);
  imageMode(CENTER);
  //Carrega as img da pasta data
  ball = loadImage("ball.png");
  bat_p1 = loadImage("bat.png");
  bat_p2 = loadImage("bat2.png");
  back = loadImage("back.png");
  pauseImg = loadImage("pauseImg.png");
  // Fonte 
  // Exibe o placar  
  f = loadFont("AgencyFB-Bold-48.vlw"); 
  textFont(f, 40);
  minim = new Minim(this);
  wallSound = minim.loadFile("wall.mp3");
  batSound = minim.loadFile("bat.mp3");
  backSound = minim.loadFile("backSound.mp3");  
  bat_p1_Position = bat_p1.height/2;
  bat_p2_Position = bat_p2.height/2;
  backSound.loop();
  resetBall(true);
}

//Centeriza a bola apos gol
void resetBall(boolean flag)
{
  ballX = largura/2;
  ballY = altura/2;
  if (flag)
  {
    horiSpeed = -1;
    vertSpeed = -1;
  }
  else
  {
    horiSpeed = +1;
    vertSpeed = +1;    
  }
}

void resetGame()
{
  p1_score = 0;
  p2_score = 0;
  resetBall(true);
}
void draw()
{
  //Imagem do campo
  image(back, width/2, height/2, width, height);
  text(p1_score, 350, 35);
  text(p2_score, 430, 35);
  /***********PAUSE********************/
  while(pause == 1)
  {
    if ((arduino != null) && (arduino.available()>0)) 
    {
      String message = arduino.readStringUntil('\n');
      if (message != null) 
      {
        //Separa os valores dos potenciometros
        value = split(message, '|');
        if (value.length==4) 
        {
          pause = int(trim(value[2]));
          reset = int(trim(value[3]));
          if(reset == 1)
          {
            resetGame();
          }
        }
      }
    }
  }
  /***********************************/  
  // Efetua leitura dos dados da serial do arduino
  if ((arduino != null) && (arduino.available()>0)) 
  {
    String message = arduino.readStringUntil('\n');
    if (message != null) 
    {
      //Separa os valores dos potenciometros
      value = split(message, '|');
      if (value.length==4) 
      {
        pause = int(trim(value[2]));
        if(pause == 1) image(pauseImg, width/2, height/2);        
        reset = int(trim(value[3]));
        if(reset == 1)
        {
          resetGame();
        }
        bat_p1_Position = map(int(trim(value[0])), 0, 1024, height-50, 50);
        bat_p2_Position = map(int(trim(value[1])), 0, 1024, height-50, 50);
      }
    }
  }
 
  // Desenha os jogadores na nova posicao
  //image(caminho, pos_horizontal, pos_vertical);
  image(bat_p1, bat_p1.height-100, bat_p1_Position);
  image(bat_p2, largura-20, bat_p2_Position);



  // Calcula nova posicao da bola
  ballX = ballX + horiSpeed;
  ballY = ballY + vertSpeed;
  if (ballX >= largura) 
  { 
    p1_score++; 
    resetBall(true);
  }
  if (ballX <= 0) 
  { 
    p2_score++; 
    resetBall(false);
  }

  if (ballY >= altura) invertDirection();
  if (ballY <= 0) invertDirection();

  // Desenha a bola na nova posicao
  //Fonte:
  translate(ballX, ballY);
  if (horiSpeed > 0) rotate(-sin(vertSpeed/horiSpeed));
  else rotate(PI-sin(vertSpeed/horiSpeed));
  image(ball, 0, 0);

  // Deteccao de colisao
  //Bola toca raquete 1
  if (bat_p1_TouchingBall()) {
    float distFromBat_p1_Center = bat_p1_Position-ballY;
    horiSpeed = -horiSpeed;
    horiSpeed++;
    vertSpeed++;
    batSound.rewind();
    batSound.play();
  }
  //Bola toca raquete 2  
  if (bat_p2_TouchingBall()) {
    float distFromBat_p2_Center = bat_p2_Position-ballX;
    horiSpeed = -horiSpeed;
    horiSpeed--;
    vertSpeed--;    
    batSound.rewind();
    batSound.play();
  }
}
//Detecta se bola tocou raquete 1
boolean bat_p1_TouchingBall()
{
  float distFromBat_p1_Center = bat_p1_Position-ballY;
  return (ballX < (bat_p1.width*2)) && (ballX > (bat_p1.width/2)) && (abs(distFromBat_p1_Center)<bat_p1.height/2);
}
//Detecta se bola tocou raquete 2
boolean bat_p2_TouchingBall()
{
  float distFromBat_p2_Center = bat_p2_Position-ballY;
  return (ballX > width-(bat_p2.width*2)) && (ballX < width-(bat_p2.width/2)) && (abs(distFromBat_p2_Center)<bat_p2.height/2);
}
//Inverte direcao da bola quando toca as laterais do campo
void invertDirection()
{
  vertSpeed = -vertSpeed;
  wallSound.rewind();
  wallSound.play();
}

//Ao pressionar botao stop da IDE
void stop()
{
  arduino.stop();
}

//Busca o arduino nas portas COM
void scanForArduino()
{
  try {
    for (int i=0; i<Serial.list().length ;i++) {
      if (Serial.list()[i].contains("tty.usb")) {
        arduino = new Serial(this, Serial.list()[i], 9600);
      }
    }
  } 
  catch(Exception e) {
    // println("Nao foi possivel conectar no arduino !");
  }
}

