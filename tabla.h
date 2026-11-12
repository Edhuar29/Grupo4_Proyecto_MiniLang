/* ==============================================================================
 * 👤 PARTE DE SAMUEL (Estudiante 3): INTERFAZ DE LA TABLA DE SÍMBOLOS
 * ==============================================================================
 * 📌 QUÉ DEBES REVISAR Y SABER EXPLICAR AQUÍ (Defensa Semana 8):
 *    1. Cómo este archivo .h expone las funciones públicas hacia 'minilang.l'.
 *    2. En qué momento se invoca cada función: tabla_agregar() al leer un ID,
 *       tabla_imprimir() al terminar el archivo y tabla_liberar() antes de salir.
 * ============================================================================== */
#ifndef TABLA_H
#define TABLA_H

/* Agrega un identificador con la línea donde apareció (evitando líneas duplicadas) */
void tabla_agregar(const char *nombre, int linea);

/* Imprime la tabla formateada según la especificación obligatoria */
void tabla_imprimir(void);

/* Libera toda la memoria dinámica asignada para evitar fugas */
void tabla_liberar(void);

#endif
