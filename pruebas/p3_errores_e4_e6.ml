// Prueba p3: Detección y recuperación de errores E4, E5 y E6
// Responsable: Eduardo (QA y Suite de Pruebas)

// Error E4: Números mal formados (letras pegadas al número, múltiples puntos, exponente trunco)
entero plazo = 2dias;
real version = 1.2.3;
real constante = 7e;

// Error E5: Identificadores mayores a 31 caracteres (se descartan y NO entran a la tabla de símbolos)
entero variable_muy_larga_de_32_chars_x = 50;
real acumulador_global_de_registros_temporales_total = 99.9;

// Identificadores válidos para comprobar recuperación en modo pánico
entero contador = 1;
real tasa = 0.15;

// Error E6: Secuencia de escape no válida en una cadena cerrada
cadena ruta1 = "archivo\qdatos.txt";
cadena ruta2 = "texto\xhexadecimal";

// Cadena válida posterior
imprimir("fin de prueba p3\n");
