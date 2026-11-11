/* ==============================================================================
 * 📄 minilang.l — ANALIZADOR LÉXICO PRINCIPAL (SCANNER)
 * ==============================================================================
 * 💡 ANALOGÍA CON JAVA:
 *    Este archivo es el equivalente a tu clase 'public class Lexer' o 'Scanner'.
 *    Aquí Flex genera el código en C que lee el código fuente carácter por carácter,
 *    reconoce los patrones y devuelve tokens o reporta errores.
 *
 * 👥 REPARTO DE RESPONSABILIDADES EN ESTA CLASE:
 *    - 👤 ESTUDIANTE 1: Reconocimiento de Tokens Válidos y retorno de códigos.
 *    - 👤 ESTUDIANTE 2: Detección de Errores Léxicos E1 a E6 en Modo Pánico.
 *    - 👤 ESTUDIANTE 4: Función main() para procesar archivos por consola.
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
 * 👤 ESTUDIANTE 1: MÉTODO PARA EMITIR TOKENS VÁLIDOS
 * Formato requerido: línea:columna⇥CLASE⇥lexema
 * ============================================================================== */
static int emitir_token(const char *tipo, int codigo) {
    printf("%d:%d\t%s\t%s\n", linea, col, tipo, yytext);
    ntokens++;
    return codigo;
}

/* ==============================================================================
 * 👤 ESTUDIANTE 2: MÉTODO PARA EMITIR ERRORES EN MODO PÁNICO
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
 * Busca la primera barra '\' con escape inválido y reporta la columna exacta */
static void error_escape_cadena(void) {
    for (int i = 0; i < yyleng; i++) {
        if (yytext[i] == '\\') {
            char next = yytext[i + 1];
            if (next != 'n' && next != 't' && next != '"' && next != '\\') {
                char msg[64];
                sprintf(msg, "secuencia de escape no válida '\\%c'", next);
                emitir_error("E6", msg, linea, col + i);
                return;
            }
            i++; /* Saltar el carácter escapado válido */
        }
    }
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
                          /* Error E3 (Estudiante 2): Comentario sin cerrar al llegar al fin de archivo */
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
       OBLIGATORIO: Se registra en la tabla de símbolos de Estudiante 3 */
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
    /* Cadena válida y/o con errores (Estudiante 1 y Estudiante 2) */
\"(\\[^\n]|[^"\\\n])*\" { 
                          /* Si contiene escape no válido, Estudiante 2 lo detecta con error_escape_cadena */
                          /* De lo contrario, Estudiante 1 emite el token CADENA */
                          return emitir_token("CADENA", T_CADENA); 
                        }

    /* Error E2 (Estudiante 2): Cadena sin cerrar antes del fin de línea */
\"(\\[^\n]|[^"\\\n])*     { emitir_error("E2", "cadena sin cerrar", linea, col); }

    /* Operadores relacionales, lógicos, asignación, aritméticos y delimitadores (Estudiante 1) */
"=="|"!="|"<="|">="|"<"|">"  { return emitir_token("OP_RELACIONAL", T_OP_RELACIONAL); }
"&&"|"||"|"!"           { return emitir_token("OP_LOGICO", T_OP_LOGICO); }
"="                     { return emitir_token("ASIGNACION", T_ASIGNACION); }
[-+*/%]                 { return emitir_token("OP_ARITMETICO", T_OP_ARITMETICO); }
[(){}\[\];,]            { return emitir_token("DELIMITADOR", T_DELIMITADOR); }

    /* Error E1 (Estudiante 2): Cualquier otro carácter o símbolo no reconocido */
.                       { error_caracter(); }

    /* Fin de archivo (EOF) */
<<EOF>>                 { printf("%d:%d\tFIN\t\n", sig_linea, sig_col); return T_FIN; }

%%

/* ==============================================================================
 * 👤 ESTUDIANTE 4: CLASE DRIVER / MAIN PRINCIPAL
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

    /* Impresión de la Tabla de Símbolos completada por Estudiante 3 */
    tabla_imprimir();

    /* Resumen total de tokens y errores */
    printf("\ntokens: %d  errores: %d\n", ntokens, nerrores);

    /* Liberación de memoria dinámica */
    tabla_liberar();

    return 0;
}
