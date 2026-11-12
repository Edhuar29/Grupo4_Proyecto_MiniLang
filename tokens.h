/* ==============================================================================
 * 👤 PARTE DE MELANY (Estudiante 1): CÓDIGOS DE TOKEN E INTERFAZ PARA BISON
 * ==============================================================================
 * 📌 QUÉ DEBES REVISAR Y SABER EXPLICAR AQUÍ (Defensa Semana 8):
 *    1. Por qué los tokens comienzan en 258 (0 es EOF/T_FIN y 1..255 se reservan
 *       para caracteres ASCII individuales si Bison los usa).
 *    2. Cómo cada regla de 'minilang.l' retorna uno de estos códigos al bucle
 *       while(yylex() != T_FIN) en main(), preparando la conexión con Bison.
 * ============================================================================== */
#ifndef TOKENS_H
#define TOKENS_H

enum token {
    T_FIN            = 0,     /* Fin de archivo (EOF) */
    T_RESERVADA      = 258,   /* Palabras reservadas (entero, si, mientras, etc.) */
    T_IDENTIFICADOR  = 259,   /* Identificadores válidos (<= 31 caracteres) */
    T_ENTERO         = 260,   /* Números enteros (ej. 10, 42) */
    T_REAL           = 261,   /* Números reales (ej. 3.14, 2.5e-3, 1E3) */
    T_CADENA         = 262,   /* Cadenas de texto con escapes válidos */
    T_OP_RELACIONAL  = 263,   /* Operadores relacionales (==, !=, <=, >=, <, >) */
    T_OP_LOGICO      = 264,   /* Operadores lógicos (&&, ||, !) */
    T_ASIGNACION     = 265,   /* Operador de asignación (=) */
    T_OP_ARITMETICO  = 266,   /* Operadores aritméticos (+, -, *, /, %) */
    T_DELIMITADOR    = 267    /* Delimitadores ((, ), {, }, [, ], ;, ,) */
};

#endif
