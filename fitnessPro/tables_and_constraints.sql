USE [FitnessPro]
GO

/****** Object:  Table [dbo].[Gimnasio]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Gimnasio](
	[cod_gimnasio] [int] NOT NULL,
	[nombre] [nvarchar](100) NOT NULL,
	[direccion] [nvarchar](255) NOT NULL,
	[telefono] [nvarchar](20) NULL,
 CONSTRAINT [PK_Gimnasio] PRIMARY KEY NONCLUSTERED 
(
	[cod_gimnasio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cliente]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cliente](
	[id_cliente] [int] NOT NULL,
	[nombre] [nvarchar](50) NOT NULL,
	[apellido] [nvarchar](50) NOT NULL,
	[correo] [nvarchar](100) NOT NULL,
	[telefono] [nvarchar](20) NULL,
	[fecha_inscripcion] [date] NOT NULL,
	[id_estado] [int] NOT NULL,
 CONSTRAINT [PK_Cliente] PRIMARY KEY NONCLUSTERED 
(
	[id_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Horario_Servicio]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Horario_Servicio](
	[id_horario] [int] NOT NULL,
	[id_personal] [int] NOT NULL,
	[cod_gimnasio] [int] NOT NULL,
	[id_servicio] [int] NOT NULL,
	[hora_inicio] [time](7) NOT NULL,
	[hora_final] [time](7) NOT NULL,
 CONSTRAINT [PK_HorarioServicio] PRIMARY KEY NONCLUSTERED 
(
	[id_horario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Inscripcion]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Inscripcion](
	[id_inscripcion] [int] NOT NULL,
	[id_cliente] [int] NOT NULL,
	[id_horario] [int] NOT NULL,
	[fecha_inscripcion] [date] NOT NULL,
 CONSTRAINT [PK_Inscripcion] PRIMARY KEY NONCLUSTERED 
(
	[id_inscripcion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Pago]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pago](
	[id_pago] [int] NOT NULL,
	[id_inscripcion] [int] NOT NULL,
	[monto] [decimal](10, 2) NOT NULL,
	[fecha_pago] [date] NOT NULL,
	[id_metodo] [int] NOT NULL,
 CONSTRAINT [PK_Pago] PRIMARY KEY NONCLUSTERED 
(
	[id_pago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[f_CalcularIngresoPorGimnasio]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   function [dbo].[f_CalcularIngresoPorGimnasio]
(@gimnasio int, @fechaI date, @fechaF date)
returns table
as
	return(select G.nombre as Nombre_Gim, count(distinct I.id_inscripcion ) as Total_Inscripciones  ,SUM(P.monto) as Monto_Generado,
	cast(sum(P.monto) / nullif(count(distinct I.id_inscripcion),0)as decimal(10,1)) as promedio_por_servicio
		from Gimnasio G
		inner join Horario_Servicio HS on G.cod_gimnasio = HS.cod_gimnasio
		inner join Inscripcion I on HS.id_horario = I.id_horario
		inner join Pago P on I.id_inscripcion = P.id_inscripcion
		inner join Cliente C on I.id_cliente = C.id_cliente
		where  G.cod_gimnasio = @gimnasio
		and C.id_estado = 1
		and P.fecha_pago between @fechaI and @fechaF
		group by G.nombre);
GO
/****** Object:  Table [dbo].[Servicio]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Servicio](
	[id_servicio] [int] NOT NULL,
	[nombre] [nvarchar](100) NOT NULL,
	[descripcion] [nvarchar](255) NULL,
	[duracion_minutos] [int] NOT NULL,
	[costo] [decimal](10, 2) NOT NULL,
 CONSTRAINT [PK_Servicio] PRIMARY KEY NONCLUSTERED 
(
	[id_servicio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[f_ObtenerDetalleServicio]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   function [dbo].[f_ObtenerDetalleServicio]
(@servicio int)
returns table
as
	return(select S.nombre ,count(distinct I.id_inscripcion) as Cant_Insc, sum(P.monto) as Total_Monto, 
	(select top 1 I2.fecha_inscripcion from Inscripcion I2
            inner join Horario_Servicio HS2 ON I2.id_horario = HS2.id_horario
            where HS2.id_servicio = @servicio
            order by I2.fecha_inscripcion desc) as fecha_Ultima_Inscripcion
		from Inscripcion I
		inner join Horario_Servicio HS on I.id_horario = HS.id_horario
		left join Pago P on I.id_inscripcion = P.id_inscripcion
		inner join Servicio S on HS.id_servicio = S.id_servicio
		where S.id_servicio = @servicio
		group by S.nombre)
GO
/****** Object:  Table [dbo].[Auditoria]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Auditoria](
	[nombre_cliente] [nvarchar](100) NULL,
	[monto] [decimal](10, 2) NULL,
	[fecha_hora] [datetime] NULL,
	[descripcion] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cargo]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cargo](
	[id_cargo] [int] NOT NULL,
	[descripcion] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Cargo] PRIMARY KEY NONCLUSTERED 
(
	[id_cargo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Estado_Cliente]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Estado_Cliente](
	[id_estado] [int] NOT NULL,
	[descripcion] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_EstadoCliente] PRIMARY KEY NONCLUSTERED 
(
	[id_estado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Gimnasio_Servicio]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Gimnasio_Servicio](
	[cod_gimnasio] [int] NOT NULL,
	[id_servicio] [int] NOT NULL,
 CONSTRAINT [PK_Gimnasio_Servicio] PRIMARY KEY NONCLUSTERED 
(
	[cod_gimnasio] ASC,
	[id_servicio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Metodo_Pago]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Metodo_Pago](
	[id_metodo] [int] NOT NULL,
	[descripcion] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_MetodoPago] PRIMARY KEY NONCLUSTERED 
(
	[id_metodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Personal]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Personal](
	[id_personal] [int] NOT NULL,
	[nombre] [nvarchar](50) NOT NULL,
	[apellido] [nvarchar](50) NOT NULL,
	[id_cargo] [int] NOT NULL,
	[fecha_contratacion] [date] NOT NULL,
	[cod_gimnasio] [int] NOT NULL,
 CONSTRAINT [PK_Personal] PRIMARY KEY NONCLUSTERED 
(
	[id_personal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Auditoria] ADD  DEFAULT (getdate()) FOR [fecha_hora]
GO
ALTER TABLE [dbo].[Cliente]  WITH CHECK ADD  CONSTRAINT [FK_Cliente_Estado] FOREIGN KEY([id_estado])
REFERENCES [dbo].[Estado_Cliente] ([id_estado])
GO
ALTER TABLE [dbo].[Cliente] CHECK CONSTRAINT [FK_Cliente_Estado]
GO
ALTER TABLE [dbo].[Gimnasio_Servicio]  WITH CHECK ADD  CONSTRAINT [FK_GimServ_Gimnasio] FOREIGN KEY([cod_gimnasio])
REFERENCES [dbo].[Gimnasio] ([cod_gimnasio])
GO
ALTER TABLE [dbo].[Gimnasio_Servicio] CHECK CONSTRAINT [FK_GimServ_Gimnasio]
GO
ALTER TABLE [dbo].[Gimnasio_Servicio]  WITH CHECK ADD  CONSTRAINT [FK_GimServ_Servicio] FOREIGN KEY([id_servicio])
REFERENCES [dbo].[Servicio] ([id_servicio])
GO
ALTER TABLE [dbo].[Gimnasio_Servicio] CHECK CONSTRAINT [FK_GimServ_Servicio]
GO
ALTER TABLE [dbo].[Horario_Servicio]  WITH CHECK ADD  CONSTRAINT [FK_HorarioServ_Gimnasio] FOREIGN KEY([cod_gimnasio])
REFERENCES [dbo].[Gimnasio] ([cod_gimnasio])
GO
ALTER TABLE [dbo].[Horario_Servicio] CHECK CONSTRAINT [FK_HorarioServ_Gimnasio]
GO
ALTER TABLE [dbo].[Horario_Servicio]  WITH CHECK ADD  CONSTRAINT [FK_HorarioServ_Personal] FOREIGN KEY([id_personal])
REFERENCES [dbo].[Personal] ([id_personal])
GO
ALTER TABLE [dbo].[Horario_Servicio] CHECK CONSTRAINT [FK_HorarioServ_Personal]
GO
ALTER TABLE [dbo].[Horario_Servicio]  WITH CHECK ADD  CONSTRAINT [FK_HorarioServ_Servicio] FOREIGN KEY([id_servicio])
REFERENCES [dbo].[Servicio] ([id_servicio])
GO
ALTER TABLE [dbo].[Horario_Servicio] CHECK CONSTRAINT [FK_HorarioServ_Servicio]
GO
ALTER TABLE [dbo].[Inscripcion]  WITH CHECK ADD  CONSTRAINT [FK_Inscripcion_Cliente] FOREIGN KEY([id_cliente])
REFERENCES [dbo].[Cliente] ([id_cliente])
GO
ALTER TABLE [dbo].[Inscripcion] CHECK CONSTRAINT [FK_Inscripcion_Cliente]
GO
ALTER TABLE [dbo].[Inscripcion]  WITH CHECK ADD  CONSTRAINT [FK_Inscripcion_Horario] FOREIGN KEY([id_horario])
REFERENCES [dbo].[Horario_Servicio] ([id_horario])
GO
ALTER TABLE [dbo].[Inscripcion] CHECK CONSTRAINT [FK_Inscripcion_Horario]
GO
ALTER TABLE [dbo].[Pago]  WITH CHECK ADD  CONSTRAINT [FK_Pago_Inscripcion] FOREIGN KEY([id_inscripcion])
REFERENCES [dbo].[Inscripcion] ([id_inscripcion])
GO
ALTER TABLE [dbo].[Pago] CHECK CONSTRAINT [FK_Pago_Inscripcion]
GO
ALTER TABLE [dbo].[Pago]  WITH CHECK ADD  CONSTRAINT [FK_Pago_MetodoPago] FOREIGN KEY([id_metodo])
REFERENCES [dbo].[Metodo_Pago] ([id_metodo])
GO
ALTER TABLE [dbo].[Pago] CHECK CONSTRAINT [FK_Pago_MetodoPago]
GO
ALTER TABLE [dbo].[Personal]  WITH CHECK ADD  CONSTRAINT [FK_Personal_Cargo] FOREIGN KEY([id_cargo])
REFERENCES [dbo].[Cargo] ([id_cargo])
GO
ALTER TABLE [dbo].[Personal] CHECK CONSTRAINT [FK_Personal_Cargo]
GO
ALTER TABLE [dbo].[Personal]  WITH CHECK ADD  CONSTRAINT [FK_Personal_Gimnasio] FOREIGN KEY([cod_gimnasio])
REFERENCES [dbo].[Gimnasio] ([cod_gimnasio])
GO
ALTER TABLE [dbo].[Personal] CHECK CONSTRAINT [FK_Personal_Gimnasio]
GO
