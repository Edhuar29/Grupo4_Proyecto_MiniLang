# Makefile del proyecto de análisis léxico MiniLang - Grupo 4
#
# RESPONSABLE: Estudiante 4 (Automatización, QA y Suite de Pruebas)
#
# Comandos principales:
#   make           compila el analizador (./minilang)
#   make pruebas   analiza cada programa de pruebas/ y compara con esperadas/
#   make limpiar   borra los archivos generados

CC = gcc
CFLAGS = -Wall -Wextra

minilang: lex.yy.c tabla.c tabla.h tokens.h
	$(CC) $(CFLAGS) -o minilang lex.yy.c tabla.c

lex.yy.c: minilang.l
	flex minilang.l

pruebas: minilang
	@mkdir -p salidas
	@echo "=== EJECUTANDO SUITE DE PRUEBAS DEL GRUPO 4 ==="
	@for f in pruebas/*.ml; do \
		n=$$(basename $$f .ml); \
		echo "Probando $$f ..."; \
		./minilang $$f > salidas/$$n.txt; \
		diff -u salidas/$$n.txt esperadas/$$n.txt || { echo "ERROR: Diferencias encontradas en $$f"; exit 1; }; \
	done
	@echo "TODAS LAS PRUEBAS PASARON SATISFACTORIAMENTE (0 DIFERENCIAS)"

limpiar:
	rm -f minilang lex.yy.c
	rm -rf salidas

clean: limpiar
