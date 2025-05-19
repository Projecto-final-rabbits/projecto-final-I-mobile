# Informe de Rendimiento – **CPP v1**

> Fecha de elaboración: 2025-05-18

## 1. Contexto y entorno de pruebas
| Variable | Valor |
|----------|-------|
| **Dispositivo** | Google Pixel 8 |
| **OS / API** | Android 14 (API 35) |
| **Modo build** | **Profile** |
| **Motor Flutter** | 3.29.2 |
| **Back‑end gráfico** | Impeller |
| **Herramientas** | Flutter DevTools 2.42.3   (CPU Profiler, Performance, Memory) |

---

## 2. Desempeño de frames (FPS & Jank)

Se capturó la pestaña **Performance → Frame Analysis** durante un recorrido típico de la app.

* **Promedio general:** ~60 FPS (todas las barras **azules** por debajo de 16 ms).  
* **Picos de navegación:** entre los frames **849 ➜ 869** aparecen barras **rojas** (_jank frames_) con tiempos de **19–22 ms**.  
  * Durante estos picos el hilo raster no alcanzó a completar el dibujo en un solo ciclo de refresco (16,6 ms), generando un ligero tartamudeo perceptible al pasar de pantalla.

> ![Frame chart sin jank](Screenshot_2025-05-18_at_14.10.52.png)  
> _Tramo estable – ≤ 3 ms por frame_

> ![Frame chart con jank](Screenshot_2025-05-18_at_14.11.07.png)  
> _Tramo con jank en transiciones_

**Hipótesis de causa**

1. **Animaciones de Navigator/Routes** que crean/transicionan múltiples capas.
2. **Shader compilations** iniciales al mostrarse nuevos widgets (first‑frame jank).
3. Sobrecarga momentánea en el **heap/Dart GC** al construir la siguiente pantalla.

---

## 3. Perfil de CPU

El muestreo de **41 s** (CPU sampling, 250 µs) entrega los siguientes *hotspots*:

| Rank | Función (exclusivo) | Tiempo aprox. | Nota |
|------|---------------------|--------------|------|
| 1 | `LinkedHashMapMixin._rehash` | **34 ms** | Rehash de `Map` durante `build()` |
| 2 | `Developer._postEvent` / `Timeline._reportTaskEvent` | 49 ms | Instrumentación DevTools |
| 3 | `FlutterView.__render` | 18 ms | Composición/raster |
| 4 | `PlatformDispatcher._scheduleFrame` | 15 ms | Programación de cuadros |
| 5 | `_NativeScene._dispose` | 9 ms | Descarte de capas |

*El cuello de botella principal está en la capa **UI/raster**; la lógica propia (<1 % de muestras) no es crítica.*

---

## 4. Uso de memoria

Snapshot generado desde **Memory → Export CSV**.

| Métrica | Valor |
|---------|-------|
| **Total Heap capturado** | **≈ 9 kB** (`Total Size` = 9 168 bytes) |
| **Total External** | 0 bytes |
| **Clases con mayor huella** | `OrderModel` (1 728 B), `OrderListItem` (288 B), varios elementos de `provider` |

> **Nota:** la captura refleja objetos **vivos** en el instante del snapshot; no incluye texturas ni buffers del GPU. Durante navegación la huella sube ~2–3 MB por _routes_ temporales y vuelve a bajar tras GC.

---

## 5. Conclusiones y acciones recomendadas

| Área | Prioridad | Acción |
|------|-----------|--------|
| **Transiciones de pantalla** | Alta | • Activa `MaterialApp.router` con `transitionBuilder` personalizado (`FadeUpwardsPageTransitionsBuilder`) para reducir capas.<br>• Precarga shaders: `--bundle-sksl-path` + `--cache-sksl` en _release_. |
| **Rebuilds innecesarios** | Media | Añade `const` a widgets estáticos y usa `Selector`/`Consumer` de **provider** para aislar cambios. |
| **Estructuras de datos mutables** | Media | Sustituir `Map` instanciados en `build()` por listas inmutables o caching (`memoize`). |
| **Profiling en release** | Alta | Repetir mediciones con `flutter build apk --release` + **Perfetto** para descartar ruido DevTools. |
| **Monitoreo de memoria** | Baja | Habilitar `debugPrintMemoryInfo()` y observar crecimiento > 50 MB en sesiones prolongadas. |

