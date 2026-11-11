/* tokens.h — Códigos de token de MiniLang (para interfaz y conexión con Bison)
 *
 * RESPONSABLE: Estudiante 1 (Tokens Base y Códigos)
 */
#ifndef TOKENS_H
#define TOKENS_H

enum token {
    T_FIN = 0,
    T_RESERVADA = 258,
    T_IDENTIFICADOR,
    T_ENTERO,
    T_REAL,
    T_CADENA,
    T_OP_RELACIONAL,
    T_OP_LOGICO,
    T_ASIGNACION,
    T_OP_ARITMETICO,
    T_DELIMITADOR
};

#endif
