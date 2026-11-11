/* ==============================================================================
 * 👤 ESTUDIANTE 3: CABECERA DE LA TABLA DE SÍMBOLOS
 * ==============================================================================
 * 🎯 RESPONSABILIDAD:
 *    Declara las funciones públicas para la gestión de la tabla de símbolos.
 *    La implementación interna se encuentra en 'tabla.c'.
 *
 * 📋 FUNCIONES PÚBLICAS:
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
