
use DeviceRepair

--4. Utilizando T-SQL realizar los siguientes ejercicios:
--a. Crea un procedimiento almacenado llamado sp_RegistrarReparacion, que
--permita registrar una nueva reparación en la tabla Repara, cumpliendo con las
--siguientes reglas:
--Parámetros de entrada:
--@NumSerie (char(10)): Número de serie de la unidad.
--@IdProd (int): ID del producto asociado.
--@IdEmp (int): ID del empleado que realiza la reparación.
--@CostoRepara (money): Costo de la reparación.
--Validaciones:
--La unidad (@NumSerie, @IdProd) debe existir en la tabla Unidad.
--El empleado (@IdEmp) debe existir en la tabla Empleado.
--Un empleado no puede registrar más de una reparación para la misma unidad en el mismo día.
--El costo de reparación no puede ser negativo.
--Operación:
--Insertar la nueva reparación en la tabla Repara, con el estado 'Iniciado' y la
--fecha/hora actual.
--Retornar un mensaje indicando el éxito o el motivo delfallo.
	CREATE PROCEDURE sp_RegistrarReparacion 
	@NumSerie char(10),@IdProd int,@IdEmp int,@CostoRepara money
	AS 
	BEGIN
	 SET NOCOUNT ON
	 IF NOT EXISTS(SELECT 1 FROM Unidad where @NumSerie = NumSerie and @IdProd = IdProd)
	 BEGIN
	 PRINT 'La unidad no existe '
	 RETURN 
	 END
	 IF NOT EXISTS(SELECT 1 FROM Empleado where @IdEmp = IdEmp)
	 BEGIN
	 PRINT 'El empleado no existe'
	 RETURN
	 END
	 IF(@CostoRepara < 0)
	 BEGIN
	 PRINT 'El costo de reparacion no puede ser menor a 0'
	 RETURN
	 END
	 IF EXISTS(SELECT 1 FROM Repara WHERE IdProd = @IdProd AND NumSerie = @NumSerie AND IdEmp = @IdEmp AND DAY(FchRepara) = DAY(GETDATE()))
	 BEGIN
	 PRINT 'El empleado ya hizo una reparacion para esa unidad hoy'
	 END
	insert into Repara(NumSerie, IdProd ,IdEmp ,FchRepara,CostoRepara)
	VALUES (@NumSerie,@IdProd,@IdEmp,GETDATE(),@CostoRepara);
	PRINT 'La reparacion se a insertado correctamente'
	END;
	


--b. Crea una función escalar llamada fn_CalcularTiempoReparacion, que reciba el
--número de serie y el ID del producto y devuelva el tiempo total (en días) que ha
--estado en reparación.
--Parámetros de entrada
--@NumSerie (char(10)): Número de serie de la unidad.
--@IdProd (int): ID del producto.
--Contar todos los días únicos en los que la unidad ha estado en reparación, sin
--importar el número de reparaciones en un mismo día.
--Usar la columna FchRepara de la tabla Repara.
--Si la unidad no tiene reparaciones registradas, debe devolver NULL.
--Salida:
--Un int con la cantidad de días distintos en los que se ha reparado la unidad.
CREATE FUNCTION fn_CalcularTiempoReparacion 
(@NumSerie char(10),@IdProd int) RETURNS INT AS 
BEGIN
DECLARE @TiempoTotalEnDias int
SELECT @TiempoTotalEnDias = COUNT(DISTINCT FchRepara) 
FROM Repara
WHERE @NumSerie = NumSerie AND @IdProd = IdProd
IF (@TiempoTotalEnDias = 0)
BEGIN
RETURN NULL
END
RETURN @TiempoTotalEnDias
END

