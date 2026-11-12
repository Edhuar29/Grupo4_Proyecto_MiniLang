/* ==============================================================================
 * 📄 minilang.l — ANALIZADOR LÉXICO COMPLETO DE MINILANG (FLEX Y C)
 * ==============================================================================
 * 👥 GUÍA PARA REVISIÓN DE CADA INTEGRANTE (Defensa Semana 8):
 *    - 👤 MELANY (Estudiante 1): Definiciones regulares, conteo línea/columna,
 *      reglas de tokens válidos, emitir_token() y retorno de códigos de tokens.h.
 *    - 👤 ARIEL  (Estudiante 2): Reglas de errores E1 a E6, estado <COMENT>,
 *      verificar_escapes_cadena(), emitir_error() y recuperación en modo pánico.
 *    - 👤 SAMUEL (Estudiante 3): Integración con tabla_agregar(), tabla_imprimir()
 *      y tabla_liberar() (implementadas en tabla.c).
 *    - 👤 EDUARDO (Estudiante 4): Función main() con bucle yylex() hasta T_FIN,
 *      Makefile y batería de pruebas en pruebas/.
 * ============================================================================== */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokens.h"
#include "tabla.h"

/* ==============================================================================
 * 👤 PARTE DE MELANY (Estudiante 1): POSICIÓN (LÍNEA/COLUMNA) Y EMISIÓN DE TOKENS
 * 📌 REVISAR: YY_USER_ACTION se ejecuta antes de cada regla. Guarda dónde inició
 *    el lexema actual (linea, col) y avanza sig_col (un tab cuenta como 1 col).
 * ============================================================================== */
int linea = 1, col = 1;
static int sig_linea = 1, sig_col = 1;
int ntokens = 0, nerrores = 0;

#define YY_USER_ACTION { linea = sig_linea; col = sig_col;               \
    for (int i = 0; i < yyleng; i++)                                     \
        if (yytext[i] == '\n') { sig_linea++; sig_col = 1; }             \
        else sig_col++; }

/* Imprime el token en formato 'línea:columna\tCLASE\tlexema' y devuelve su código */
static int emitir_token(const char *tipo, int codigo) {
    printf("%d:%d\t%s\t%s\n", linea, col, tipo, yytext);
    ntokens++;
    return codigo;
}

/* ==============================================================================
 * 👤 PARTE DE ARIEL (Estudiante 2): MANEJO DE ERRORES LÉXICOS (E1 A E6)
 * 📌 REVISAR: Cada función reporta el error con su posición exacta y el análisis
 *    continúa sin detenerse (modo pánico).
 * ============================================================================== */
static int com_linea, com_col;        /* Línea y columna donde abrió el bloque */

static void emitir_error(const char *cod, const char *msg, int l, int c) {
    printf("%d:%d\tERROR %s\t%s\n", l, c, cod, msg);
    nerrores++;
}

/* Error E1 (Ariel): Carácter o byte no válido */
static void error_caracter(void) {
    char msg[64];
    unsigned char b = (unsigned char) yytext[0];
    if (b >= 32 && b < 127) sprintf(msg, "carácter no válido '%c'", b);
    else sprintf(msg, "byte no válido 0x%02X", b);
    emitir_error("E1", msg, linea, col);
}

/* Error E4 (Ariel): Número mal formado (ej. 2dias, 1.2.3, 7e) */
static void error_numero(void) {
    char msg[160];
    snprintf(msg, sizeof msg, "número mal formado '%.120s'", yytext);
    emitir_error("E4", msg, linea, col);
}

/* Error E6 (Ariel): Secuencia de escape no válida en una cadena (ej. "hola\q")
 * Recorre yytext buscando el primer '\' seguido de algo distinto a n, t, ", \
 * y calcula la columna exacta de esa barra invertida (col + i). */
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

/* ==============================================================================
 * 👤 PARTE DE MELANY Y ARIEL: DEFINICIONES REGULARES CON NOMBRE
 * 📌 REVISAR: Por qué REAL exige dígitos antes y después del punto (no .5 ni 4.)
 *    y cómo ID_INVALIDO detecta 32 o más caracteres (1 letra/_ + >=31 más).
 * ============================================================================== */
DIG         [0-9]
LETRA       [A-Za-z_]
ID          {LETRA}({LETRA}|{DIG})*
ID_INVALIDO {LETRA}({LETRA}|{DIG}){31,}
REAL        {DIG}+"."{DIG}+([eE][+-]?{DIG}+)?|{DIG}+[eE][+-]?{DIG}+

