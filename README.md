# 🥾 Control de Corte de Botas

Aplicación desarrollada en **Flutter** para **Android** y **Web** para el control y seguimiento del corte de componentes de botas en taller de calzado.

---

## 📋 Características Principales

1. **Gestión de Modelos**:
   - Registro de código o nombre del modelo (ej: *Bota Vaquera 501*, *Cuadra Caiman*).
   - Selección rápida de género: **Hombre** o **Mujer**.
   - Guardado automático en la memoria del dispositivo (funciona 100% offline).

2. **Selección Inteligente de Puntos (Tallas)**:
   - **Mujer**: Puntos del **2 al 7 con medios puntos** (2, 2 ½, 3, 3 ½, 4, 4 ½, 5, 5 ½, 6, 6 ½, 7).
   - **Hombre**: Puntos del **5 al 30 con medios puntos** (5.0 a 30.0), con accesos rápidos a puntos comerciales (25 al 30).
   - Sin escritura manual: toca los chips de los puntos y asigna la cantidad de pares por punto o aplica una cantidad general a todos.

3. **Tablero de Corte (11 Componentes)**:
   - **Chinela y talón**
   - **Tubos**
   - **Forro**
   - **Ormas**
   - **Cartón**
   - **Planta**
   - **Contra fuerte**
   - **Rif**
   - **Suela**
   - **Tacón**
   - **Espinazo**

4. **Sistema de Marcado Rápido**:
   - **✓ Paloma (Completado)**: Indica que todos los pares de esa talla y componente están listos.
   - **— Raya (Medio Completo / Parcial)**: Permite ingresar con exactitud cuántos pares se llevan cortados (ej: 4 de 10).
   - **Modo Rápido**: Un toque marca paloma directa (✓) o desmarca. Mantener presionado abre el control de cantidad parcial.
   - Acciones en lote: Marcar toda una fila completa o toda una columna completa con un solo toque.

5. **Barra de Progreso y Borrado**:
   - Barra de avance general en porcentaje (%) y conteo exacto de piezas listas vs faltantes.
   - Al llegar al **100%**, se activa la celebración y el botón para **Borrar el modelo completado** de la memoria para liberar espacio.

---

## 📱 Archivo APK para Android
El archivo compilado listo para instalar en cualquier teléfono o tablet Android se encuentra en:
- `Control_Botas.apk` (en la raíz del proyecto)
- `build/app/outputs/flutter-apk/app-release.apk`

---

## 🌐 Despliegue en GitHub Pages
La aplicación web está compilada dentro de la carpeta `docs/` y cuenta con un flujo de GitHub Actions configurado en `.github/workflows/deploy.yml`.

### Para activar en tu repositorio de GitHub:
1. Sube este repositorio a tu cuenta de GitHub:
   ```bash
   git remote add origin https://github.com/TU_USUARIO/TU_REPOSITORIO.git
   git push -u origin main
   ```
2. En GitHub entra a **Settings** -> **Pages**.
3. En **Build and deployment** > **Source**:
   - Elige **GitHub Actions** (se desplegará automáticamente), o
   - Elige **Deploy from a branch** -> Selecciona rama `main` y carpeta `/docs`.
