/*
Created By: Ben-Tommy Eriksen
Created On: 2012-11-10
Website / More Infomation: http://www.nornet.no/arduino/
Email: ben@nornet.no

Some code by:
Created By: Samleong
Created On: 2011-9-17
Website / More Infomation: http://www.b2cqshop.com
Email: b2cqshop@gmail.com

Made for:
Arduino 0023 software
Arduino Mega 2560
Serial LCD 1602 
IR remodecontroll
Servo shild V5

Attaches the servo 1 on pin 4 to the servo object 
Attaches the servo 2 on pin 5 to the servo object 
Attaches the servo 3 on pin 6 to the servo object 
Attaches the servo 4 on pin 7 to the servo object
Attaches the servo 5 on pin 8 to the servo object 

Infrared receiver Pin 23

LCD SLC pin 21
LCD SDA pin 20

*/

#include <Wire.h> 

#include <LiquidCrystal_I2C.h>

boolean running = false;

long previousMillis = 0;        // will store last time LED was updated

// the follow variables is a long because the time, measured in miliseconds,
// will quickly become a bigger number than can be stored in an int.
long interval = 1000;           // interval at which to blink (milliseconds)

#include <Servo.h> 
 
Servo myservo1;  // create servo object to control a servo 
Servo myservo2;  // create servo object to control a servo 
Servo myservo3;  // create servo object to control a servo 
Servo myservo4;  // create servo object to control a servo 
Servo myservo5;  // create servo object to control a servo 

#define IR_IN  23  //Infrared receiver Pin

int MenyValg = 0;
int MenyValgOld = 1;
int ServoValg = 1;
int ServoValgOld = 1;
int ServoValue = 512;
int MenyValgAntall = 15; // Antall poster i Preference arr 
int MenyHigh = 0;

char* PreferenceText[] = {"Robot 1","Robot 2","Robot 3","Robot 4","Robot 5","Robot 6","Robot 7","Robot 8",};
int PreferenceValue[] = {1,1000,1,0}; 
int PreferenceValueOld[] = {0,0,0,1};
int PreferenceValueMin[] = {0,100,1,0};
int PreferenceValueMax[] = {1,10000,20,1};
int PreferenceValueInc[] = {1,100,1,1};

int Servo1Value[] = {512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512};
int Servo2Value[] = {512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512}; 
int Servo3Value[] = {512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512}; 
int Servo4Value[] = {512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512}; 
int Servo5Value[] = {512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512}; 

int Servo1ValueNew = 512;
int Servo2ValueNew = 512;
int Servo3ValueNew = 512;
int Servo4ValueNew = 512;
int Servo5ValueNew = 512;

int Servo1ValueOld = 512;
int Servo2ValueOld = 512;
int Servo3ValueOld = 512;
int Servo4ValueOld = 512;
int Servo5ValueOld = 512;

int aminStep = 50;
int a = 0;

int PreferenceTallVerdier[] = {1,0,0,1};
char* PreferencePrefix[] = {" (1=start 0=stopp)"," steps/m sek"," steps/interval"};
char* PreferenceVerdier[] = {"Off","On"};

int Pulse_Width=0;//Storage width 
int adr_code=0x00;// User-coded values
char comL_code=0x00;//Command code
char comH_code=0x00;//Anti-code command

LiquidCrystal_I2C lcd(0x27,16,4);  // set the LCD address to 0x27 for a 20 chars and 4 line display



