# Proyecto del I Bimestre · Analizador Léxico de MiniLang (Grupo 4)

**Materia:** Compiladores y Lenguajes (ICCD422) — GR2CC_2026-2  
**Institución:** Escuela Politécnica Nacional (EPN)  
**Profesor:** Ing. Henry Recalde, MSc.  

---

## 📌 Guía Rápida de Trabajo por Estudiante

Para que no existan conflictos ni confusiones, cada integrante trabaja en sus archivos correspondientes:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        ESTRUCTURA DE ARCHIVOS                          │
├───────────────────┬──────────────────────────────┬─────────────────────┤
│ Integrante        │ Archivos a su cargo          │ Qué debe hacer      │
├───────────────────┼──────────────────────────────┼─────────────────────┤
│ 🧑‍💻 Estudiante 1   │ tokens.h                     │ Definir códigos de  │
│                   │ minilang.l (sección tokens)  │ tokens y retornos   │
├───────────────────┼──────────────────────────────┼─────────────────────┤
│ 🧑‍💻 Estudiante 2   │ minilang.l (sección errores) │ Implementar errores │
│                   │                              │ E1 a E6 (modo pánico│
├───────────────────┼──────────────────────────────┼─────────────────────┤
│ 🧑‍💻 Estudiante 3   │ tabla.h                      │ Programar la tabla  │
│                   │ tabla.c                      │ de símbolos en C    │
├───────────────────┼──────────────────────────────┼─────────────────────┤
│ 🧑‍💻 Estudiante 4   │ Makefile                     │ Crear los 4 tests   │
│                   │ pruebas/*.ml                 │ y verificar que     │
│                   │ esperadas/*.txt              │ make pruebas pase   │
└───────────────────┴──────────────────────────────┴─────────────────────┘
```

---

## 👥 Tabla Oficial de Integrantes y Responsabilidades

| Integrante | Rol Técnico | Responsabilidad Principal |
| :--- | :--- | :--- |
| **[Nombre 1]** | Léxico Core & Tokens | Definición de expresiones regulares de tokens válidos (`PALABRA_RESERVADA`, `IDENTIFICADOR`, `ENTERO`, `REAL`, `CADENA`, etc.), interfaz con `tokens.h` y control de línea/columna. |
| **[Nombre 2]** | Errores Léxicos & Modo Pánico | Detección y recuperación en modo pánico de errores E1 a E6 (especialmente E5 para identificadores > 31 caracteres y E6 para secuencias de escape no válidas en cadenas). |
| **[Nombre 3]** | Tabla de Símbolos en C | Implementación en `tabla.c` y `tabla.h`, almacenamiento con `strdup()`, lista ordenada de líneas de aparición sin duplicados y reporte al final. |
| **[Nombre 4]** | Automatización, QA & Pruebas | Configuración de `Makefile`, suite de 4 programas en `pruebas/`, salidas de referencia en `esperadas/` y ejecución de `make pruebas` con 0 diferencias. |

---

## 🚀 Comandos Rápidos para la Terminal

```bash
# 1. Compilar el analizador léxico (genera el ejecutable ./minilang)
make

# 2. Ejecutar un archivo individual de prueba
./minilang pruebas/p1_correcto.ml

# 3. Ejecutar toda la batería de pruebas y verificar contra esperadas/
make pruebas

# 4. Limpiar ejecutables y archivos generados
make limpiar
```

---

## 🧪 Batería de Pruebas Obligatoria

* `pruebas/p1_correcto.ml` $\rightarrow$ Cobertura de tokens válidos y tabla de símbolos sin errores.
* `pruebas/p2_errores_e1_e3.ml` $\rightarrow$ Cobertura de caracteres no válidos (E1), cadena sin cerrar (E2) y comentario de bloque sin cerrar (E3).
* `pruebas/p3_errores_e4_e6.ml` $\rightarrow$ Cobertura de número mal formado (E4), identificador > 31 caracteres (E5) y escape inválido en cadena (E6).
* `pruebas/p4_casos_limite.ml` $\rightarrow$ Casos borde (identificador de exactamente 31 chars vs 32, escapes válidos múltiples, comentarios dentro de cadenas, números con notación científica).
