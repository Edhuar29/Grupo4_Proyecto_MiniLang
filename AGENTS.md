# Reglas de Desarrollo - Proyecto MiniLang Grupo 4

## ⚠️ Restricción Estricta de Lenguaje y Herramientas

- **Lenguajes Exclusivos del Proyecto:**
  - Todo el código fuente del proyecto debe desarrollarse **ÚNICA Y EXCLUSIVAMENTE en Flex y Lenguaje C**.
  - El escáner léxico debe estar en `minilang.l` (Flex).
  - Las estructuras de datos y la tabla de símbolos deben estar en `tabla.c` y `tabla.h` (Lenguaje C).
  - Los códigos de tokens deben estar en `tokens.h` (Lenguaje C).
  - La automatización de compilación y pruebas debe ser mediante `gcc` y `Makefile`.

- **Prohibiciones Absolutas:**
  - **PROHIBIDO** utilizar cualquier otro lenguaje (como Python, Java, C++, Rust, Go, etc.) para la implementación del analizador léxico.
  - El docente evaluará de forma automatizada mediante:
    `flex minilang.l && gcc lex.yy.c tabla.c` y `make pruebas`.
    Cualquier intento de usar otro lenguaje causará una calificación automática de **0 puntos**.

- **Lenguaje Objetivo a Analizar:**
  - El analizador procesa código fuente escrito en el lenguaje **MiniLang** (archivos de entrada con extensión `.ml`).
