/* ==============================================================================
 * 👤 ESTUDIANTE 3: IMPLEMENTACIÓN DE LA TABLA DE SÍMBOLOS
 * ==============================================================================
 * 💡 ANALOGÍA CON JAVA:
 *    Este archivo '.c' es como tu clase 'public class SymbolTable implements ISymbolTable'.
 *    En Java usarías:
 *       class Simbolo { String nombre; List<Integer> lineas; Simbolo sig; }
 *    Aquí en C usamos 'struct Simbolo' con punteros y memoria dinámica (malloc/free).
 *
 * 🎯 TU MISIÓN PASO A PASO:
 *    [ ] 1. En 'tabla_agregar':
 *           - Buscar si el identificador ya existe en la lista (usando strcmp).
 *           - Si YA EXISTE:
 *             * Mirar su última línea registrada; si no es igual a 'linea', agregarla.
 *           - Si NO EXISTE:
 *             * Crear un nuevo Simbolo con malloc.
 *             * Copiar el nombre obligatoriamente con strdup(nombre) (yytext cambia).
 *             * Guardar la primera línea de aparición.
 *             * Enlazarlo al final de la lista para conservar el orden cronológico.
 *             * Incrementar total_identificadores.
 *
 *    [ ] 2. En 'tabla_imprimir':
 *           - Imprimir el encabezado exacto:
 *             TABLA DE SÍMBOLOS (N identificadores)
 *           - Recorrer la lista en orden (del 1 al N) e imprimir:
 *               1  n                    líneas: 2 4 5 6
 *               2  suma                 líneas: 3 5 8
 *
 *    [ ] 3. En 'tabla_liberar':
 *           - Recorrer y liberar con free() el nombre, las líneas y cada nodo.
 *
 * 🧪 CÓMO PROBAR QUE TU CLASE FUNCIONA:
 *    Compila con 'make' y corre './minilang pruebas/p1_correcto.ml'.
 *    Al final de la salida debe aparecer la tabla con 2 identificadores ('n' y 'suma').
 * ============================================================================== */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabla.h"

/* Estructura equivalente a tu clase interna 'Simbolo' en Java */
typedef struct Simbolo {
    char *nombre;              /* Cadena propia reservada con strdup() */
    int *lineas;               /* Arreglo dinámico de números de línea */
    int num_lineas;            /* Cantidad actual de líneas registradas */
    int cap_lineas;            /* Capacidad máxima del arreglo antes de realloc */
    struct Simbolo *sig;       /* Puntero al siguiente símbolo (orden de aparición) */
} Simbolo;

/* Variables privadas de la "clase" (punteros a inicio y fin de la lista) */
static Simbolo *cabeza = NULL;
static Simbolo *cola = NULL;
static int total_identificadores = 0;

/* ==============================================================================
 * MÉTODO 1: AGREGAR O ACTUALIZAR SÍMBOLO
 * ============================================================================== */
void tabla_agregar(const char *nombre, int linea) {
    /* 1. Buscar si ya existe en la lista enlazada */
    Simbolo *actual = cabeza;
    while (actual != NULL) {
        if (strcmp(actual->nombre, nombre) == 0) {
            /* Ya existe: agregar la línea solo si es distinta a la última guardada */
            if (actual->num_lineas == 0 || actual->lineas[actual->num_lineas - 1] != linea) {
                if (actual->num_lineas >= actual->cap_lineas) {
                    actual->cap_lineas *= 2;
                    actual->lineas = (int *) realloc(actual->lineas, actual->cap_lineas * sizeof(int));
                }
                actual->lineas[actual->num_lineas++] = linea;
            }
            return;
        }
        actual = actual->sig;
    }

    /* 2. No existe: crear un nuevo nodo al final */
    Simbolo *nuevo = (Simbolo *) malloc(sizeof(Simbolo));
    nuevo->nombre = strdup(nombre); /* OBLIGATORIO: strdup */
    nuevo->cap_lineas = 4;
    nuevo->num_lineas = 1;
    nuevo->lineas = (int *) malloc(nuevo->cap_lineas * sizeof(int));
    nuevo->lineas[0] = linea;
    nuevo->sig = NULL;

    if (cabeza == NULL) {
        cabeza = nuevo;
        cola = nuevo;
    } else {
        cola->sig = nuevo;
        cola = nuevo;
    }
    total_identificadores++;
}

/* ==============================================================================
 * MÉTODO 2: IMPRIMIR TABLA FORMATEADA
 * ============================================================================== */
void tabla_imprimir(void) {
    printf("\nTABLA DE SÍMBOLOS (%d identificadores)\n", total_identificadores);
    Simbolo *actual = cabeza;
    int indice = 1;
    while (actual != NULL) {
        /* Formato estricto: dos espacios, índice, dos espacios, nombre alineado a 20 chars */
        printf("  %d  %-20s líneas:", indice++, actual->nombre);
        for (int j = 0; j < actual->num_lineas; j++) {
            printf(" %d", actual->lineas[j]);
        }
        printf("\n");
        actual = actual->sig;
    }
}

/* ==============================================================================
 * MÉTODO 3: LIBERAR MEMORIA (DESTRUCTOR)
 * ============================================================================== */
void tabla_liberar(void) {
    Simbolo *actual = cabeza;
    while (actual != NULL) {
        Simbolo *temp = actual;
        actual = actual->sig;
        free(temp->nombre);
        free(temp->lineas);
        free(temp);
    }
    cabeza = NULL;
    cola = NULL;
    total_identificadores = 0;
}
