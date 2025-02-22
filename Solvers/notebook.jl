### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 931f7d35-deff-4ac6-a0c7-927673c252fd
md"""
# Análisis de Solvers de EDO en Diferentes Herramientas
- Esneider Fabian Sierra Alba
- Juan José Martínez Castiblanco
- Juan Carlos Sánchez Orjuela
"""

# ╔═╡ 8a6beff8-5b76-4918-bb4a-5e891713d4c6
md"""
## Selección de Herramientas
### Solver 1: Python SciPy
SciPy es una librería gratis y de codigo abierto(Open Source) de Python para computación científica que incluye el módulo integrate, el cual contiene funciones para resolver EDOs. Esta libreria fue lanzada desarrollada inicialmente en 2001 por Travis Oliphant, Pearu Peterson y Eric Jones.

**Documentación:** [SciPy Integrate](https://docs.scipy.org/doc/scipy/reference/integrate.html#solving-initial-value-problems-for-ode-systems)

**Repositorio:** [SciPy GitHub](https://github.com/scipy/scipy)

**Fun fact:** [Primer commit](https://github.com/scipy/scipy/commit/02de46a5464f182d3d64be5a7ee1087ae8be8646)

"""

# ╔═╡ fcb7a6ce-41a3-42ff-9838-494424f5031f
md"""
## Análisis del Solver
### Solver 1: Python SciPy
El análisis del código se hizo usando la versión [1.15.2](https://github.com/scipy/scipy/releases/tag/v1.15.2).

SciPy cuenta con los siguientes métodos para resolver problemas de valor inicial en EDO:
- `solve_ivp`
- `RK23`
- `RK45`
- `DOP853`
- `Radau`
- `BDF`
- `LSODA`
- `OdeSolver`
- `DenseOutput`
- `OdeSolution`

En este caso analizaremos `solve_ivp`.

### `solve_ivp`
Este método puede resolver un problema de EDO con valor inicial utilizando cualquiera de los métodos descritos anteriormente. Por defecto, éste usa `RK45` explícito, es decir, el método de Runge–Kutta **explícito** de orden 5. El 4 en el nombre se debe a que se utiliza un método de Runge–Kutta de orden 4 para comparar la precisión, es decir, los errores se estiman comparando las soluciones de orden 4 y 5.

Esta función recibe los siguientes parámetros:
- **fun:** La función que define la EDO en la forma $\frac{dy}{dt}=f(t,y)$. Esta función debe poder llamarse como `fun(t, y)`, donde $y$ debe tener la misma longitud que $y_0$.
- **t_span:** Intervalo de evaluación $(t_0, t_f)$.
- **y0:** Valor inicial en forma de arreglo.
- **dense_output** (opcional, `False`): Booleano para especificar si se desea calcular una solución continua.
- **events** (opcional, *callables*): Lista de funciones (*callables*) que se ejecutarán cada vez que se encuentre un cero en la función.
- **args** (opcional, tupla): Argumentos adicionales que se pasarán a la función. Una función que necesite argumentos se envolverá en un *wrapper* para ser llamada por el solver de la siguiente manera:
  ```python
  # scipy/integrate/_ivp/ivp.py
  def fun(t, x, fun=fun):
      return fun(t, x, *args)
  ```
- **options** (opcional): Opciones que se pasarán al solver, como se ve a continuación:
  ```python
  # scipy/integrate/_ivp/ivp.py
  solver = method(fun, t0, y0, tf, vectorized=vectorized, **options)
  ```

Algunas opciones relevantes son:

- **first_step** (opcional, flotante): Tamaño del paso inicial. Si no se proporciona, el algoritmo elegirá uno.
- **max_step** (opcional, flotante): Tamaño máximo del paso. Si no se proporciona, el algoritmo elegirá uno.
- **atol, rtol** (opcional, flotante o `array_like`): Tolerancia absoluta y relativa, respectivamente. El solver garantiza que el error en cada paso satisface  
  $\text{error} \leq atol + rtol\,|y|$

Este solver funciona de la siguiente manera:

Una vez llamada la función, se procede a verificar que el método asignado esté implementado y sea del tipo `OdeSolver` (el solver soporta métodos personalizados). Luego, se comprueba que los puntos de los intervalos sean válidos para, posteriormente, instanciar una clase del solver, como se muestra a continuación:
```python
# scipy/integrate/_ivp/ivp.py
solver = method(fun, t0, y0, tf, vectorized=vectorized, **options)
```
En el caso por defecto, se instancia la clase `RK45`, que hereda de la clase `RungeKutta`. En esta inicialización se declaran las siguientes variables relevantes:
```python
# scipy/integrate/_ivp/rk.py
C = np.array([0, 1/5, 3/10, 4/5, 8/9, 1])
A = np.array([
    [0, 0, 0, 0, 0],
    [1/5, 0, 0, 0, 0],
    [3/40, 9/40, 0, 0, 0],
    [44/45, -56/15, 32/9, 0, 0],
    [19372/6561, -25360/2187, 64448/6561, -212/729, 0],
    [9017/3168, -355/33, 46732/5247, 49/176, -5103/18656]
])
B = np.array([35/384, 0, 500/1113, 125/192, -2187/6784, 11/84])
E = np.array([-71/57600, 0, 71/16695, -71/1920, 17253/339200, -22/525])
```
Donde $A$, $B$, $C$ y $E$ corresponden al [Butcher tableau](https://en.wikipedia.org/wiki/Runge%E2%80%93Kutta_methods#Explicit_Runge.E2%80%93Kutta_methods) expandido para calcular la solución de orden 4. Estos coeficientes se obtienen al resolver los pesos que se deben asignar a la solución de orden 5 para obtener la de orden 4; nótese que esto funciona debido a que existen muchos valores similares en el Butcher tableau para ambas soluciones. Este método también es conocido como [método Dormand–Prince](https://en.wikipedia.org/wiki/Dormand%E2%80%93Prince_method).

Con la clase instanciada se procede a evaluar cada paso del solver, como se ve a continuación:
```python
# scipy/integrate/_ivp/ivp.py
while status is None:
    message = solver.step()

    if solver.status == 'finished':
        status = 0
    elif solver.status == 'failed':
        status = -1
        break
```
Al llamar a `solver.step()` se invoca la implementación de Runge–Kutta `_step_impl()`, en la que se procede al cálculo del tamaño del paso:
```python
# scipy/integrate/_ivp/ivp.py

min_step = 10 * np.abs(np.nextafter(t, self.direction * np.inf) - t)

if self.h_abs > max_step:
    h_abs = max_step
elif self.h_abs < min_step:
    h_abs = min_step
else:
    h_abs = self.h_abs
```
Nótese que se utiliza `np.nextafter`; esto determina la tolerancia mínima del sistema, por lo que el tamaño del paso puede llegar hasta $eps \times 10$. Una vez definido el paso, se procede a evaluar la función para obtener $y_{n+1}$ y $f(t+h, y_{n+1})$:
```python
# scipy/integrate/_ivp/ivp.py
...
y_new, f_new = rk_step(self.fun, t, y, self.f, h, self.A,
                                   self.B, self.C, self.K)
...
self.t = t_new
self.y = y_new
...
def rk_step(fun, t, y, f, h, A, B, C, K):
    K[0] = f
    for s, (a, c) in enumerate(zip(A[1:], C[1:]), start=1):
        dy = np.dot(K[:s].T, a[:s]) * h
        K[s] = fun(t + c * h, y + dy)
    
    y_new = y + h * np.dot(K[:-1].T, B)
    f_new = fun(t + h, y_new)
    
    K[-1] = f_new
```
En este código se evalúan los coeficientes \(K\) y se calcula \(y_{n+1}\) (almacenado en `y_new`) según:
$k_s = f(t_n + c_s\,h,\; y_n + h\,\sum_{j=1}^{s-1} a_{sj}\,k_j)$
guardando los respectivos $k_s$ en una matriz. A continuación, se procede a calcular el error y, si éste ajustado a la escala basada en la tolerancia asignada resulta menor que 1, se acepta el paso; de lo contrario, se ajusta el paso hasta que el cálculo cumpla con el error requerido.
```python
# scipy/integrate/_ivp/ivp.py
scale = atol + np.maximum(np.abs(y), np.abs(y_new)) * rtol
error_norm = self._estimate_error_norm(self.K, h, scale)
```
Luego, se verifica que el paso se encuentre dentro de los límites de evaluación y, de no ser así, se termina la ejecución del algoritmo de Runge–Kutta:
```python
# scipy/integrate/_ivp/base.py
if not success:
    self.status = 'failed'
else:
    self.t_old = t
    if self.direction * (self.t - self.t_bound) >= 0:
        self.status = 'finished'
```
Si aún se está dentro del límite de evaluación, se procede a guardar los nuevos \(t\) e \(y\) calculados:
```python
# scipy/integrate/_ivp/ivp.py
...
t = solver.t
y = solver.y
...
ts.append(t)
ys.append(y)
...
```
Una vez terminada la ejecución de RK, se crea el objeto solución, que contiene principalmente un arreglo con los tiempos de ejecución del algoritmo y un arreglo con la función $y(t)$ evaluada en cada punto.

Un ejemplo sencillo es la ecuación de decaimiento exponencial 
$\frac{dy}{dt} = -0.5y,\quad y(0)=2$,
Usando la librería se obtiene:
```python
import numpy as np
from scipy.integrate import solve_ivp

def exponential_decay(t, y): 
    return -0.5 * y

sol = solve_ivp(exponential_decay, [0, 5], [2])

print(sol.t)
print(sol.y)

# Salida:
# [0.         0.11488132 1.26369452 3.06074656 4.81637262 5.        ]
# [[2.         1.88835583 1.0632438  0.43316531 0.18014905 0.16434549]]
```
Nótese que la solución exacta es $y(t)=2e^{-0.5t}$.
"""

