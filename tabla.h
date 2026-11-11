/* ==============================================================================
 * 👤 ESTUDIANTE 3: INTERFAZ DE LA TABLA DE SÍMBOLOS
 * ==============================================================================
 * 💡 ANALOGÍA CON JAVA:
 *    Este archivo '.h' es el equivalente exacto a una 'public interface ISymbolTable'.
 *    Define los métodos públicos que el analizador léxico puede invocar.
 *    La implementación de la lógica interna va en 'tabla.c'.
 *
 * 🎯 MÉTODOS PÚBLICOS DE ESTA INTERFAZ:
 * ============================================================================== */
#ifndef TABLA_H
#define TABLA_H

/* Equivalente en Java a: void agregar(String nombre, int linea); */
void tabla_agregar(const char *nombre, int linea);

/* Equivalente en Java a: void imprimir(); */
void tabla_imprimir(void);

/* Equivalente en Java a: void liberarMemoria(); (en C la memoria se libera a mano) */
void tabla_liberar(void);

#endif
