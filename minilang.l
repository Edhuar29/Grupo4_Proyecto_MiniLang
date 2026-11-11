/* ==============================================================================
 * 📄 minilang.l — ANALIZADOR LÉXICO PRINCIPAL DE MINILANG (FLEX)
 * ==============================================================================
 * 🎯 DESCRIPCIÓN:
 *    Especificación léxica para Flex que analiza el código fuente carácter por carácter,
 *    reconoce los tokens válidos, maneja errores léxicos en modo pánico y gestiona
 *    la tabla de símbolos.
 *
 * 👥 REPARTO DE RESPONSABILIDADES:
 *    - 👤 ESTUDIANTE 1 (Melany): Reconocimiento de Tokens Válidos y códigos de tokens.h.
 *    - 👤 ESTUDIANTE 2 (Ariel): Detección y recuperación de Errores Léxicos E1 a E6.
 *    - 👤 ESTUDIANTE 4 (Eduardo): Función main() para ejecución por consola.
 * ============================================================================== */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokens.h"
#include "tabla.h"

int linea = 1, col = 1;              /* Posición donde empieza el lexema actual */
static int sig_linea = 1, sig_col = 1;
static int com_linea, com_col;        /* Posición donde inició comentario de bloque */
int ntokens = 0, nerrores = 0;

/* Macro que Flex ejecuta automáticamente antes de cada acción léxica */
#define YY_USER_ACTION { linea = sig_linea; col = sig_col;               \
    for (int i = 0; i < yyleng; i++)                                     \
        if (yytext[i] == '\n') { sig_linea++; sig_col = 1; }             \
        else sig_col++; }

/* ==============================================================================
 * 👤 ESTUDIANTE 1 (Melany): MÉTODO PARA EMITIR TOKENS VÁLIDOS
 * Formato requerido: línea:columna⇥CLASE⇥lexema
 * ============================================================================== */
static int emitir_token(const char *tipo, int codigo) {
    printf("%d:%d\t%s\t%s\n", linea, col, tipo, yytext);
    ntokens++;
    return codigo;
}

/* ==============================================================================
 * 👤 ESTUDIANTE 2 (Ariel): MÉTODO PARA EMITIR ERRORES EN MODO PÁNICO
 * Formato requerido: línea:columna⇥ERROR Ek⇥mensaje
 * ============================================================================== */
static void emitir_error(const char *cod, const char *msg, int l, int c) {
    printf("%d:%d\tERROR %s\t%s\n", l, c, cod, msg);
    nerrores++;
}

/* Error E1: Carácter no válido (@, #, $, ?, o bytes extraños) */
static void error_caracter(void) {
    char msg[64];
    unsigned char b = (unsigned char) yytext[0];
    if (b >= 32 && b < 127) sprintf(msg, "carácter no válido '%c'", b);
    else sprintf(msg, "byte no válido 0x%02X", b);
    emitir_error("E1", msg, linea, col);
}

/* Error E4: Número mal formado (ej. 2dias, 1.2.3, 7e) */
static void error_numero(void) {
    char msg[160];
    snprintf(msg, sizeof msg, "número mal formado '%.120s'", yytext);
    emitir_error("E4", msg, linea, col);
}

/* Error E6: Secuencia de escape no válida en una cadena (ej. "hola\q")
 * Busca la primera barra '\' con escape inválido y reporta la columna exacta.
 * Devuelve 1 si encontró un escape inválido, o 0 si todos son válidos. */
static int verificar_escapes_cadena(void) {
    for (int i = 0; i < yyleng; i++) {
        if (yytext[i] == '\\') {
            char next = yytext[i + 1];
            if (next != 'n' && next != 't' && next != '"' && next != '\\') {
                char msg[64];
                sprintf(msg, "secuencia de escape no válida '\\%c'", next);
                emitir_error("E6", msg, linea, col + i);
                return 1;
            }
            i++; /* Saltar el carácter escapado válido */
        }
    }
    return 0;
}
%}

%option noyywrap nounput noinput
%x COMENT

/* Definiciones regulares (Expresiones regulares con nombre) */
DIG         [0-9]
LETRA       [A-Za-z_]
ID          {LETRA}({LETRA}|{DIG})*
ID_INVALIDO {LETRA}({LETRA}|{DIG}){31,}
REAL        {DIG}+"."{DIG}+([eE][+-]?{DIG}+)?|{DIG}+[eE][+-]?{DIG}+

%%

    /* =========================================================================
     * SECCIÓN BASE: ESPACIOS EN BLANCO Y COMENTARIOS
     * ========================================================================= */
[ \t\r\n]+              { /* Espacios y tabs: se descartan silenciosamente */ }
"//".*                  { /* Comentario de línea: se descarta hasta el fin de línea */ }

