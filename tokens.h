/* ==============================================================================
 * 👤 ESTUDIANTE 1: MÓDULO DE TOKENS Y CÓDIGOS DE INTERFAZ
 * ==============================================================================
 * 💡 ANALOGÍA CON JAVA:
 *    Este archivo es el equivalente exacto a un 'public enum Token' en Java.
 *    Define las constantes numéricas únicas para cada categoría léxica del lenguaje.
 *
 * 🎯 TU MISIÓN:
 *    1. Garantizar que cada token tenga su código numérico asignado (a partir de 258).
 *    2. En 'minilang.l', en cada una de tus reglas de tokens válidos, debes hacer:
 *          return emitir_token("CLASE_TOKEN", CODIGO_DE_AQUI);
 *
 * 📋 CÓDIGOS DE TOKEN OBLIGATORIOS:
 * ============================================================================== */
#ifndef TOKENS_H
#define TOKENS_H

enum token {
    T_FIN            = 0,     /* Fin de archivo (EOF) */
    T_RESERVADA      = 258,   /* Palabras reservadas (entero, si, etc.) */
    T_IDENTIFICADOR  = 259,   /* Identificadores válidos (<= 31 chars) */
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
