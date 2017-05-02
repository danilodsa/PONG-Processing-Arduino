const int buttonPause = 8;
const int buttonReset = 7;

int pause = 0;
int reset = 0;
boolean paused = false;

void setup() 
{
  pinMode(buttonPause,INPUT);
  pinMode(buttonReset,INPUT);
  pinMode(0,INPUT);
  pinMode(1,INPUT);  // Seta pino A0 e A1 como entrada
  Serial.begin(9600);   // Inicia comunicação serial
}

void loop() 
{
  int readinga0 = analogRead(0); //Lê porta A0 (Potenciometro 1)
  int readinga1 = analogRead(1); //Lê porta A1 (Potenciometro 2)
   if ((digitalRead(buttonPause)) and (paused == false))
   {
      pause = 1;
      paused = true;
      delay(100);
   }
   else if ((digitalRead(buttonPause)) and (paused == true))
   {
      pause = 0;
      paused = false;
      delay(100);
   }
  if (digitalRead(buttonReset))
  {
    reset = 1;
  }
  
  String sendstr=(String)readinga0+"|"+(String)readinga1+"|"+(String)pause+"|"+(String)reset; //Coloca separador entre os valores
  reset = 0;
  Serial.println(sendstr); //Manda string para serial
  delay(50);                      
}