# ╔═╡ c041d5b6-c998-4aab-92b5-1ea56843c542
md"""
Podemos considerar el ejemplo que usamos con solve_ivp: 
$\frac{dy}{dt} = -0.5y,\quad y(0)=2$.
Usando ode23 se obtiene:

```mathlab
>> %Solución numérica usando ode23s
tspan = 0:0.1:5;
opts = odeset('Stats','on');
y0 = 2;
[t,y] = ode23s(@(t,y) -0.5*y, tspan, y0);
 
%Solución numérica usando solve_ivp
a = [0.         0.11488132 1.26369452 3.06074656 4.81637262 5.        ];
b = [2.         1.88835583 1.0632438  0.43316531 0.18014905 0.16434549];

%Solución analítica
x = 0:0.1:5;
z = 2*exp(-0.5*x);

%Gráficas
tiledlayout(3,1)
nexttile
plot(t,y)
title('Matlab: ode23s')
nexttile
plot(a,b)
title('Python SciPy: solve-ivp')
nexttile
plot(t,y)
title('Solución Analítica')
```
Podemos visualizar las gráficas de cada uno de los solvers y compararlas con la solución analítica
![Gráficas](https://i.postimg.cc/NFLBydqQ/Captura.png)
$\scriptsize{\texttt{Figure 1. Matlab: ode23s VS Python SciPy: solve-ivp VS Solución Analítica.}}$
"""


# ╔═╡ Cell order:
# ╟─931f7d35-deff-4ac6-a0c7-927673c252fd
# ╟─8a6beff8-5b76-4918-bb4a-5e891713d4c6
# ╠═fcb7a6ce-41a3-42ff-9838-494424f5031f
