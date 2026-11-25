/* ==============================================================================
 *  minilang.l — ANALIZADOR LÉXICO COMPLETO DE MINILANG (FLEX Y C)
 * ============================================================================== */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokens.h"
#include "tabla.h"


int linea = 1, col = 1;
static int sig_linea = 1, sig_col = 1;
int ntokens = 0, nerrores = 0;

/* Actualiza la posición del analizador antes de cada regla. */
#define YY_USER_ACTION { linea = sig_linea; col = sig_col;               \
    for (int i = 0; i < yyleng; i++)                                     \
        if (yytext[i] == '\n') { sig_linea++; sig_col = 1; }             \
        else sig_col++; }

/* Imprime el token reconocido y devuelve su código correspondiente. */
static int emitir_token(const char *tipo, int codigo) {
    printf("%d:%d\t%s\t%s\n", linea, col, tipo, yytext);
    ntokens++;
    return codigo;
}

/* Almacena la posición inicial de un comentario de bloque. */
static int com_linea, com_col;       

static void emitir_error(const char *cod, const char *msg, int l, int c) {
    printf("%d:%d\tERROR %s\t%s\n", l, c, cod, msg);
    nerrores++;
}

/* Detecta caracteres que no pertenecen al lenguaje. */
static void error_caracter(void) {
    char msg[64];
    unsigned char b = (unsigned char) yytext[0];
    if (b >= 32 && b < 127) snprintf(msg, sizeof msg, "carácter no válido '%c'", b);
    else snprintf(msg, sizeof msg, "byte no válido 0x%02X", b);
    emitir_error("E1", msg, linea, col);
}

/* Detecta números mal formados. */
static void error_numero(void) {
    char msg[160];
    snprintf(msg, sizeof msg, "número mal formado '%.120s'", yytext);
    emitir_error("E4", msg, linea, col);
}

/*
 * Verifica las secuencias de escape de una cadena.
 * Los escapes permitidos son: \n, \t, \" y \\.
 * Devuelve 1 si encuentra un escape inválido.
 */
static int verificar_escapes_cadena(void) {
    for (int i = 0; i < yyleng; i++) {
        if (yytext[i] == '\\') {
            char next = yytext[i + 1];
            if (next != 'n' && next != 't' && next != '"' && next != '\\') {
                char msg[64];
                snprintf(msg, sizeof msg, "secuencia de escape no válida '\\%c'", next);
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


DIG         [0-9]
LETRA       [A-Za-z_]
ID          {LETRA}({LETRA}|{DIG})*
ID_INVALIDO {LETRA}({LETRA}|{DIG}){31,}
REAL        {DIG}+"."{DIG}+([eE][+-]?{DIG}+)?|{DIG}+[eE][+-]?{DIG}+

%%


[ \t\r\n]+              { /* Espacios y tabuladores: se descartan */ }
"//".*                  { /* Comentario de línea: se descarta hasta \n */ }

"/*"                    { com_linea = linea; com_col = col; BEGIN(COMENT); }
<COMENT>"*/"            { BEGIN(INITIAL); }
<COMENT>[^*\n]+|"*"|\n  { /* Contenido interno del comentario de bloque */ }
<COMENT><<EOF>>         {
                          /* Error E3 (Ariel): Comentario abierto al llegar al EOF */
                          emitir_error("E3", "comentario de bloque sin cerrar", com_linea, com_col);
                          BEGIN(INITIAL);
                        }


{ID_INVALIDO}           { emitir_error("E5", "identificador de más de 31 caracteres", linea, col); }

   
entero|real|cadena|logico|si|sino|mientras|para|funcion|retornar|imprimir|leer|verdadero|falso {
                          return emitir_token("PALABRA_RESERVADA", T_RESERVADA); }

{ID}                    {
                          /* Registra el identificador y la línea donde aparece. */
                          tabla_agregar(yytext, linea);
                          return emitir_token("IDENTIFICADOR", T_IDENTIFICADOR);
                        }

{REAL}                  { return emitir_token("REAL", T_REAL); }
{DIG}+                  { return emitir_token("ENTERO", T_ENTERO); }

    /* Detecta números seguidos de caracteres no permitidos. */
({REAL}|{DIG}+)[A-Za-z0-9_.]+ { error_numero(); }


\"(\\[^\n]|[^"\\\n])*\" {
                          if (!verificar_escapes_cadena()) {
                              return emitir_token("CADENA", T_CADENA);
                          }
                        }

\"(\\[^\n]|[^"\\\n])*\\?   { emitir_error("E2", "cadena sin cerrar", linea, col); }

    /* Operadores y delimitadores */
"=="|"!="|"<="|">="|"<"|">"  { return emitir_token("OP_RELACIONAL", T_OP_RELACIONAL); }
"&&"|"||"|"!"                { return emitir_token("OP_LOGICO", T_OP_LOGICO); }
"="                          { return emitir_token("ASIGNACION", T_ASIGNACION); }
[-+*/%]                      { return emitir_token("OP_ARITMETICO", T_OP_ARITMETICO); }
[(){}\[\];,]               { return emitir_token("DELIMITADOR", T_DELIMITADOR); }

    /* Detecta caracteres que no pertenecen al lenguaje. */
.                       { error_caracter(); }

<<EOF>>                 { printf("%d:%d\tFIN\t\n", sig_linea, sig_col); return T_FIN; }

%%

/*
 * Función principal: abre el archivo de entrada, ejecuta el analizador,
 * imprime la tabla de símbolos y el resumen de resultados.
 */
int main(int argc, char *argv[]) {
    if (argc > 1 && !(yyin = fopen(argv[1], "r"))) {
        perror(argv[1]);
        return 1;
    }

    int tok;
    while ((tok = yylex()) != T_FIN) {
        /* El analizador continúa hasta el fin del archivo. */
    }

    tabla_imprimir();
    printf("\ntokens: %d  errores: %d\n", ntokens, nerrores);
    tabla_liberar();

    return 0;
}
