
int estado = 0;
int regreso = 0;
char texto[256];
char caracter = 'a';
int nivel = 0;
int escape = 0;
int i = 0;
int j = 0;
int contador = 0;
void setup() {
  Serial.begin(9600);
  Serial3.begin(9600);
}

void loop() {

  if (Serial3.available())
  {
    if (Serial3.peek() == 43)   //estado 1(+) quita del buffer el +
    {
      int nivel_snk = 0;
      Serial3.read();
      regreso = 0;
      while (regreso != 64) //@ de salida
      {
        if (Serial3.available())
        {
          if (Serial3.peek() == 49) //nivel 1 (No se destrulle del buffer)
          {
            nivel_snk = 1;
            Serial3.read();
          }
          else if (Serial3.peek() == 50) //nivel 2
          {
            nivel_snk = 2;
            int i = 0;
            int j = 0;
            Serial3.read();
          }
          else if (Serial3.peek() == 51) //nivel 3
          {
            nivel_snk = 3;
            int i = 0;
            int j = 0;
            Serial3.read();
          }
          else if (Serial3.peek() == 52) //nivel 4
          {
            nivel_snk = 4;
            int i = 0;
            int j = 0;
            Serial3.read();
          }
          else if (Serial3.peek() == 64)
          {
            regreso = 64;
            Serial.print("Se salio de jugar");
            Serial3.read();
          }
          else
          {
            if (nivel_snk == 1)
            {
              if (i < 8)
              {
                if (j < 8)
                {
                  Serial.print(Serial3.read());
                  j++;
                }
                else
                {
                  i++;
                  j = 0;
                  Serial.print("\n");

                  if (i == 8)
                  {
                    Serial.print("\n");
                    i = 0;
                  }

                }
              }
            }
            else if (nivel_snk == 2)
            {
              if (i < 8)
              {
                if (j < 8)
                {
                  Serial.print(Serial3.read());
                  j++;
                }
                else
                {
                  i++;
                  j = 0;
                  Serial.print("\n");

                  if (i == 8)
                  {
                    Serial.print("\n");
                    i = 0;
                  }

                }
              }
            }
            else if (nivel_snk == 3)
            {
              if (i < 8)
              {
                if (j < 8)
                {
                  Serial.print(Serial3.read());
                  j++;
                }
                else
                {
                  i++;
                  j = 0;
                  Serial.print("\n");

                  if (i == 8)
                  {
                    Serial.print("\n");
                    i = 0;
                  }

                }
              }
            }
            else if (nivel_snk == 4)
            {
              if (i < 8)
              {
                if (j < 8)
                {
                  Serial.print(Serial3.read());
                  j++;
                }
                else
                {
                  i++;
                  j = 0;
                  Serial.print("\n");

                  if (i == 8)
                  {
                    Serial.print("\n");
                    i = 0;
                  }
                }
              }
            }
            else
            {
              Serial.println("esta en el ciclo pero no hya nivel");
            }
          }
        }
      }
    }
    if(Serial3.peek()== 45){// lee -
      Serial3.read();
      regreso =0;
      int contador = 0;
      while (regreso != 64) {
        if (Serial3.available()){
          caracter = Serial3.read();
          if(caracter == 64){
            regreso = 64;
          } else{
            texto[contador] = caracter;
            contador++;
          }
        }
      }
      for (int i = 0; i < contador; i++) {
        Serial.print(texto[i]);
      }
      Serial.print('\n');
      regreso =0;
      while (regreso != 64) {
        if (Serial3.available()){
          caracter = Serial3.read();
          if(caracter == 64){
            regreso = 64;
          } else if (caracter == 35){// opcion1 #
            Serial.print("Estoy de dentro afuera");
          }else if (caracter == 37){ // opcion2 %
            Serial.print("Estoy de fuera dentro");
          }else if (caracter == 38){// opcion 3 &
            Serial.print("Estoy de izq a der");
          }else if (caracter == 36){// opcion 4  $
            Serial.print("Estoy de der izq");
          }
        }
      }

    }
    if(Serial3.peek() == 47){// lee /
      Serial3.read();
      regreso = 0;
      while(regreso != 64){
        if (Serial3.available()){
          caracter = Serial3.read();
          if(caracter == 64){
            regreso = 64;
          } else if (caracter == 35){
          // le damos el mando a jose
          int salida = 0;
            while(salida == 0){
              if(Serial.available()){
                caracter = (char)Serial.read();
                if(caracter == 'a'){
                    Serial3.print(caracter);
                    Serial.print(caracter);
                    salida =1;
                }else{
                    Serial.print(caracter);
                }
              }
            }
          }
        }

      }
    }
  }

}
