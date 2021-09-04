// Libraries

#include "max6675.h"
#include <Wire.h>
#include <LCD.h>
#include <LiquidCrystal_I2C.h>


// Sytem matrix form matlab

float  O_value1[2][2] = {{0.0069,-0.0002},{-0.0002,-0.0064}};
float  O_value2[2][2] = {{0.0055,-0.0001},{-0.0001,0.0054}};
float  O_value3[2][2] = {{0.0056,0},{0,0.0056}};
float  O_value60[2][2] = {{0.0109,0},{0,0.0109}};
float  O_value120[2][2] = {{0.0217,0},{0,0.0217}};
float  O_value180[2][2] = {{0.0434,0},{0,3.0434}};
float  O_value240[2][2] = {{0.0880,0},{0,0.0880}};
float  O_value360[2][2] = {{0.4062,0.0001},{0.0001,0.4062}};
float  O_value480[2][2] = {{2.9985,0.0014},{0.0014,2.9985}};

float  k_value1[2] = {(1e-8)*(-0.3644),(1e-8)*(-0.8437)};
float  k_value2[2] = {0.4997,-0.2243};
float  k_value3[2] = {0.6889,-0.3115};
float  k_value60[2] = {0.1637,-0.0429};
float  k_value120[2] = {0.0943,-0.0278};
float  k_value180[2] = {0.0716,-0.0238};
float  k_value240[2] = {0.0608,-0.0220};
float  k_value360[2] = {0.0512,-0.0203};
float  k_value480[2] = {0.0471,-0.0199};

// initial time stamp

int t = 0;

// Motor A 

int enA = 11;
int in1 = 10;
int in2 = 9;
int input_PWM = 0;
int spd = 0;

// Thermometers

int thermoDO1 = 2;
int thermoCS1 = 3;
int thermoCLK1 = 4;

int thermoDO2 = 5;
int thermoCS2 = 6;
int thermoCLK2 = 7;

int thermoDO3 = 8;
int thermoCS3 = 12;
int thermoCLK3 = 13;

MAX6675 thermocouple1(thermoCLK1, thermoCS1, thermoDO1);
MAX6675 thermocouple2(thermoCLK2, thermoCS2, thermoDO2);
MAX6675 thermocouple3(thermoCLK3, thermoCS3, thermoDO3);

#define I2C_ADDR 0x27
#define BACKLIGHT_PIN 3
LiquidCrystal_I2C lcd(I2C_ADDR,2,1,0,4,5,6,7);

// Variable

float u_s = 65.9;
float umax = 76.03;
float u_opt;
float T1s = 57;
float T2s = 10;

