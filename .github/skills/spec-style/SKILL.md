# SKILL — spec-style (Markdown robusto y consistente)

## Propósito

Asegurar que todos los documentos Markdown en `docs/spec/**` rendericen de forma
robusta y consistente (GitHub / VS Code / MkDocs), evitando roturas por
encabezados sin separación, listas pegadas, fences mal indentados, tablas mal
formadas o espacios en blanco excesivos.

## Alcance

- Aplica a **cualquier edición** de Markdown dentro de `docs/spec/**`.
- Se usa como criterio de aceptación de calidad para Writer y Reviewer.
- Si una corrección de formato implica reestructurar grandes bloques, prioriza
  cambios mínimos y seguros. Si el arreglo no es trivial sin riesgo, deja un
  `TODO:` local y crea `TODO-###` en `docs/spec/96-todos.md`.

## Reglas duras (SIEMPRE)

### 1) Línea en blanco tras encabezados (H1–H4)

**Siempre** debe haber **exactamente 1 línea en blanco** después de cualquier
encabezado `#`, `##`, `###`, `####`.

✅ Correcto:

```md
### Título

Texto...
````

❌ Incorrecto:

```md
### Título
Texto...
```

---

### 2) Listas: línea en blanco antes y después

**Siempre** debe haber **1 línea en blanco antes y 1 después** de cualquier
lista (`-`, `*`, `1.`), incluyendo listas dentro de secciones.

✅ Correcto:

```md
Texto previo.

- Item A
- Item B

Texto posterior.
```

❌ Incorrecto (sin línea en blanco antes):

```md
Texto previo.
- Item A
- Item B
```

❌ Incorrecto (sin línea en blanco después):

```md
- Item A
- Item B
Texto posterior.
```

#### Sublistas: indentación de 4 espacios por nivel

Cada nivel de sublista añade **4 espacios**.

✅ Correcto:

```md
- Item
    - Subitem
        - Subsubitem
```

❌ Incorrecto:

```md
- Item
  - Subitem
    - Subsubitem
```

---

### 3) Bloques de código (fences) siempre bien formados e indentados

Reglas:

- Los bloques de código usan siempre triple backtick: ```.
- Si el bloque está **dentro de una lista**, debe ir **indentado con 4 espacios**
  por nivel de lista.
- Debe existir **1 línea en blanco antes y 1 después** del bloque.

✅ Bloque fuera de lista:

````md
Texto previo.

```json
{ "a": 1 }
```

Texto posterior.

````

✅ Bloque dentro de lista (1 nivel):

````md
- Ejemplo:

    ```json
    { "a": 1 }
    ```
````

✅ Bloque dentro de sublista (2 niveles):

````md
- Item:
    - Ejemplo:

        ```json
        { "a": 1 }
        ```
````

❌ Incorrecto (sin indentación dentro de lista):

````md
- Ejemplo:
```json
{ "a": 1 }
```

````

---

### 4) No puede haber dos líneas en blanco seguidas (en ningún sitio)

Regla global:

- Nunca debe existir un bloque con **dos líneas en blanco seguidas**.
- En términos de saltos de línea, evita `\n\n\n` en cualquier parte del archivo.
- Entre bloques (párrafo/lista/tabla/fence/encabezado) usa **exactamente 1**
  línea en blanco.

✅ Correcto: 1 línea en blanco entre bloques.

❌ Incorrecto: 2 o más líneas en blanco seguidas.

---

### 5) Tablas: fila separadora con espacios y guiones correctos

Reglas:

- La fila separadora debe tener **espacios** alrededor de los guiones y las
  barras verticales.
- Formato obligatorio: `| --- | --- |` (tantas columnas como cabecera).
- No usar nunca `|---|---|` (sin espacios).

✅ Correcto:

```md
| Col A | Col B |
| --- | --- |
| A1 | B1 |
````

❌ Incorrecto:

```md
| Col A | Col B |
|---|---|
| A1 | B1 |
```

---

## Reglas de ubicación y consistencia

### Ubicación de `### Fuentes`

- Añade `### Fuentes` **al final del bloque/sección** donde se use la
  información verificada.
- Si la verificación afecta a varias secciones o a todo el documento, coloca
  `### Fuentes` **al final del documento**.
- En `### Fuentes`, cada entrada debe tener: **URL + fecha (YYYY-MM-DD) + 1
  línea** de qué se extrajo.

Ejemplo:

```md
### Fuentes
- https://example.com — consultado 2026-01-22 — describe límites de la API y auth.
```

---

## Higiene de archivo

### Final de archivo (EOF)

- El archivo debe terminar con **un único salto de línea**.
- No dejar líneas en blanco extra al final.
- **Nunca** dejar 2 líneas en blanco seguidas al final del archivo.

---

## Checklist de validación (antes de dar por bueno un doc)

1. ¿Cada `#..####` tiene una línea en blanco después?
2. ¿Cada lista tiene línea en blanco antes y después?
3. ¿Todos los fences dentro de listas están indentados (4 espacios por nivel)?
4. ¿No hay ningún tramo con 2 líneas en blanco seguidas?
5. ¿Todas las tablas usan `| --- |` con espacios y la fila separadora coincide
   en nº de columnas?
6. ¿El archivo termina con un único salto de línea (sin líneas en blanco extra)?

---

## Autofix mental rápido (patrones típicos)

- Si ves `### Título` y la siguiente línea empieza con texto → inserta una línea
  en blanco.
- Si ves texto seguido inmediatamente de `- item` → inserta una línea en blanco
  antes.
- Si ves una lista seguida inmediatamente de texto → inserta una línea en blanco
  después.
- Si ves un bloque ``` dentro de `- ...` sin indentación → indenta 4 espacios
  (por nivel de lista).
- Si ves dos líneas en blanco seguidas → reduce a una.
- Si ves `|---|---|` → reemplaza por `| --- | --- |`.

---

## Nota operativa

Si no puedes aplicar una corrección sin riesgo (p. ej. tabla muy grande o
bloques complejos), deja un `TODO:` local y crea `TODO-###` en
`docs/spec/96-todos.md`, pero **no** aceptes un render roto si es fácil de
corregir.