void setup()
{
  unsigned char i;
  pinMode(IR_IN,INPUT);//Set the infrared receiver input pin
  
  // start serial port at 9600 bps:
  Serial.begin(9600);
   
  myservo1.attach(4);  // attaches the servo 1 on pin 4 to the servo object 
  myservo2.attach(5);  // attaches the servo 2 on pin 5 to the servo object 
  myservo3.attach(6);  // attaches the servo 3 on pin 6 to the servo object 
  myservo4.attach(7);  // attaches the servo 4 on pin 7 to the servo object
  myservo5.attach(8);  // attaches the servo 5 on pin 8 to the servo object 
  
  lcd.init();                      // initialize the lcd 
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("ARDUINO");

  lcd.setCursor(0, 1);
  lcd.print("booting");
  
  timer1_init();//Timer initialization
}
void loop()
{  
    if (running == true) {
      MenyValg++;
      if (MenyValg>MenyHigh) {MenyValg = 0;}
      SetServoStepAnim();
    
    
    }
    remote_decode();  //Decoding
    remote_deal();   //Perform decoding results
    
    MenuCase();

    MenuLCD();
    ServoLCD();
    
    //SerialStatus();
    
    unsigned long currentMillis = millis();
    if(currentMillis - previousMillis > PreferenceValue[1]) {
      // save the last time you blinked the LED 
      previousMillis = currentMillis;   
  
      if (PreferenceValue[0] == 1) {
        digitalWrite(13, HIGH);

        if (MenyValg == 0) {
          lcd.setCursor(12, 0);
        }
        delay(50);
        digitalWrite(13, LOW);
      } 
    }
}

void SerialStatus() {
  Serial.print("0-");
  Serial.print(Servo1Value[0]);
  Serial.print("-");
  Serial.print(Servo2Value[0]);
  Serial.print("-");
  Serial.print(Servo3Value[0]);
  Serial.print("-");
  Serial.print(Servo4Value[0]);
  Serial.print("-");
  Serial.println(Servo5Value[0]);
  Serial.print("1-");
  Serial.print(Servo1Value[1]);
  Serial.print("-");
  Serial.print(Servo2Value[1]);
  Serial.print("-");
  Serial.print(Servo3Value[1]);
  Serial.print("-");
  Serial.print(Servo4Value[1]);
  Serial.print("-");
  Serial.println(Servo5Value[1]);
}

void MenuLCD() {
  lcd.setCursor(0, 0);
  lcd.print("Step   ");
  lcd.setCursor(5, 0);
  lcd.print(MenyValg);
}

void AnimatioLCD(int a2) {
  lcd.setCursor(8, 0);
  lcd.print("Anim   ");
  lcd.setCursor(13, 0);
  lcd.print(a2);
}

void ServoLCD() {
  lcd.setCursor(0, 1);
  lcd.print("Servo   ");
  lcd.setCursor(6, 1);
  lcd.print(ServoValg);
  lcd.setCursor(8, 1);
  lcd.print("    ");
  lcd.setCursor(8, 1);
  LoadServoValue();
  lcd.print(ServoValue);
  
}

int LoadServoValue() {
  if (MenyValg>MenyHigh) {// Copy last step position
    Servo1Value[MenyValg] = Servo1Value[MenyHigh];
    Servo2Value[MenyValg] = Servo2Value[MenyHigh];
    Servo3Value[MenyValg] = Servo3Value[MenyHigh];
    Servo4Value[MenyValg] = Servo4Value[MenyHigh];
    Servo5Value[MenyValg] = Servo5Value[MenyHigh];
    MenyHigh = MenyValg;
  
  }
  
  switch (ServoValg) {
  
    case 1:
      ServoValue = Servo1Value[MenyValg];
      break;
    case 2:
      ServoValue = Servo2Value[MenyValg];
      break;
    case 3:
      ServoValue = Servo3Value[MenyValg];
      break;
    case 4:
      ServoValue = Servo4Value[MenyValg];
      break;
    case 5:
      ServoValue = Servo5Value[MenyValg];
      break;
  }

}

