# Lab00: Introducción a Verilog, Simulación y Máquinas de Estados Finitos (FSM)

**Grupo:** G4
**Integrantes:**
- Jana Rubbiano Hurtado
- Alina Idaly Ortiz Martinez
- Johana
- Laura Alejandra Moreno

---

## 1. Objetivos del Laboratorio
- Diseñar e implementar Máquinas de Estados Finitos (FSM) sencillas en Verilog.
- Validar el comportamiento de los diseños mediante testbench y visualización de señales en GTKWave.

---

## 2. Estructura del Repositorio
La carpeta `src/` contiene todos los archivos fuente en Verilog y sus respectivos testbenches para los ejercicios desarrollados:

* `semaforo1.v` / `tb_semaforo1.v` (Ejercicio 1)
* `acumulador.v` / `tb_acumulador.v` (Ejercicio 2, variante 1)
* `acumulador.v` / `tb_acumulador.v` (Ejercicio 2, variante con limite de acumulación)


---

## 3. Desarrollo de los Ejercicios

### Ejercicio 1: FSM de control – Semáforo simple
**Descripción:** 
Se diseñó un semáforo vehicular controlado por una FSM de tres estados (`Verde: S0`, `Amarillo: S1`, `Rojo: S2`). 
* .
(explicacion del la maquina... he insertar imagen)


**Codigo elaborado:** 
En cuanto al codigo se definieron las entradas que en este caso serian el *rst* y el *clk*, se crearon ademas las salidas para cada color, y se definieron los parametros locales y registros necesarios para manejar los cambios entre  estados todo con el fin del correcto funcionamiento del diseño.

(poner aca una seccion del codigo)

