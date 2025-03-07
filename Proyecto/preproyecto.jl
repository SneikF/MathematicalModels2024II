### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ 094f2d6e-4871-4189-8301-37cda62918aa
using PlutoUI

# ╔═╡ 4f45bb8c-49aa-4330-b4df-c3ab9f562cf5
PlutoUI.TableOfContents(title="Pre-Proyecto", aside=true)

# ╔═╡ 60412e5c-b686-11ef-156c-b1e1858bb3d1
md"""
# Osciladores acoplados y sincronización
## Descripción del problema 
Existe un fenómeno natural que tiene origen en grupos de poblaciones, puede observarse en el parpadeo de luciérnagas, el sonido de las cigarras, metrónomos acoplados e incluso en los aplausos en salas de teatro. Para ejemplificar el modelo consideremos un grupo de luciérnagas que emiten destellos de luz; las luciérnagas no empiezan a destellar de manera sincronizada, en principio incian cada una a su ritmo, el fenómeno que nos interesa es que al pasar el tiempo y unos cuantos destellos, el grupo de luciernagas comenzará a destellar como si fueran un solo individuo: los destellos comienzan a sincronizarse y las luciérnagas destellan y apagan todas a la vez.
"""

# ╔═╡ a659978a-ffd7-4b59-a256-36f97f5c6cf9
md"""
## Objetivo
Modelar y analizar la sincronización colectiva usando el modelo de Kuramoto, explorando cómo factores como el acoplamiento  y el número de individuos afectan la sincronización. También se buscará estimar tiempos de sincronización y validar el modelo con datos reales (o razonables) para comparar las simulaciones.
"""

