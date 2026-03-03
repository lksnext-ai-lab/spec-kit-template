---
name: spec-kit-spec-style
description: "Reglas de estilo Markdown para docs/spec/** y docs/kit/**. Prioriza render robusto (GitHub/VS Code/MkDocs) con cambios mínimos y locales, evitando diffs ruidosos."
license: Proprietary
---

# SKILL — spec-style (Markdown robusto, mínimos cambios)

## Principio rector
**Fix local, no reformat global.**  
Solo corrige el fragmento que causa mala lectura/render o provoca errores típicos (listas pegadas, fences rotos, tablas inválidas). Evita “embellecer” documentos enteros.

## Alcance
- Aplica a ediciones Markdown en:
  - `docs/spec/**` (principal)
  - `docs/kit/**` (cuando se edita documentación del kit)

## No-objetivos
- No reescritura por estilo si el Markdown ya renderiza bien.
- No normalización masiva de espaciados, tablas o listas si no hay beneficio claro.

---

## Reglas duras (robustez)

### 1) Encabezados con separación mínima
- Debe haber **1 línea en blanco después** de cualquier encabezado `#..####`.
- Debe haber **1 línea en blanco antes** de un encabezado (salvo que sea la primera línea del archivo).

✅
```md
## Sección

Texto.
```

❌

```md
## Sección
Texto.
```

### 2) Listas separadas de párrafos

* Si una lista va después de un párrafo → **1 línea en blanco antes**.
* Si tras una lista viene un párrafo/encabezado → **1 línea en blanco después**.

✅

```md
Texto previo.

- A
- B

Texto posterior.
```

### 3) Fences correctos y estables

* Usar fences `…` para código.
* Debe haber **1 línea en blanco** antes y después del bloque (fuera de listas).
* Si el fence está **dentro de una lista**, indentar el fence y su contenido con **4 espacios por nivel** de lista.

✅ Dentro de lista:

````md
- Ejemplo:

    ```json
    { "a": 1 }
    ```
````

> Excepción: **no “normalizar” espacios dentro de fences**. El contenido del bloque se respeta.

### 4) Tablas válidas

* El número de columnas debe ser consistente en cabecera/separador/filas.
* Evitar pipes `|` sin escapar dentro de celdas.
* Evitar saltos de línea dentro de celdas.

> Nota: el separador puede ser `|---|---|` o `| --- | --- |` (ambos válidos). Preferencia se define en “Recomendadas”.

### 5) Sin tabs y sin trailing spaces

* No usar tabuladores.
* Evitar espacios al final de línea.

### 6) Evitar “líneas en blanco múltiples” cuando generen ruido

* Si hay **2+ líneas en blanco** fuera de fences y no aportan claridad → reducir a 1.
* Si separan secciones grandes de forma intencional, no tocar.

---

## Reglas recomendadas (consistencia, no “obligatorias”)

### R1) Marcadores de lista consistentes

* Preferir `-` para listas no ordenadas.
* En listas ordenadas, preferir `1.` en todos los ítems salvo que el número tenga significado.

### R2) Sublistas con 4 espacios por nivel

* Mantener indentación consistente.

### R3) Preferencia de separador de tablas

* Preferir `| --- | --- |` por legibilidad, pero **no reformat** si la tabla ya es válida.

### R4) No saltar niveles de encabezado

* Evitar `##` → `####` sin `###` intermedio, salvo documentos muy cortos.

---

## Higiene de archivo

* El archivo debe terminar con **un único salto de línea** (EOF newline).
* No dejar líneas en blanco extra al final.

---

## Checklist DoD (rápido)

1. Encabezados con línea en blanco antes/después.
2. Listas separadas de párrafos (antes/después).
3. Fences correctos e indentados dentro de listas.
4. Tablas con columnas coherentes.
5. Sin tabs ni trailing spaces.
6. Evitar múltiples líneas en blanco solo cuando crean diffs inútiles.
7. EOF newline único.

---

## Regla operativa

Si arreglar estilo implica un cambio grande (tablas enormes, reflujo de texto, reindentaciones masivas):

* aplica un fix mínimo local, y
* deja `TODO:` local y registra el pendiente en `docs/spec/96-todos.md`.
