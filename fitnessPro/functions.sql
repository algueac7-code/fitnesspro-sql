USE [FitnessPro]
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
