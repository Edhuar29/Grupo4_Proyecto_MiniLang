/* ==============================================================================
 * 👤 ESTUDIANTE 3 (Samuel): IMPLEMENTACIÓN DE LA TABLA DE SÍMBOLOS EN C
 * ==============================================================================
 * 🎯 RESPONSABILIDAD:
 *    Almacenar los identificadores encontrados durante el análisis léxico.
 *
 * 📋 REQUISITOS OBLIGATORIOS:
 *    1. Cada identificador aparece UNA sola vez, en el orden de primera aparición.
 *    2. Registra las líneas donde aparece, sin repetir números de línea.
 *    3. Copia el nombre obligatoriamente con strdup(nombre) (yytext cambia).
 *    4. Imprime con el formato exacto requerido por el docente:
 *         TABLA DE SÍMBOLOS (N identificadores)
 *           1  nombre               líneas: 2 4 5
 *    5. Liberar toda la memoria con free() en tabla_liberar().
 * ============================================================================== */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabla.h"

/* Estructura para almacenar cada símbolo de forma dinámica */
typedef struct Simbolo {
    char *nombre;              /* Cadena propia reservada con strdup() */
    int *lineas;               /* Arreglo dinámico de números de línea */
    int num_lineas;            /* Cantidad actual de líneas registradas */
    int cap_lineas;            /* Capacidad máxima del arreglo antes de realloc */
    struct Simbolo *sig;       /* Puntero al siguiente símbolo (orden cronológico) */
} Simbolo;

/* Punteros de control para la lista enlazada */
static Simbolo *cabeza = NULL;
static Simbolo *cola = NULL;
static int total_identificadores = 0;

/* ==============================================================================
 * FUNCIÓN: tabla_agregar
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
 * FUNCIÓN: tabla_imprimir
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
 * FUNCIÓN: tabla_liberar
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