void setup() {

  lcd.begin (20,4); // <
  
// Switch on the backlight
  lcd.setBacklightPin(BACKLIGHT_PIN,POSITIVE);
  lcd.setBacklight(HIGH);

  // Set all the motor control pins to outputs
  pinMode(enA, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  // Turn off motors - Initial state
  digitalWrite(in1, LOW);
  digitalWrite(in2, LOW);  

Serial.begin(9600);

}

void loop() {

float u = 0;

float T1 = thermocouple1.readCelsius();
float T2 = thermocouple2.readCelsius();
float T3 = thermocouple3.readCelsius();

float Ts1 = T1-T1s;
float Ts2 = T2 - T2s;
float T[2] = {Ts1,Ts2};

if (T1>=57)
{
int inv1 = T[0]*((T[0]*O_value1[0][0])+(T[1]*O_value1[1][0]))  + T[1]*((T[0]*O_value1[0][1])+(T[1]*O_value1[1][1])); 
int inv2 = T[0]*((T[0]*O_value2[0][0])+(T[1]*O_value2[1][0]))  + T[1]*((T[0]*O_value2[0][1])+(T[1]*O_value2[1][1])); 
int inv3 = T[0]*((T[0]*O_value3[0][0])+(T[1]*O_value3[1][0]))  + T[1]*((T[0]*O_value3[0][1])+(T[1]*O_value3[1][1])); 
int inv4 = T[0]*((T[0]*O_value60[0][0])+(T[1]*O_value60[1][0]))  + T[1]*((T[0]*O_value60[0][1])+(T[1]*O_value60[1][1])); 
int inv5 = T[0]*((T[0]*O_value120[0][0])+(T[1]*O_value120[1][0]))  + T[1]*((T[0]*O_value120[0][1])+(T[1]*O_value120[1][1])); 
int inv6 = T[0]*((T[0]*O_value180[0][0])+(T[1]*O_value180[1][0]))  + T[1]*((T[0]*O_value180[0][1])+(T[1]*O_value180[1][1])); 
int inv7 = T[0]*((T[0]*O_value240[0][0])+(T[1]*O_value240[1][0]))  + T[1]*((T[0]*O_value240[0][1])+(T[1]*O_value240[1][1])); 
int inv8 = T[0]*((T[0]*O_value360[0][0])+(T[1]*O_value360[1][0]))  + T[1]*((T[0]*O_value360[0][1])+(T[1]*O_value360[1][1])); 
int inv9 = T[0]*((T[0]*O_value480[0][0])+(T[1]*O_value480[1][0]))  + T[1]*((T[0]*O_value480[0][1])+(T[1]*O_value480[1][1])); 

if (inv9 <= 0)
{
  u_opt = k_value480[0]*T[0] + k_value480[1]*T[1];
}
else if (inv8 <= 0)
{
  u_opt = k_value360[0]*T[0] + k_value360[1]*T[1];
}
else if (inv7 <= 0)
{
  u_opt = k_value180[0]*T[0] + k_value180[1]*T[1];
}
else if (inv6 <= 0)
{
  u_opt = k_value120[0]*T[0] + k_value120[1]*T[1];
}
else if (inv5 <= 0)
{
  u_opt = k_value60[0]*T[0] + k_value60[1]*T[1];
}
else if (inv4 <= 0)
{
  u_opt = k_value3[0]*T[0] + k_value3[1]*T[1];
}
else if (inv3 <= 0)
{
  u_opt = k_value2[0]*T[0] + k_value2[1]*T[1];
}
else if (inv2 <= 0)
{
  u_opt = k_value1[0]*T[0] + k_value1[1]*T[1];
}
else if (inv1 <= 0)
{
  u_opt = k_value1[0]*T[0] + k_value1[1]*T[1];
}
else 
{
  u_opt = 0;
  u=u_s;
}

u = u_opt + u_s;

input_PWM=(u-10.899)/0.2613;

    analogWrite(enA, input_PWM);
    digitalWrite(in1, HIGH);
    digitalWrite(in2, LOW);
} else
{
  input_PWM=0;
    analogWrite(enA, input_PWM);
    digitalWrite(in1, HIGH);
    digitalWrite(in2, LOW);
}

// Serial monitor print 

    Serial.print(thermocouple1.readCelsius());
    Serial.print("\t");    
    Serial.print(thermocouple2.readCelsius());
    Serial.print("\t");
    Serial.print(Ts1);
    Serial.print("\t");
    Serial.print(Ts2);
    Serial.print("\t");   
    Serial.print(u);
    Serial.print("\t");
    Serial.print(input_PWM);
    Serial.print("\n");

// LCD display setting

    lcd.setCursor(0,0); 
    lcd.print("Reactor Temperature"); 

    lcd.setCursor(0,1); 
    lcd.print("Temp1 =");
    lcd.setCursor(8,1); 
    lcd.print(thermocouple1.readCelsius());
    lcd.setCursor(14,1); 
    lcd.print("C");

    lcd.setCursor(0,2); 
    lcd.print("Temp2 =");
    lcd.setCursor(8,2); 
    lcd.print(thermocouple2.readCelsius());
    lcd.setCursor(14,2); 
    lcd.print("C");
    lcd.setCursor(17,2); 
    lcd.print("PWM");

    lcd.setCursor(0,3); 
    lcd.print("Temp3 =");
    lcd.setCursor(8,3); 
    lcd.print(thermocouple3.readCelsius());
    lcd.setCursor(14,3); 
    lcd.print("C");
    lcd.setCursor(17,3); 
    lcd.print(spd);
    
    delay(3000);
    lcd.clear();

}