void SetServoStepAnim() {
    ServoLCD();
    for (a = 0; a < aminStep; a++) {
      ServoValue = map(a, 0, aminStep, Servo1ValueOld, Servo1Value[MenyValg]);
      ServoValue = map(ServoValue, 0, 1023, 179, 0);
      myservo1.write(ServoValue);
      
      
      ServoValue = map(a, 0, aminStep, Servo2ValueOld, Servo2Value[MenyValg]);
      ServoValue = map(ServoValue, 0, 1023, 0, 179);
      myservo2.write(ServoValue);
      
      
      ServoValue = map(a, 0, aminStep, Servo3ValueOld, Servo3Value[MenyValg]);
      ServoValue = map(ServoValue, 0, 1023, 0, 179);
      myservo3.write(ServoValue);
      
      
      ServoValue = map(a, 0, aminStep, Servo4ValueOld, Servo4Value[MenyValg]);
      ServoValue = map(ServoValue, 0, 1023, 0, 179);
      myservo4.write(ServoValue);
      
      
      ServoValue = map(a, 0, aminStep, Servo5ValueOld, Servo5Value[MenyValg]);
      ServoValue = map(ServoValue, 0, 1023, 0, 179);
      myservo5.write(ServoValue);
      
      AnimatioLCD(a);
      
 
    }
    
    Servo1ValueOld = Servo1Value[MenyValg];
    Servo2ValueOld = Servo2Value[MenyValg];
    Servo3ValueOld = Servo3Value[MenyValg];
    Servo4ValueOld = Servo4Value[MenyValg];
    Servo5ValueOld = Servo5Value[MenyValg];
    

}

int SaveServoValue() {
  switch (ServoValg) {
  
    case 1:
      Servo1Value[MenyValg] = ServoValue;
      Servo1ValueOld = ServoValue;
      break;
    case 2:
      Servo2Value[MenyValg] = ServoValue;
      Servo2ValueOld = ServoValue;
      break;
    case 3:
      Servo3Value[MenyValg] = ServoValue;
      Servo3ValueOld = ServoValue;
      break;
    case 4:
      Servo4Value[MenyValg] = ServoValue;
      Servo4ValueOld = ServoValue;
      break;
    case 5:
      Servo5Value[MenyValg] = ServoValue;
      Servo5ValueOld = ServoValue;
      break;
  }
}

void SetServoStepPos() {
    ServoValue = map(Servo1Value[MenyValg], 0, 1023, 179, 0);
    myservo1.write(ServoValue);
    
    ServoValue = map(Servo2Value[MenyValg], 0, 1023, 0, 179);
    myservo2.write(ServoValue);
    
    ServoValue = map(Servo3Value[MenyValg], 0, 1023, 0, 179);
    myservo3.write(ServoValue);
    
    ServoValue = map(Servo4Value[MenyValg], 0, 1023, 0, 179);
    myservo4.write(ServoValue);
    
    ServoValue = map(Servo5Value[MenyValg], 0, 1023, 0, 179);
    myservo5.write(ServoValue);

}



void MenuCase() {
  switch (comL_code) {
      case 64: // Buttom >>|            
        LoadServoValue();
        MenyValg++;
        MenuLCD();
        SetServoStepAnim();
        SerialStatus();
        if (MenyValg>MenyValgAntall) {MenyValg = MenyValgAntall;}
        
        break;
        
      case 68: // Buttom |<<
        LoadServoValue();
        MenyValg--;
        MenuLCD();
        SetServoStepAnim();
        SerialStatus();
        if (MenyValg<0) {MenyValg = 0;}
        break;
      
        
      case 13: // Buttom Enter
        MenyValg = 0;
        break;
        
      case 70: // Buttom Meny
    
        break;
        
      case 67: // Start
        running = true;
        break;
        
      case 69: // Stopp
        running = false;
        break;
        
      
      case 22: //Butom  0

        break;
      
      case 12: //Butom  1
        ServoValg = 1;
        break;
      
      case 24: //Butom  2
        ServoValg = 2;
        break;
         
      case 94: //Butom  3
        ServoValg = 3;
        break;
        
      case 8: //Butom  4
        ServoValg = 4;
        break;
        
      case 28: //Butom  5
        ServoValg = 5;
        break;
        
      case 7: //Butom  -
        LoadServoValue();
        ServoValue = ServoValue - 8;
        if (ServoValue<0) {ServoValue = 0;}
        SaveServoValue();
        SetServoStepPos();
        break;
      
      case 21: //Butom  +
        LoadServoValue();
        ServoValue = ServoValue + 8;
        if (ServoValue>1023) {ServoValue = 1023;}
        SaveServoValue();
        SetServoStepPos();
        break;
    
    }
}

