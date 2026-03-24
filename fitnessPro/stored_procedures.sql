USE [FitnessPro]
GO

/****** Object:  StoredProcedure [dbo].[p_ActualizarEstadoCliente]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [dbo].[p_ActualizarEstadoCliente]
as
Begin
	declare @fechaL date = dateadd(MONTH,-6,cast(getdate() as date));
	--Crea la tabla temporal si no existe--
	if OBJECT_ID('dbo.Auditoria') is null
	begin
		CREATE TABLE Auditoria (
			nombre_cliente NVARCHAR(100),
			monto DECIMAL(10,2),
			fecha_hora DATETIME DEFAULT GETDATE(),
			descripcion NVARCHAR(255)
		);
	end
	--Insertar datos en tabla temporal Auditoria--
	insert into Auditoria(nombre_cliente,monto,fecha_hora,descripcion)
	select 
		cast(C.id_cliente as nvarchar) + '-) ' + C.nombre + ' ' + C.apellido as nombre_cliente,
		0.00 as monto,
		GETDATE() as fecha_hora,
		'Cliente Moroso' as descripcion
	from Cliente C
	inner join Inscripcion I on C.id_cliente = I.id_cliente
	inner join Pago P on I.id_inscripcion = P.id_inscripcion
	group by C.id_cliente,C.nombre,C.apellido
	having MAX(P.fecha_pago) < @fechaL;
	--Cambiar el estado del cliente--
	update C
	set id_estado = 2
	from Cliente C
	where exists(
	select 1 from Pago P 
	inner join Inscripcion I on P.id_inscripcion = I.id_inscripcion
	where I.id_cliente = C.id_cliente
	group by I.id_cliente
	having max(P.fecha_pago) < @fechaL);
End;
GO
/****** Object:  StoredProcedure [dbo].[p_RegistrarInscripcion]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [dbo].[p_RegistrarInscripcion]
--Parametros de entrada--
@cliente int,
@servicio int,
@fecha date,
@horario int
as
Begin
	--Declaracion de variables internas--
	declare @Vcliente int, @Vservicio int;
	declare @nuevaInsc int, @duplicado int;
	declare @numeroInsc int,@costoS decimal(10,2),@decuento decimal(10,2),@nombreC nvarchar(100);
	--Crea la tabla temporal si no existe--
	if OBJECT_ID('dbo.Auditoria') is null
	begin
		CREATE TABLE Auditoria (
			nombre_cliente NVARCHAR(100),
			monto DECIMAL(10,2),
			fecha_hora DATETIME DEFAULT GETDATE(),
			descripcion NVARCHAR(255)
		);
	end
	--Validar si el cliente y el servicio existe--
	select @Vcliente = COUNT(*) from Cliente where @cliente = id_cliente;
	select @Vservicio = COUNT(*) from Servicio where @servicio = id_servicio;
	if @Vcliente = 0 or @Vservicio = 0
	begin
		throw 50003, 'El cliente o el servicio no existen',1;
		return;
	end
	--Validar que el cliente no este inscrito en ese servicio o en ese horario--
	select @duplicado = COUNT(*) from Inscripcion I
	where I.id_cliente = @cliente and I.id_horario = @horario 
	and exists 
			(select 1 from Horario_Servicio H 
			 where H.id_horario = I.id_horario or H.id_servicio = @servicio);
	if @duplicado > 0
	begin
		throw 50004, 'El cliente ya está inscrito en ese servicio o tiene ese horario.', 1;
        return;
	end;
	--Insertar nuevo registro--
	select @nuevaInsc = ISNULL(MAX(id_inscripcion),0) + 1 from Inscripcion
	insert into Inscripcion(id_inscripcion, id_cliente,fecha_inscripcion,id_horario)
	values(@nuevaInsc,@cliente,@fecha,@horario);
	--Crear registro de descuento en la tabla Auditoria--
	select @numeroInsc = count(*) from Inscripcion where id_cliente = @cliente;
	if @numeroInsc >= 3
	begin
		select @costoS = costo from Servicio where id_servicio = @servicio;
		set @decuento = @costoS * 0.10;
		select @nombreC = nombre + ' ' + apellido from Cliente where id_cliente = @cliente;
			insert into Auditoria(nombre_cliente,monto,descripcion)
			values(@nombreC,@decuento,'10% decuento');
	end
End;
GO
/****** Object:  StoredProcedure [dbo].[p_RegistrarPago]    Script Date: 24/3/2026 09:16:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [dbo].[p_RegistrarPago]
--Parametros de entrada--
@cliente int,
@monto decimal(10,2),
@fecha date,
@metodo int
as
--Instruccion principal--
Begin
	--Declaracion de variables internas--
	declare @id_InscripcionV int, @nuevo_id int;
	declare @validarCliente int, @clienteEst int, @estadoAct int = 1;
	declare @nombreC NVARCHAR(100),@descripcion NVARCHAR(255);
	--Crea la tabla temporal si no existe--
	if OBJECT_ID('dbo.Auditoria') is null
	begin
		CREATE TABLE Auditoria (
			nombre_cliente NVARCHAR(100),
			monto DECIMAL(10,2),
			fecha_hora DATETIME DEFAULT GETDATE(),
			descripcion NVARCHAR(255)
		);
	end
	--Verificar si el cliente existe--
	select @validarCliente = COUNT(*) from Cliente where id_cliente = @cliente;
		if @validarCliente = 0
		begin
			throw 50001, 'El cliente no existe',1;
			return
		end
	select @nombreC = nombre + ' ' + apellido from cliente where id_cliente = @cliente;
	--Cambiar estado del cliente si existe--
	select @clienteEst = id_estado from Cliente where id_cliente = @cliente;
		if @clienteEst <> @estadoAct
		begin
			update Cliente set id_estado = @estadoAct where id_cliente = @cliente;
			set @descripcion = 'Estado actualizado "Activo"';
		end else
		begin
			set @descripcion = 'Estado no actualizado'
		end
	--Buscarla ultima inscripcion--
	select TOP 1 @id_inscripcionV = id_Inscripcion from Inscripcion where id_cliente = @cliente
	order by id_inscripcion desc;
		--Validar si el cliente tiene incripcion--
		if @id_InscripcionV is not null
		begin
			--Crear un nuevo id_pago--
			select @nuevo_id = ISNULL(MAX(id_pago),0) + 1 from Pago;
				--Insertar el pago--
				insert into Pago (id_pago ,id_inscripcion,monto,fecha_pago,id_metodo)
				values(@nuevo_id,@id_InscripcionV,@monto,@fecha,@metodo);
					--Insertar linea a la tabla auditoria Temporal--
					insert into Auditoria (nombre_cliente,monto,descripcion)
					values (@nombreC,@monto,@descripcion);
		end else
		begin
			throw 50002, 'El cliente no tiene inscripcion',1;
			return
		end
End;
GO
