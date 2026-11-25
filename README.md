# Analizador Léxico de MiniLang (Flex y C)

**Escuela Politécnica Nacional (EPN)**  
**Asignatura:** Compiladores y Lenguajes (ICCD422) — GR2CC (2026-2)  
**Docente:** Ing. Henry Recalde, MSc.  
**Grupo 4:**
* Danny Anasi
* Melany Taco
* Ariel Soria
* Samuel Robayo

---

## Descripción del Proyecto

Implementación de un analizador léxico autónomo para el lenguaje **MiniLang**, desarrollado en **Flex** y **C**. El escáner lee código fuente, descarta espacios y comentarios, agrupa lexemas en 10 clases de tokens compatibles con Bison (`258`–`267` y `0` para `EOF`), registra identificadores únicos con sus líneas de aparición en una tabla de símbolos dinámica y realiza recuperación de errores léxicos en **modo pánico** (`E1` a `E6`).

---

## Estructura del Repositorio

```text
Grupo4_Proyecto_MiniLang/
├── minilang.l          # Especificación léxica en Flex (reglas, errores, posición y main)
├── tokens.h            # Definición del enum de códigos de token (compatible con Bison)
├── tabla.h             # Interfaz pública de la tabla de símbolos
├── tabla.c             # Implementación de la tabla de símbolos (lista enlazada O(1))
├── Makefile            # Automatización de compilación, pruebas con diff y limpieza
├── pruebas/            # Programas fuente MiniLang (.ml) para validación
│   ├── p1_correcto.ml
│   ├── p2_errores_e1_e3.ml
│   ├── p3_errores_e4_e6.ml
│   └── p4_casos_limite.ml
└── esperadas/          # Salidas de referencia (.txt) para comparación automática
