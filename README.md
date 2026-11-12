# Proyecto del I Bimestre · Analizador Léxico de MiniLang en Flex y C

**Materia:** Compiladores y Lenguajes (ICCD422) — GR2CC_2026-2  
**Institución:** Escuela Politécnica Nacional (EPN)  
**Grupo:** Grupo 4  

---

## 👥 Integrantes y Responsabilidades

| Integrante | Rol | Responsabilidad Principal |
| :--- | :--- | :--- |
| **Melany [Completar apellidos]** | Léxico Core & Tokens | Expresiones regulares de tokens válidos, tipos numéricos (`ENTERO`, `REAL`), palabras reservadas, operadores, delimitadores, interfaz con `tokens.h` y control de línea/columna. |
| **Ariel [Completar apellidos]** | Errores Léxicos & Modo Pánico | Detección y recuperación en modo pánico de errores E1 a E6 (especialmente E5 > 31 chars y E6 escapes inválidos en cadenas con posición del `\`). |
| **Samuel [Completar apellidos]** | Tabla de Símbolos en C | Implementación en `tabla.c` y `tabla.h`, registro dinámico con `strdup()`, lista ordenada de líneas de aparición sin duplicados y formateo estricto. |
| **Anasi Nacimba Danny Eduardo** | Automatización, QA & Pruebas | Configuración de `Makefile`, suite de 4 programas en `pruebas/`, salidas de referencia en `esperadas/`, función `main()`, verificación con `diff` y documentación. |

---

## 🚀 Cómo compilar y ejecutar

### Requisitos previos
* `gcc` (compilador de C)
* `flex` (generador de analizadores léxicos)
* `make` (herramienta de automatización)

### Comandos de compilación
```bash
# Compilar el ejecutable minilang
make

# Ejecutar un programa de prueba individual
./minilang pruebas/p1_correcto.ml

# Ejecutar toda la batería de pruebas automatizada
make pruebas

# Limpiar archivos temporales y ejecutables generados
make limpiar
```

---

## 🧪 Batería de Pruebas

| Archivo de Prueba | Categoría | Descripción y Casos Cubiertos |
| :--- | :--- | :--- |
| `pruebas/p1_correcto.ml` | Programa Válido | Cobertura total de palabras reservadas, operadores, enteros, reales, comentarios y tabla de símbolos sin errores. |
| `pruebas/p2_errores_e1_e3.ml` | Errores Sintácticos Tempranos | Cobertura de caracteres inválidos (E1), cadenas sin cerrar en fin de línea (E2) y bloque `/* ... */` sin cerrar al EOF (E3). |
| `pruebas/p3_errores_e4_e6.ml` | Errores Complejos | Cobertura de números mal formados (E4), identificadores > 31 caracteres (E5) y secuencias de escape inválidas (E6). |
| `pruebas/p4_casos_limite.ml` | Casos Borde | Identificador de exactamente 31 caracteres vs 32, escapes válidos múltiples (`\n`, `\t`, `\"`, `\\`), comentarios dentro de cadenas, reales con exponente. |

---

## 🛠️ Decisiones de Diseño Técnico

1. **Orden de Reglas en Flex:**
   * Las reglas de error de mayor longitud (como `ID_INVALIDO` de más de 31 caracteres) preceden a la regla general `{ID}` para que Flex aplique la precedencia de regla superior ante igual longitud.
   * Las palabras reservadas preceden a `{ID}` para evitar que sean absorbidas como identificadores.
2. **Estrategia del Modo Pánico:**
   * Ningún error detiene el análisis (`exit`), permitiendo diagnosticar la totalidad de incidencias del código fuente de una sola pasada.
3. **Gestión de Memoria en la Tabla de Símbolos:**
   * Se utiliza `strdup()` para asegurar que cada identificador conserve su cadena propia antes de que el buffer `yytext` de Flex sea reutilizado por el siguiente lexema.

---

## 🔍 Guía de Revisión por Integrante (Defensa Semana 8)

Cada archivo fuente tiene marcada con el nombre correspondiente la sección exacta que debe dominar y defender cada integrante:

* **Melany (`tokens.h` y `minilang.l` — Tokens Válidos):**
  * Revisar las definiciones regulares (`DIG`, `LETRA`, `ID`, `REAL`), el macro `YY_USER_ACTION` para `linea`/`col`, la función `emitir_token()` y el orden de palabras reservadas antes de `{ID}`.
* **Ariel (`minilang.l` — Errores E1 a E6 y Modo Pánico):**
  * Revisar la condición de inicio `%x COMENT` (E3), `{ID_INVALIDO}` antes de `{ID}` (E5), la regla de número mal formado (E4), `verificar_escapes_cadena()` con `col + i` (E6), cadena sin cerrar (E2) y `error_caracter()` (E1).
* **Samuel (`tabla.h` y `tabla.c` — Tabla de Símbolos):**
  * Revisar la estructura `struct Simbolo`, la lista enlazada con `cabeza`/`cola` (orden cronológico), la copia con `strdup()`, la inserción sin líneas repetidas (`realloc`) y `tabla_liberar()`.
* **Eduardo (`Makefile`, `minilang.l` `main()`, `pruebas/` y `esperadas/`):**
  * Revisar el bucle `while ((tok = yylex()) != T_FIN)` en `main()`, las reglas de compilación del `Makefile`, los 4 programas en `pruebas/` y la verificación automatizada con `make pruebas`.
