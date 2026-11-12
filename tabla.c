/* ==============================================================================
 * 👤 PARTE DE SAMUEL (Estudiante 3): TABLA DE SÍMBOLOS EN LENGUAJE C
 * ==============================================================================
 * 📌 QUÉ DEBES REVISAR Y SABER EXPLICAR AQUÍ (Defensa Semana 8):
 *    1. Estructura 'Simbolo': lista enlazada con punteros 'cabeza' y 'cola' para
 *       mantener el orden exacto de primera aparición de cada identificador.
 *    2. Por qué es OBLIGATORIO usar strdup(nombre): porque el puntero 'yytext'
 *       de Flex es un buffer interno que se sobrescribe con el siguiente lexema.
 *    3. Cómo se evitan líneas duplicadas: comparando si 'linea' ya es igual a
 *       la última línea almacenada en el arreglo dinámico 'lineas' (y usando
 *       realloc si supera 'cap_lineas').
 *    4. Gestión de memoria: liberación ordenada con free() en tabla_liberar().
 * ============================================================================== */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabla.h"

/* Nodo de la lista enlazada de símbolos */
typedef struct Simbolo {
    char *nombre;              /* Copia independiente del lexema (con strdup) */
    int *lineas;               /* Arreglo dinámico de números de línea */
    int num_lineas;            /* Cantidad actual de líneas registradas */
    int cap_lineas;            /* Capacidad actual antes de usar realloc */
    struct Simbolo *sig;       /* Siguiente símbolo en orden cronológico */
} Simbolo;

/* Punteros privados para mantener orden O(1) al final de la lista */
static Simbolo *cabeza = NULL;
static Simbolo *cola = NULL;
static int total_identificadores = 0;

/* ==============================================================================
 * 👤 SAMUEL — FUNCIÓN 1: tabla_agregar
 * ============================================================================== */
void tabla_agregar(const char *nombre, int linea) {
    /* 1. Buscar si el identificador ya fue registrado previamente */
    Simbolo *actual = cabeza;
    while (actual != NULL) {
        if (strcmp(actual->nombre, nombre) == 0) {
            /* Ya existe: agregar la línea solo si no se ha registrado aún en esta línea */
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

    /* 2. Es un identificador nuevo: reservar nodo y copiar el lexema con strdup */
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
 * 👤 SAMUEL — FUNCIÓN 2: tabla_imprimir
 * ============================================================================== */
void tabla_imprimir(void) {
    printf("\nTABLA DE SÍMBOLOS (%d identificadores)\n", total_identificadores);
    Simbolo *actual = cabeza;
    int indice = 1;
    while (actual != NULL) {
        /* Formato exacto de la consigna: 2 espacios, índice, 2 espacios, nombre %-20s */
        printf("  %d  %-20s líneas:", indice++, actual->nombre);
        for (int j = 0; j < actual->num_lineas; j++) {
            printf(" %d", actual->lineas[j]);
        }
        printf("\n");
        actual = actual->sig;
    }
}

/* ==============================================================================
 * 👤 SAMUEL — FUNCIÓN 3: tabla_liberar
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
