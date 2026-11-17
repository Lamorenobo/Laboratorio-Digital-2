# Informe Lab04 – SoC Zynq-7000

**Curso:** Electrónica Digital 2  
**Grupo:** G3/G4  
**Estudiante:** [Tu Nombre / jovelasquezs]  
**Fecha:** [Fecha de entrega]  

---

## 1. Objetivos de la Práctica
Durante esta sesión de laboratorio, los objetivos cumplidos fueron:
* Implementar un SoC mediante la herramienta Block Design de Vivado.
* Identificar y conectar los bloques principales que componen el Zynq-7000 (Procesador, Memoria, Periféricos y Lógica Programable).
* Preparar y exportar una plataforma de hardware (archivo XSA) para su posterior desarrollo de software en Vitis.
* Comprobar la relación entre hardware programable y sistemas embebidos operando los LEDs y botones de la tarjeta Zybo Z7.

---

## 2. Evidencias del Procedimiento

### 2.1 Integración y Creación del Proyecto
Se creó el proyecto en Vivado seleccionando la tarjeta Zybo Z7-10 en lugar de seleccionar directamente la FPGA.

> ![Selección de la Zybo Z7](ruta/a/tu/imagen_zybo_z7.png)

### 2.2 Creación del SoC en Vivado (Hardware)

A través de la herramienta *IP INTEGRATOR > Create Block Design*, se añadieron y configuraron los bloques necesarios (ZYNQ7 Processing System, Processor System Reset, AXI Interconnect, AXI BRAM Controller y Block Memory Generator). 
> ![bloques necesarios](ruta/a/tu/bloques.jpeg)

Además, se añadieron los puertos GPIO correspondientes a los 4 botones y 4 LEDs de la tarjeta.


> ![bloques necesarios](ruta/a/tu/bloquesunidos.jpeg)

Tras realizar las conexiones (clk, rst, AXI) y ejecutar *Regenerate Layout*, el diagrama de bloques resultante es el siguiente:

> ![Diagrama de Bloques Finalizado](ruta/a/tu/bloquesfinal.jpeg)

Posteriormente, en la pestaña *Address Editor*, se asignó y ajustó el rango de memoria a 4K para `/axi_gpio_0/S_AXI`.

> ![Configuración en Address Editor](ruta/a/tu/conexionfinal.jpeg)

Se generó el *HDL Wrapper* permitiendo que Vivado lo administre y auto-actualice, y se ejecutó la automatización del diseño (*Run Block Automation*). Finalmente, se generó el *Bitstream* de manera exitosa y se exportó la plataforma de hardware (archivo `.xsa`).

> ![ejecucion del "Run Block Automations"](ruta/a/tu/running.jpeg)

---

### 2.3 Entorno de Vitis (Software)

Con el hardware exportado, se inició Vitis IDE. Se creó un nuevo *Platform Component* utilizando el archivo `.xsa` previamente generado.

> ![Creación de Plataforma en Vitis](ruta/a/tu/platforma.jpeg)

A continuación, se creó una nueva *Application* basada en esta plataforma. Se añadió el archivo `main.c` (provisto en la carpeta `src`) a la carpeta de recursos de la aplicación. El proyecto se compiló sin errores (*Build*), preparándolo para ser ejecutado en la placa.

> **[INSTRUCCIÓN: Inserta aquí la captura de la consola mostrando que el Build fue exitoso]**
> ![Build exitoso en Vitis](ruta/a/tu/build.png)

---

## 3. Resultado Final (Funcionamiento en la FPGA)

Tras conectar la Zybo Z7 y ejecutar el programa (*RUN*), se verificó el correcto funcionamiento del sistema diseñado. Los LEDs de la Zybo parpadean y, al mantener presionado uno de los botones, el LED correspondiente permanece encendido.

A continuación, se presenta la evidencia en video del funcionamiento:

> **🎥 [Ver Video de Demostración del Funcionamiento](https://drive.google.com/file/d/1NC0a47g0rdO35dtqtwtyKakphZyYn-mS/view?usp=drive_link)**

---

## 4. Conclusiones
Se logró comprender y ejecutar el flujo de trabajo completo para instanciar un sistema de procesamiento en el Zynq-7000. El uso de la herramienta Block Design en Vivado permitió integrar el procesador y la lógica programable, estableciendo una plataforma de hardware funcional y preparada para su uso en el proyecto final.

El único inconveniente presentado durante la práctica fue la asignación de las salidas (LEDs) en el mapa de memoria. Al analizar el problema, se determinó que este correspondía a un detalle en el código de software (Vitis) y no a un error de configuración o montaje en Vivado. Esta situación reforzó la importancia del correcto direccionamiento al comunicar periféricos físicos con el procesador.

La práctica permitió validar la interacción directa entre hardware y software. Exportar el diseño base desde Vivado y programarlo en C mediante Vitis demostró de manera práctica cómo se controlan componentes físicos a través de un sistema embebido integrado.