--5. Escribir los siguientes disparadores (por supuesto: considerando modificaciones
--múltiples)
--a. Crea un disparador llamado trg_ControlEstadoReparacion, que se active
--cuando se UPDATE la columna StsRepara ON Repara.
--Eltrigger debe ejecutarse cuando:
--El estado de reparación (StsRepara) cambie a "Terminado" o "Cancelado".
--No debe activarse si el estado no cambió.
--Acciones a realizar:
--Registrar el cambio en una tabla llamada HistoricoReparacion, que debe
--crearse con los siguientes campos:
--CREATE TABLE HistoricoReparacion (
--IdHist INT IDENTITY PRIMARY KEY,
--IdRepara INT NOT NULL,
--NumSerie CHAR(10) NOT NULL,
--IdProd INT NOT NULL,
--EstadoAnterior VARCHAR(20) NOT NULL,
--EstadoNuevo VARCHAR(20) NOT NULL,
--FchCambio DATETIME DEFAULT GETDATE());
--Insertar en esta tabla el IdRepara, NumSerie, IdProd, el estado anterior, el
--estado nuevo y la fecha del cambio.

CREATE TRIGGER trg_ControlEstadoReparacion
ON Repara 
AFTER UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 INSERT INTO HistoricoReparacion(IdRepara, NumSerie, IdProd, EstadoAnterior, EstadoNuevo)
 SELECT d.IdRepara,d.NumSerie,d.IdProd,d.StsRepara as EstadoAnterior,i.StsRepara as EstadoNuevo
 FROM inserted i, deleted d 
 where i.IdRepara = d.IdRepara 
 and d.StsRepara <> i.StsRepara and
 i.StsRepara in ('Terminado'  , 'Cancelado');
END;

--b. Crea un disparador llamado trg_PrevenirEliminacionReparaciones, que impida
--la eliminación de registros en la tabla Repara si la reparación tiene el estado
--"Terminado" o "En testing".
--Eltrigger debe activarse cuando se intente eliminar un registro en Repara.
--Debe permitir eliminar reparaciones solo si su estado es "Iniciado" o
--"Cancelado".
--Si el estado es "En testing" o "Terminado", debe bloquear la eliminación y
--mostrar un mensaje de error.
--Si la eliminación es permitida, debe registrarse en una tabla de auditoría
--HistoricoEliminacionReparaciones, con los siguientes datos:
--CREATE TABLE HistoricoEliminacionReparaciones (
--IdHist INT IDENTITY PRIMARY KEY,
--IdRepara INT NOT NULL,
--NumSerie CHAR(10) NOT NULL,
--IdProd INT NOT NULL,
--StsRepara VARCHAR(20) NOT NULL,
--FchEliminacion DATETIME DEFAULT GETDATE()
--);
CREATE TRIGGER trg_PrevenirEliminacionReparaciones
ON Repara
instead of DELETE
AS
BEGIN
set nocount on;
if exists (select 1 from deleted  where StsRepara in ('En testing', 'Terminado'))
BEGIN
 THROW 51000, 'No se puede eliminar porque el StsRepara esta en Testing o Terminado.', 1;  
 RETURN;
END
insert into HistoricoEliminacionReparaciones(IdRepara,NumSerie,IdProd,StsRepara)
select d.IdRepara,d.NumSerie,d.IdProd,d.StsRepara 
from deleted d;
DELETE FROM Repara 
WHERE IdRepara in (select IdRepara from deleted)
END;


--la tabla deleted es la tupla anterior al cambio
--y la tabla inxserted es la tupla despues del cambio


--6. Crea una vista llamada vw_ReparacionesActivas, que muestre información detallada
--de las reparaciones en curso, es decir, aquellas cuyo estado sea "Iniciado" o "En
--testing".
--La vista debe incluirla siguiente información:
--IdRepara (ID de la reparación).
--NumSerie (Número de serie de la unidad).
--IdProd (ID del producto).
--DscProd (Descripción del producto, obtenida de la tabla Producto).
--NomEmp (Nombre del empleado que está realizando la reparación, obtenido de
--Empleado).
--FchRepara (Fecha de reparación).
--StsRepara (Estado de la reparación).
--Filtrar solo las reparaciones activas, es decir, aquellas con StsRepara = 'Iniciado' o
--StsRepara = 'En testing'.
 CREATE VIEW vw_ReparacionesActivas AS
 SELECT  r.IdRepara,r.NumSerie,r.IdProd,p.Dscprod,e.NomEmp,r.FchRepara,r.StsRepara
 from Repara r
 inner join Producto p on p.IdProd = r.IdProd
 inner join Empleado e on e.IdEmp = r.IdEmp
 where r.StsRepara in ('Iniciado', 'En testing')





