/* ==============================================================================
 * 👤 ESTUDIANTE 1 (Melany): MÓDULO DE TOKENS Y CÓDIGOS DE INTERFAZ
 * ==============================================================================
 * 🎯 RESPONSABILIDAD:
 *    Define las constantes numéricas únicas para cada clase léxica de MiniLang.
 *    Estos mismos códigos serán utilizados por Bison para el análisis sintáctico.
 *
 * 📋 CÓDIGOS DE TOKEN OBLIGATORIOS:
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