void timer1_init(void)//Timer initialization function
{
  TCCR1A = 0X00; 
  TCCR1B = 0X05;//To the timer clock source
  TCCR1C = 0X00;
  TCNT1 = 0X00;
  TIMSK1 = 0X00;	//Disable timer overflow interrupt
}
void remote_deal(void)//The results of the implementation of decoding function
{ 
      //Show Data
      if(adr_code!=0XFF)
      {
        Serial.print("the Address Code is : "); 
        Serial.println(adr_code, HEX);//Hexadecimal display
        Serial.print("the Command code is : ");
        Serial.println(comL_code, DEC);//Hexadecimal display
      }
}
char logic_value()//Determine the logic value "0" and "1" Functions
{
  TCNT1 = 0X00;
  while(!(digitalRead(IR_IN))); //Low wait
  Pulse_Width=TCNT1;
  TCNT1=0;
  if(Pulse_Width>=7&&Pulse_Width<=10)//Low 560us
  {
    while(digitalRead(IR_IN));//Is waiting for another job
    Pulse_Width=TCNT1;
    TCNT1=0;
    if(Pulse_Width>=7&&Pulse_Width<=10)//Then high 560us
      return 0;
    else if(Pulse_Width>=25&&Pulse_Width<=27) //Then high 1.7ms
      return 1;
  }
  return -1;
}
void pulse_deal()//Receiver address code and command code pulse function
{
  int i;
  int j;
  adr_code=0x00;// Clear
  comL_code=0x00;// Clear
  comH_code=0x00;// Clear

  //Parsing remote code value in the user code  
  for(i = 0 ; i < 16; i++)
  {
    if(logic_value() == 1) //if 1
        adr_code |= (1<<i);//Save value
  }
  //Parsing code in the remote control command codes
  for(i = 0 ; i < 8; i++)
  {
    if(logic_value() == 1) //if 1
      comL_code |= (1<<i);//Save value
  }
  //Parsing code in the remote control command codes counter code
  for(j = 0 ; j < 8; j++)
  {
    if(logic_value() == 1) //if 1
        comH_code |= (1<<j);//Save value
  }
}
void remote_decode(void)//Decoding function
{
  TCNT1=0X00;       
  while(digitalRead(IR_IN))//if high then waiting
  {
    if(TCNT1>=1563)  //When the high lasts longer than 100ms, that no button is pressed at this time
    {
      adr_code=0x00ff;// User-coded values
      comL_code=0x00;//Key code value of the previous byte
      comH_code=0x00;//After a byte key code value
      return;
    }  
  }

  //If the high does not last more than 100ms
  TCNT1=0X00;

  while(!(digitalRead(IR_IN))); //Low wait
  Pulse_Width=TCNT1;
  TCNT1=0;
  if(Pulse_Width>=140&&Pulse_Width<=142)//9ms
  {

    while(digitalRead(IR_IN));//high wait
    Pulse_Width=TCNT1;
    TCNT1=0;
    if(Pulse_Width>=68&&Pulse_Width<=72)//4.5ms
    {  
      pulse_deal();
      return;
    }
    else if(Pulse_Width>=34&&Pulse_Width<=36)//2.25ms
    {
      while(!(digitalRead(IR_IN)));//low wait
      Pulse_Width=TCNT1;
      TCNT1=0;
      if(Pulse_Width>=7&&Pulse_Width<=10)//560us
      {
        return; 
      }
    }
  }
}







