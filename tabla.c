/* tabla.c — Implementación de la Tabla de Símbolos de identificadores
 *
 * RESPONSABLE: Estudiante 3 (Estructura de Datos y Gestión de Memoria en C)
 *
 * REQUISITOS OBLIGATORIOS:
 *   1. Cada identificador aparece UNA sola vez, en el orden de primera aparición.
 *   2. Registra las líneas donde aparece, sin repetir números de línea.
 *   3. Copia el nombre usando strdup() (yytext se sobreescribe en cada token).
 *   4. Imprime con formato exacto:
 *        TABLA DE SÍMBOLOS (N identificadores)
 *          1  nombre               líneas: 2 4 5
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabla.h"

/* Estructura para registrar los identificadores */
typedef struct Simbolo {
    char *nombre;              /* Cadena copiada con strdup */
    int *lineas;               /* Arreglo dinámico de líneas */
    int num_lineas;            /* Cantidad de líneas registradas */
    int cap_lineas;            /* Capacidad del arreglo de líneas */
    struct Simbolo *sig;       /* Puntero al siguiente símbolo (orden cronológico) */
} Simbolo;

static Simbolo *cabeza = NULL;
static Simbolo *cola = NULL;
static int total_identificadores = 0;

void tabla_agregar(const char *nombre, int linea) {
    /* TODO (Estudiante 3):
     * 1. Buscar si 'nombre' ya está en la lista enlazada (usando strcmp).
     * 2. Si ya existe:
     *    - Verificar si 'linea' ya está registrada en sim->lineas.
     *    - Si no está, agregarla (redimensionar arreglo si num_lineas == cap_lineas).
     * 3. Si no existe:
     *    - Crear nuevo nodo Simbolo con malloc.
     *    - Copiar nombre con strdup(nombre).
     *    - Inicializar arreglo de líneas (ej. capacidad inicial 4) y guardar 'linea'.
     *    - Enlazar al final de la lista con cola->sig = nuevo; cola = nuevo.
     *    - Incrementar total_identificadores.
     */
}

void tabla_imprimir(void) {
    /* TODO (Estudiante 3):
     * Imprimir exactamente:
     * printf("\nTABLA DE SÍMBOLOS (%d identificadores)\n", total_identificadores);
     * Recorrer desde cabeza:
     *   printf("  %-3d%-21s líneas:", i, sim->nombre);
     *   para cada línea j:
     *     printf(" %d", sim->lineas[j]);
     *   printf("\n");
     */
    printf("\nTABLA DE SÍMBOLOS (%d identificadores)\n", total_identificadores);
}

void tabla_liberar(void) {
    /* TODO (Estudiante 3):
     * Recorrer la lista enlazada liberando sim->nombre, sim->lineas y el propio nodo sim.
     */
}
