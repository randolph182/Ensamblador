
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
  Serial1.begin(9600);
}

void loop() {

  if (Serial1.available())
  {
    if (Serial1.peek() == 43)  //(+) =============================ESTADO UNO --> CON PEEK SOLO LEEMOS JUGAR ================
    {
      int nivel_snk = 0;
      Serial1.read(); //DESTRUIMOS
      regreso = 0;
      while (regreso != 64) //@  CARACTER DE SALIDA
      {
        if (Serial1.available())
        {
          if (Serial1.peek() == 49) // (1) NIVEL 1
          {
            nivel_snk = 1;
            Serial1.read();
          }
          else if (Serial1.peek() == 50) // (2) NIVEL 2
          {
            nivel_snk = 2;
            int i = 0;
            int j = 0;
            Serial1.read();
          }
          else if (Serial1.peek() == 51) // (3) NIVEL 3
          {
            nivel_snk = 3;
            int i = 0;
            int j = 0;
            Serial1.read();
          }
          else if (Serial1.peek() == 52) // (4) NIVEL 4
          {
            nivel_snk = 4;
            int i = 0;
            int j = 0;
            Serial1.read();
          }
          else if (Serial1.peek() == 64) //(@) CARACTER DE SALIDA
          {
            regreso = 64;
            //Serial.print("Se salio de jugar");
            Serial1.read();
          }
          else
          {
            if (nivel_snk == 1)  //============ NIVEL 1========================
            {
              if (i < 8)
              {
                if (j < 8)
                {
                  Serial.print(Serial1.read());
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
            else if (nivel_snk == 2) //============ NIVEL 2========================
            {
              if (i < 8)
              {
                if (j < 8)
                {
                  Serial.print(Serial1.read());
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
            else if (nivel_snk == 3)  //============ NIVEL 3========================
            {
              if (i < 8)
              {
                if (j < 8)
                {
                  Serial.print(Serial1.read());
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
            else if (nivel_snk == 4) //============ NIVEL 4========================
            {
              if (i < 8)
              {
                if (j < 8)
                {
                  Serial.print(Serial1.read());
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
    if(Serial1.peek()== 45){// caracter(-) ============================ESTADO 2 ============ LEER ARCHIVO===================
      Serial1.read();
      regreso =0;
      int contador = 0;
      while (regreso != 64) {
        if (Serial1.available()){
          caracter = Serial1.read();
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
        if (Serial1.available()){
          caracter = Serial1.read();
          if(caracter == 64){
            regreso = 64;
          } else if (caracter == 35){//=============== opcion1 #
            Serial.print("Estoy de dentro afuera");
          }else if (caracter == 37){ //=============== opcion2 %
            Serial.print("Estoy de fuera dentro");
          }else if (caracter == 38){//================ opcion 3 &
            Serial.print("Estoy de izq a der");
          }else if (caracter == 36){//================ opcion 4  $
            Serial.print("Estoy de der izq");
          }
        }
      }

    }
    if(Serial1.peek() == 42) //caracter(*) ============================= ESTADO 3 =========== MODO REPOSO ===================
    {
      Serial1.read();
      regreso =0;
      while(regreso != 64){
        if(Serial1.available() >0){
          caracter = Serial1.read();
          if(caracter == 64){
            regreso = 64;
          }else if(caracter == 35){ //caracter(#)======== REPOSO1========
            //espacio para jose
            Serial.print("Reposo1");
          }else if(caracter == 37){ //caracter(%)======== REPOSO2=======
            //espacio para jose
            Serial.print("Reposo2");
          }else if(caracter == 38){ //caracter(&)======== REPOSO3=======
            //espacio para jose
            Serial.print("Reposo3");
          }
        }
      }
    }
    if(Serial1.peek() == 47){// caracter(/) ============================ESTADO 4 ============ APLICACION MOVIL ===================
      Serial1.read();
      regreso = 0;
      while(regreso != 64){   //wHILE QUE ESPERA POR UNA OPCION EN EL SUBMENU DE MODO REPOSO
        if (Serial1.available()){
          caracter = Serial1.read();
          if(caracter == 64){
            regreso = 64;
          } else if (caracter == 35){ //caracter (#) ============== OPCION PARA ACTIVAR EL MOVIL CON  ========================
          // le damos el mando a jose
          int salida = 0;
            while(salida == 0){
              if(Serial.available()){
                caracter = (char)Serial.read();
                if(caracter == 'a'){
                    Serial1.print(caracter);
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
