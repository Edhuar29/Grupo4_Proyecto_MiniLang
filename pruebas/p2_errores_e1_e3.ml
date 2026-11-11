// Prueba p2: Detección y recuperación de errores E1, E2 y E3
// Responsable: Eduardo (QA y Suite de Pruebas)

entero radio = 5;
real area = 3.1416 * radio * radio;

// Error E1: Caracteres no válidos (@ y $)
real precio@base = 100.50;
entero total$ = 200;

// Error E2: Cadena sin cerrar en la misma línea
cadena saludo = "Hola mundo sin cerrar comilla;
entero x = 10;

// Modo pánico: el análisis continúa normalmente
si (x > 0) {
  imprimir("x es positivo\n");
}

// Error E3: Comentario de bloque sin cerrar al llegar al final del archivo
/* Este comentario de bloque se queda abierto hasta el final del archivo
