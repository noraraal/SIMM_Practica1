# Práctica de Tipos de Objetos en Oracle

Esta práctica contiene ejercicios enfocados en la creación y manipulación de **tipos de objetos** en Oracle Database, utilizando tipos `OBJECT`, `REF`, `VARRAY` y relaciones entre objetos.

## Ejercicio 1: Tipos de Objetos y Tablas

- Se crea un tipo de objeto `Producto` con los atributos:
  - `id_producto` (NUMBER)
  - `nombre` (VARCHAR2)
  - `precio` (NUMBER con decimales)
- Se crea una tabla `Productos` basada en ese tipo.
- Se insertan al menos dos registros.
- Se actualiza un precio y se elimina un producto.

## Ejercicio 2: Relaciones entre Objetos con REF

- Se define un tipo `Empleado` con `id_emp` y `nombre`.
- Se crea una tabla `Empleados`.
- Se define un tipo `Proyecto` que contiene una referencia (`REF`) a un empleado.
- Se crea la tabla `Proyectos` con `SCOPE IS Empleados`.
- Se insertan datos y se consulta el nombre del empleado responsable de un proyecto usando `DEREF`.

## Ejercicio 3: Uso de VARRAY y Colecciones

- Se define un tipo `Telefonos` como `VARRAY(3)` de `VARCHAR2(15)`.
- Se crea un tipo `Cliente` que incluye una colección de teléfonos.
- Se crea la tabla `Clientes` y se insertan datos.
- Se realiza una consulta que descompone los teléfonos con `TABLE(cliente.telefonos)`.

---

## Requisitos

- Oracle Database 11g o superior.
- SQL*Plus o alguna herramienta compatible como SQL Developer.

## Ejecución

Los scripts deben ejecutarse en orden para evitar conflictos por dependencias entre tipos y tablas.

---

**Autores:** Nora Raghay, Sergi Adrià y Arnau Oller
**Fecha:** Abril 2025  