# ╔═╡ 91d638e4-5e87-4180-b04c-38681e609198
md"""
## Metodología
### Planteamiento del modelo aislado
Utilizaremos un modelo de agentes, donde cada agente es un oscilador y es representado por el movimiento de un punto sobre el circulo unitario, alli una oscilacion se puede representar como el viaje que realiza el punto desde la posicion con angulo 0 hasta desplazarse $2\pi$ radianes en sentido opuesto a las manecillas del reloj, como se describe en la sección 4 de [1]. Cada punto en el circulo se puede describir por su angulo $theta$ que es denominado $\textit{fase}$.

![cir1](https://i.ibb.co/HTYRZjs/cir1.png)

$$\texttt{\small Ejemplos de puntos en el círculo unitario y sus fases.}$$

El espacio de trabajo será un cuerpo de vectores sobre el círculo unitario, lo cual se define en [1] como una regla que asigna un único vector velocidad $\dot{\theta} = f(\theta) $ a cada punto del círculo $\theta$.

Inicialmente consideremos un oscilador, es decir, el destello de una sola luciérnaga, mediante el modelo que se propone en la sección 4.5 de [1]. 

Suponga que $\theta(t)$ es la fase del destello de la luciérnaga donde $\theta(t) = 0$ significa que en el tiempo $t$ se produjo un destello.
Si suponemos que la luciérnaga está aislada, que no hay estímulos para el destello, podemos considerar que la frecuencia con la que se da el destello está dada por un oscilador uniforme $\dot{\theta} = \omega$.

Para añadir un estímulo que altere la frecuencia del destello, considere un estímulo periódico cuya fase $\Theta$ satisface $\dot{\Theta} = \Omega$. Debe ocurrir que la luciérnaga aumente su velocidad de destello si el estímulo está adelante del ciclo uniforme (este está dado por la fase $\theta$) y si la baja si está detrás (si va primero el estímulo y luego el destello de la luciérnaga) (esto también se puede explicar con el $\textit{beat phenomenon}$).

Podemos modelar lo anterior con la ecuación $$\dot{\theta} = \omega + A \sin(\Theta-\theta)$$ (podemos añadir información de osciladores no uniformes) 


## Modelos base

Antes de estudiar un modelo con múltiples agentes, trabajaremos con los casos más sencillos: un solo agente (un oscilador con y sin estímulo) y dos agentes:

$\begin{align*}
    &\dot\theta =\omega & (1)\\
    &\begin{cases}
        \dot\theta &=\omega + K\sin(\Theta-\theta)\\
        \dot\Theta &= \Omega
    \end{cases} & (2)\\
    &\begin{cases}
        \dot\theta_1 &=\omega_1 + K_1\sin(\theta_2-\theta_1)\\
        \dot\theta_2 &= \omega_2 + K_2\sin(\theta_1-\theta_2)
    \end{cases} & (3)
\end{align*}$

Estudiaremos las particularidades de cada modelo. En los casos con un agente, buscaremos ajustar el modelo con datos reales.

### Análisis del modelo

En esta primera sección de análisis, aplicaremos varios de los conocimientos introducidos en clase, clasificando los equilibrios de sistemas de 1 y 2 dimensiones y exploraremos de cerca los fenómenos que surgen en la versión con dos dimensiones. Igualmente, estudiaremos las bifurcaciones presentes al variar parámetros y construiremos algunos diagramas de bifurcación.

### Trabajo con datos

En esta parte, nuestro objetivo es, para los modelos con un agente, ajustar la constante de acoplamiento y la frecuencia natural a datos reales de la emisión de destellos de algunas especies de luciérnaga. Esta información será relevante cuando trabajemos con el modelo grande. 

## Modelo de Kuratamo

Tomando como punto de partida el modelo de Kuramoto:

$\begin{align*}
    \dot\theta &= \omega_1 +\dfrac{1}{N}\sum_{j=1}^NK_{ij}\sin(\theta_j-\theta_i), \qquad i=1,\cdots, N &(4)
\end{align*}$

En esta sección usaremos el centroide de los puntos sobre el círculo unitario, cuyas coordenadas polares se suelen denominar parámetros de orden, el radio es un indicador de la coherencia y la fase es el promedio de las fases de todos los osciladores en el círculo. 

![cir2](https://i.ibb.co/JR5qRVf/cir2.png)

$$\texttt{\small Ejemplos de parámetros de orden.}$$

Estudiaremos el comportamiento del modelo a largo plazo y analizaremos algunos casos simplificados del modelo, apuntando a usar información como los parámetros de orden para ajustar nuestro modelo con datos reales. También tenemos el objetivo de dibujar algunos diagramas de bifurcación, y realizar simulaciones extensivamente, explorando escenarios en los que un agente es afectado por todos los demás agentes y en los que es estimulado únicamente por agentes cercanos.
"""

# ╔═╡ 1ace81ce-0897-4edf-805e-b36cb238866a
md"""
## Resultados esperados

"""

# ╔═╡ d4ce8449-5da5-4512-bced-1a8e952790d4
md"""
## Referencias iniciales

[1] Strogatz, S. H. (2015). Nonlinear dynamics and chaos: With applications to physics, biology, chemistry, and engineering (2nd ed.). CRC Press.

[2] Strogatz, S. H. (2000). From Kuramoto to Crawford: Exploring the onset of synchronization in populations of coupled oscillators. Physica D: Nonlinear Phenomena, 143(1-4), 1-20.

[3] 
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.60"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.1"
manifest_format = "2.0"
project_hash = "8aa109ae420d50afa1101b40d1430cf3ec96e03e"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╠═094f2d6e-4871-4189-8301-37cda62918aa
# ╠═4f45bb8c-49aa-4330-b4df-c3ab9f562cf5
# ╟─60412e5c-b686-11ef-156c-b1e1858bb3d1
# ╟─a659978a-ffd7-4b59-a256-36f97f5c6cf9
# ╟─91d638e4-5e87-4180-b04c-38681e609198
# ╟─1ace81ce-0897-4edf-805e-b36cb238866a
# ╟─d4ce8449-5da5-4512-bced-1a8e952790d4
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
