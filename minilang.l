/* minilang.l — Analizador léxico de MiniLang en Flex
 *
 * RESPONSABILIDADES:
 *   - Estudiante 1: Tokens válidos, contadores de línea/columna y códigos tokens.h
 *   - Estudiante 2: Manejo de errores léxicos E1 a E6 en modo pánico
 */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokens.h"
#include "tabla.h"

int linea = 1, col = 1;              /* posición donde empieza el lexema actual */
static int sig_linea = 1, sig_col = 1;
static int com_linea, com_col;        /* posición donde inició comentario de bloque */
int ntokens = 0, nerrores = 0;

/* Actualiza la posición de línea y columna antes de cada acción léxica */
#define YY_USER_ACTION { linea = sig_linea; col = sig_col;               \
    for (int i = 0; i < yyleng; i++)                                     \
        if (yytext[i] == '\n') { sig_linea++; sig_col = 1; }             \
        else sig_col++; }

/* Función auxiliar para imprimir tokens válidos (Estudiante 1) */
static int emitir_token(const char *tipo, int codigo) {
    printf("%d:%d\t%s\t%s\n", linea, col, tipo, yytext);
    ntokens++;
    return codigo;
}

/* Función auxiliar para registrar errores en modo pánico (Estudiante 2) */
static void emitir_error(const char *cod, const char *msg, int l, int c) {
    printf("%d:%d\tERROR %s\t%s\n", l, c, cod, msg);
    nerrores++;
}

/* Manejador de Error E1: Carácter o byte no válido */
static void error_caracter(void) {
    char msg[64];
    unsigned char b = (unsigned char) yytext[0];
    if (b >= 32 && b < 127) sprintf(msg, "carácter no válido '%c'", b);
    else sprintf(msg, "byte no válido 0x%02X", b);
    emitir_error("E1", msg, linea, col);
}

/* Manejador de Error E4: Número mal formado */
static void error_numero(void) {
    char msg[160];
    snprintf(msg, sizeof msg, "número mal formado '%.120s'", yytext);
    emitir_error("E4", msg, linea, col);
}

/* TODO (Estudiante 2): Función auxiliar para Error E6 (secuencia de escape inválida) */
static void error_escape(void) {
    /* Localizar la barra '\' del primer escape no válido dentro de yytext,
       calcular su columna exacta y reportar: emitir_error("E6", ..., linea, col_escape); */
}
%}

%option noyywrap nounput noinput
%x COMENT

DIG         [0-9]
LETRA       [A-Za-z_]
ID          {LETRA}({LETRA}|{DIG})*
ID_INVALIDO {LETRA}({LETRA}|{DIG}){31,}
REAL        {DIG}+"."{DIG}+([eE][+-]?{DIG}+)?|{DIG}+[eE][+-]?{DIG}+

%%

    /* =========================================================================
     * SECCIÓN BASE: ESPACIOS Y COMENTARIOS
     * ========================================================================= */
[ \t\r\n]+              { /* espacios: se descartan */ }
"//".*                  { /* comentario de línea: se descarta */ }
"/*"                    { com_linea = linea; com_col = col; BEGIN(COMENT); }
<COMENT>"*/"            { BEGIN(INITIAL); }
<COMENT>[^*\n]+|"*"|\n  { /* contenido interno del comentario */ }
<COMENT><<EOF>>         { emitir_error("E3", "comentario sin cerrar", com_linea, com_col); BEGIN(INITIAL); }

    /* =========================================================================
     * SECCIÓN ESTUDIANTE 2: REGLAS DE ERRORES CON MAYOR PRECEDENCIA (E4, E5, E6)
     * ========================================================================= */
    /* TODO (Estudiante 2): E5: Identificador de más de 31 caracteres */
{ID_INVALIDO}           { emitir_error("E5", "identificador de más de 31 caracteres", linea, col); }

    /* =========================================================================
     * SECCIÓN ESTUDIANTE 1: TOKENS VÁLIDOS Y RETORNO DE CÓDIGOS DE TOKENS.H
     * ========================================================================= */
entero|real|cadena|logico|si|sino|mientras|para|funcion|retornar|imprimir|leer|verdadero|falso {
                          return emitir_token("PALABRA_RESERVADA", T_RESERVADA); }

{ID}                    { 
                          tabla_agregar(yytext, linea);
                          return emitir_token("IDENTIFICADOR", T_IDENTIFICADOR); 
                        }

{REAL}                  { return emitir_token("REAL", T_REAL); }
{DIG}+                  { return emitir_token("ENTERO", T_ENTERO); }

    /* E4 (Estudiante 2): Número mal formado (longest match cuando hay caracteres tras el número) */
({REAL}|{DIG}+)[A-Za-z0-9_.]+ { error_numero(); }

    /* Cadenas válidas y errores en cadenas (Estudiante 1 y Estudiante 2) */
\"(\\[^\n]|[^\"\\\n])*\" { return emitir_token("CADENA", T_CADENA); }

    /* TODO (Estudiante 2): E6: Cadena con secuencia de escape inválida */
    /* TODO (Estudiante 2): E2: Cadena sin cerrar en la misma línea */
\"(\\[^\n]|[^\"\\\n])*   { emitir_error("E2", "cadena sin cerrar", linea, col); }

    /* Operadores y Delimitadores (Estudiante 1) */
"=="|"!="|"<="|">="|"<"|">"  { return emitir_token("OP_RELACIONAL", T_OP_RELACIONAL); }
"&&"|"||"|"!"           { return emitir_token("OP_LOGICO", T_OP_LOGICO); }
"="                     { return emitir_token("ASIGNACION", T_ASIGNACION); }
[-+*/%]                 { return emitir_token("OP_ARITMETICO", T_OP_ARITMETICO); }
[(){}\[\];,]            { return emitir_token("DELIMITADOR", T_DELIMITADOR); }

    /* Error E1: Cualquier otro carácter no reconocido */
.                       { error_caracter(); }

<<EOF>>                 { printf("%d:%d\tFIN\t\n", sig_linea, sig_col); return T_FIN; }

%%

int main(int argc, char *argv[]) {
    if (argc > 1 && !(yyin = fopen(argv[1], "r"))) {
        perror(argv[1]);
        return 1;
    }
    
    /* Bucle de yylex() hasta recibir T_FIN (0) exigido para conectar con Bison */
    int tok;
    while ((tok = yylex()) != T_FIN) {
        /* Cada llamada a yylex() procesa el siguiente token */
    }

    /* Impresión de la Tabla de Símbolos construida */
    tabla_imprimir();

    /* Resumen final en stdout */
    printf("\ntokens: %d  errores: %d\n", ntokens, nerrores);

    /* Liberación de memoria */
    tabla_liberar();

    return 0;
}
