/* tabla.h — Interfaz de la Tabla de Símbolos de identificadores
 *
 * RESPONSABLE: Estudiante 3 (Estructura de Datos y Gestión de Memoria en C)
 */
#ifndef TABLA_H
#define TABLA_H

/* Agrega un identificador a la tabla con la línea donde apareció.
 * Requisitos:
 *  - Si el identificador ya existe, añade la línea a su lista si no está repetida.
 *  - Si es nuevo, reserva memoria con strdup() y lo inserta al final de la lista.
 */
void tabla_agregar(const char *nombre, int linea);

/* Imprime la tabla con el formato exacto requerido:
 *
 * TABLA DE SÍMBOLOS (N identificadores)
 *   1  n                    líneas: 2 4 5 6
 *   2  suma                 líneas: 3 5 8
 */
void tabla_imprimir(void);

/* Libera toda la memoria dinámica reservada */
void tabla_liberar(void);

#endif