%%

    /* =========================================================================
     * 👤 MELANY (espacios/comentarios válidos) & ARIEL (Error E3 en EOF)
     * ========================================================================= */
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

    /* =========================================================================
     * 👤 PARTE DE ARIEL (Estudiante 2): ERROR E5 (IDENTIFICADOR > 31 CARACTERES)
     * 📌 REVISAR: Va ANTES de {ID} por prioridad en caso de empate; se descarta
     *    y NO se inserta en la tabla de símbolos de Samuel.
     * ========================================================================= */
{ID_INVALIDO}           { emitir_error("E5", "identificador de más de 31 caracteres", linea, col); }

    /* =========================================================================
     * 👤 PARTE DE MELANY (Estudiante 1): TOKENS VÁLIDOS DE MINILANG
     * 📌 REVISAR: Orden de palabras reservadas ANTES de {ID} para que 'entero' o
     *    'si' no sean clasificados como IDENTIFICADOR.
     * ========================================================================= */
entero|real|cadena|logico|si|sino|mientras|para|funcion|retornar|imprimir|leer|verdadero|falso {
                          return emitir_token("PALABRA_RESERVADA", T_RESERVADA); }

{ID}                    {
                          /* Conexión con el módulo de Samuel (tabla.c) */
                          tabla_agregar(yytext, linea);
                          return emitir_token("IDENTIFICADOR", T_IDENTIFICADOR);
                        }

{REAL}                  { return emitir_token("REAL", T_REAL); }
{DIG}+                  { return emitir_token("ENTERO", T_ENTERO); }

    /* =========================================================================
     * 👤 PARTE DE ARIEL (Estudiante 2): ERROR E4 (NÚMERO MAL FORMADO)
     * 📌 REVISAR: Va DESPUÉS de {REAL} y {DIG}+. Por máximo bocado (longest match),
     *    '10' coincide con {DIG}+, pero '2dias' o '1.2.3' coinciden aquí por ser más largos.
     * ========================================================================= */
({REAL}|{DIG}+)[A-Za-z0-9_.]+ { error_numero(); }

    /* =========================================================================
     * 👤 PARTE DE MELANY (Cadenas válidas) Y ARIEL (Errores E6 y E2)
     * 📌 REVISAR: La cadena cerrada pasa por verificar_escapes_cadena() (E6);
     *    si no tiene escapes inválidos, Melany emite CADENA. Si falta comilla
     *    de cierre antes del salto de línea, entra a E2.
     * ========================================================================= */
\"(\\[^\n]|[^"\\\n])*\" {
                          if (!verificar_escapes_cadena()) {
                              return emitir_token("CADENA", T_CADENA);
                          }
                        }

\"(\\[^\n]|[^"\\\n])*\\?   { emitir_error("E2", "cadena sin cerrar", linea, col); }

    /* Operadores y delimitadores (Melany) */
"=="|"!="|"<="|">="|"<"|">"  { return emitir_token("OP_RELACIONAL", T_OP_RELACIONAL); }
"&&"|"||"|"!"                { return emitir_token("OP_LOGICO", T_OP_LOGICO); }
"="                          { return emitir_token("ASIGNACION", T_ASIGNACION); }
[-+*/%]                      { return emitir_token("OP_ARITMETICO", T_OP_ARITMETICO); }
[(){}\[\];,]               { return emitir_token("DELIMITADOR", T_DELIMITADOR); }

    /* Error E1 (Ariel): Regla comodín al final para cualquier carácter no válido */
.                       { error_caracter(); }

    /* Fin de archivo (Melany / Eduardo) */
<<EOF>>                 { printf("%d:%d\tFIN\t\n", sig_linea, sig_col); return T_FIN; }

%%

/* ==============================================================================
 * 👤 PARTE DE EDUARDO (Estudiante 4): DRIVER / FUNCIÓN MAIN PRINCIPAL
 * 📌 REVISAR: Abre el archivo recibido por argv[1], ejecuta el bucle yylex()
 *    hasta recibir T_FIN (0), imprime la tabla de símbolos de Samuel, muestra el
 *    resumen de tokens/errores y libera memoria.
 * ============================================================================== */
int main(int argc, char *argv[]) {
    if (argc > 1 && !(yyin = fopen(argv[1], "r"))) {
        perror(argv[1]);
        return 1;
    }

    int tok;
    while ((tok = yylex()) != T_FIN) {
        /* En Semana 12 Bison llamará a yylex() y usará 'tok' */
    }

    tabla_imprimir();
    printf("\ntokens: %d  errores: %d\n", ntokens, nerrores);
    tabla_liberar();

    return 0;
}