"/*"                    { com_linea = linea; com_col = col; BEGIN(COMENT); }
<COMENT>"*/"            { BEGIN(INITIAL); }
<COMENT>[^*\n]+|"*"|\n  { /* Contenido interno del comentario de bloque */ }
<COMENT><<EOF>>         { 
                          /* Error E3 (Ariel): Comentario sin cerrar al llegar al fin de archivo */
                          emitir_error("E3", "comentario de bloque sin cerrar", com_linea, com_col); 
                          BEGIN(INITIAL); 
                        }

    /* =========================================================================
     * 👤 SECCIÓN ESTUDIANTE 2: ERRORES LÉXICOS QUE TIENEN PRECEDENCIA (E5)
     * ========================================================================= */
    /* E5: Identificador de más de 31 caracteres
       Va ANTES de {ID} para que Flex aplique esta regla si el identificador es largo.
       REGLA: Se descarta y NO entra a la tabla de símbolos. */
{ID_INVALIDO}           { emitir_error("E5", "identificador de más de 31 caracteres", linea, col); }

    /* =========================================================================
     * 👤 SECCIÓN ESTUDIANTE 1: TOKENS VÁLIDOS DE MINILANG
     * ========================================================================= */
    /* Palabras reservadas */
entero|real|cadena|logico|si|sino|mientras|para|funcion|retornar|imprimir|leer|verdadero|falso {
                          return emitir_token("PALABRA_RESERVADA", T_RESERVADA); }

    /* Identificadores válidos (<= 31 caracteres):
       OBLIGATORIO: Se registra en la tabla de símbolos de Samuel */
{ID}                    { 
                          tabla_agregar(yytext, linea);
                          return emitir_token("IDENTIFICADOR", T_IDENTIFICADOR); 
                        }

    /* Números Reales y Enteros */
{REAL}                  { return emitir_token("REAL", T_REAL); }
{DIG}+                  { return emitir_token("ENTERO", T_ENTERO); }

    /* =========================================================================
     * 👤 SECCIÓN ESTUDIANTE 2: ERROR E4 (NÚMERO MAL FORMADO)
     * ========================================================================= */
    /* E4: Un número seguido de letras, dígitos o puntos extras (ej. 2dias, 1.2.3, 7e) */
({REAL}|{DIG}+)[A-Za-z0-9_.]+ { error_numero(); }

    /* =========================================================================
     * 👤 SECCIÓN ESTUDIANTE 1 & 2: CADENAS Y SUS ERRORES (E2 y E6)
     * ========================================================================= */
    /* Cadena válida y/o con errores (Melany y Ariel) */
\"(\\[^\n]|[^"\\\n])*\" { 
                          /* Ariel: Detección de error E6 si contiene escape no válido */
                          if (!verificar_escapes_cadena()) {
                              /* Si todos los escapes son válidos, Melany emite el token CADENA */
                              return emitir_token("CADENA", T_CADENA);
                          }
                        }

    /* Error E2 (Ariel): Cadena sin cerrar antes del fin de línea */
\"(\\[^\n]|[^"\\\n])*     { emitir_error("E2", "cadena sin cerrar", linea, col); }

    /* Operadores relacionales, lógicos, asignación, aritméticos y delimitadores (Melany) */
"=="|"!="|"<="|">="|"<"|">"  { return emitir_token("OP_RELACIONAL", T_OP_RELACIONAL); }
"&&"|"||"|"!"           { return emitir_token("OP_LOGICO", T_OP_LOGICO); }
"="                     { return emitir_token("ASIGNACION", T_ASIGNACION); }
[-+*/%]                 { return emitir_token("OP_ARITMETICO", T_OP_ARITMETICO); }
[(){}\[\];,]            { return emitir_token("DELIMITADOR", T_DELIMITADOR); }

    /* Error E1 (Ariel): Cualquier otro carácter o símbolo no reconocido */
.                       { error_caracter(); }

    /* Fin de archivo (EOF) */
<<EOF>>                 { printf("%d:%d\tFIN\t\n", sig_linea, sig_col); return T_FIN; }

%%

/* ==============================================================================
 * 👤 ESTUDIANTE 4 (Eduardo): CLASE DRIVER / MAIN PRINCIPAL
 * ============================================================================== */
int main(int argc, char *argv[]) {
    if (argc > 1 && !(yyin = fopen(argv[1], "r"))) {
        perror(argv[1]);
        return 1;
    }
    
    /* Bucle que invoca a yylex() hasta recibir T_FIN (0) (requerido para Bison en Semana 12) */
    int tok;
    while ((tok = yylex()) != T_FIN) {
        /* yylex() se encarga de emitir cada token e interactuar con la tabla */
    }

    /* Impresión de la Tabla de Símbolos completada por Samuel */
    tabla_imprimir();

    /* Resumen total de tokens y errores */
    printf("\ntokens: %d  errores: %d\n", ntokens, nerrores);

    /* Liberación de memoria dinámica */
    tabla_liberar();

    return 0;
}
