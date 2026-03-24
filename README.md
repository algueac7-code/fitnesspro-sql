# 🏋️ FitnessPro SQL

## 📌 Descripción

Proyecto de base de datos relacional diseñado para la gestión de una cadena de gimnasios.

El sistema permite administrar clientes, servicios, horarios, inscripciones y pagos, aplicando lógica de negocio mediante procedimientos almacenados y funciones.

---

## 🚀 Funcionalidades principales

* Registro y gestión de clientes
* Administración de servicios y horarios
* Control de inscripciones a servicios
* Registro de pagos
* Validaciones de negocio:

  * Evitar duplicidad de inscripciones en el mismo horario
  * Verificación de existencia de cliente y servicio
* Auditoría de eventos relevantes

---

## 🛠️ Tecnologías utilizadas

* SQL Server
* Modelado relacional
* Procedimientos almacenados
* Funciones definidas por el usuario (UDF)

---

## 🧩 Estructura de la base de datos

El modelo incluye las siguientes entidades principales:

* Cliente
* Servicio
* Horario Servicio
* Inscripción
* Pago
* Personal
* Gimnasio
* Estado Cliente
* Método de Pago
* Auditoría

Se implementan relaciones mediante llaves primarias y foráneas, asegurando integridad referencial.

---

## ⚙️ Lógica de negocio destacada

### 📌 Procedimientos almacenados

* `p_RegistrarInscripcion`
  Registra una inscripción validando:

  * existencia del cliente
  * existencia del servicio
  * no duplicidad en el mismo horario

* `p_RegistrarPago`
  Registra pagos asociados a una inscripción y método de pago.

* `p_ActualizarEstadoCliente`
  Actualiza el estado del cliente según condiciones del sistema.

---

### 📌 Funciones

* `f_CalcularIngresoPorGimnasio`
  Calcula ingresos generados por gimnasio.

* `f_ObtenerDetalleServicio`
  Devuelve información detallada de servicios.

---

## 📂 Estructura del repositorio

```plaintext
scripts/
 ├── 00_create_database_simple.sql
 ├── 01_tables_and_constraints.sql
 ├── 02_functions.sql
 └── 03_stored_procedures.sql
```

---

## ▶️ Orden de ejecución

1. Ejecutar `00_create_database_simple.sql`
2. Ejecutar `01_tables_and_constraints.sql`
3. Ejecutar `02_functions.sql`
4. Ejecutar `03_stored_procedures.sql`

---

## 🖼️ Modelo de datos

<img width="325" height="355" alt="image" src="https://github.com/user-attachments/assets/a860640d-72bd-426f-a343-45da6ccec608" />

---

## 💾 Consideraciones

* El proyecto está diseñado para SQL Server
* Incluye lógica de validación a nivel de base de datos
* Puede extenderse con datos de prueba o interfaz de aplicación

---

## 🧠 Conceptos aplicados

* Diseño de bases de datos relacionales
* Integridad referencial
* Normalización
* Lógica de negocio en base de datos
* Validaciones mediante procedimientos almacenados

---

## 👨‍💻 Autor

Alonso Guevara

