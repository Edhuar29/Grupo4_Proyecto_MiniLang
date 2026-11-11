// Prueba p4: Casos límite y situaciones de borde
// Responsable: Eduardo (QA y Suite de Pruebas)

// 1. Identificador de exactamente 31 caracteres (VÁLIDO, debe registrarse en la tabla de símbolos)
entero id_limite_exacto_de_31_caract_1 = 31;

// 2. Números reales al borde de la especificación (con exponente y decimales válidos)
real r1 = 2.5e-3;
real r2 = 1E3;
real r3 = 100.005E+2;
real r4 = 0.001e-10;

// 3. Comentarios // y /* dentro de cadenas literales (NO deben interpretarse como comentarios)
cadena url = "http://localhost:8080/api/datos";
cadena bloque = "/* esto es texto dentro de cadena, no un comentario */";

// 4. Múltiples escapes válidos en una misma cadena (\n, \t, \", \\)
cadena escapes = "Tab:\tSalto:\nComilla:\"Barra:\\";

// 5. Delimitadores anidados y operadores relacionales/lógicos
si ((id_limite_exacto_de_31_caract_1 >= 30) && !(r1 == 0.0)) {
  imprimir("Casos limite superados exitosamente\n", escapes);
}
