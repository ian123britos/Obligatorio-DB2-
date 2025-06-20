USE  DeviceRepair
--a. Para todos los productos existentes, mostrar código y descripción, cantidad de
--reparaciones con control de calidad realizado, cantidad sin control realizado y
--cantidad de reparaciones cuyo valor fue superior a $100.
SELECT 
p.IdProd AS Codigo,
p.Dscprod AS Descripcion,
--//conta en el caso cuando idempqa no es null entonces agregale 1 y terminalo
SUM(Case when r.IdEmpQA is null then 0 else 1 end) as ConControl,
SUM(Case when r.IdEmpQA IS NULL then 1 else 0 end) as SinControl,
SUM(Case when r.CostoRepara > 100 then 1 else 0 end) as CantidadMayoresAcien
FROM Producto p
inner JOIN Repara r ON R.IdProd = P.IdProd
GROUP BY P.IdProd , p.Dscprod


--b. Muestra los datos del Empleado con mayor cantidad de reparaciones realizadas.
select TOP 1 e.*, COUNT(r.IdRepara) CantidadReparacionesRealizadas
from Empleado e
INNER JOIN Repara r ON r.IdEmp = e.IdEmp
group by e.FchNacEmp,e.IdEmp,e.NomEmp,e.SueldoEmp,e.TipoEmp
order by CantidadReparacionesRealizadas DESC

--c. Muestra datos del producto y costo total de reparaciones por producto,
--mostrando solo los productos con un costo total superior a $200.
select DISTINCT p.IdProd,p.Dscprod,p.StkProd,sum(r.CostoRepara)as SumaTotal
from Producto p
INNER JOIN Repara r ON r.IdProd = p.IdProd
group by p.IdProd,r.CostoRepara,p.Dscprod,p.StkProd
HAVING SUM(r.CostoRepara) > 200


--d. Datos del producto más reparado.
select DISTINCT p.*
from Producto p
inner join Repara r ON r.IdProd = p.IdProd
where p.IdProd IN (
select top 1 IdProd 
from Repara
group by IdProd
order by count(IdProd) desc)


--e. Escribe una consulta que muestre información detallada de los empleados,
--incluyendo:
--Clasificación del salario en tres niveles (Alto, Medio, Bajo)
--Categoría del empleado según su tipo (Tiempo Completo o Contratado) y nivel
--salarial (Senior, Junior, Experimentado).
--Cantidad de reparaciones realizadas por cada empleado.
--Ordenar la consulta por salario en orden descendente y, en caso de empate, por
--el número de reparaciones en orden descendente.
--Elige los rangos de clasificación de acuerdo con tu criterio (justifica).
select e.IdEmp ,e.NomEmp,e.TipoEmp,e.SueldoEmp,
CASE 
  WHEN e.SueldoEmp < 15000 THEN 'Bajo' 
  WHEN e.SueldoEmp BETWEEN 15000 AND 22999 THEN 'Medio'
  WHEN e.SueldoEmp >= 23000 THEN 'Alto'
END AS ClasificacionSalarial,
CASE 
   WHEN E.SueldoEmp >= 23000 THEN 'Senior'
   WHEN E.SueldoEmp BETWEEN 15000 AND 22999 THEN 'Experimentado'
   ELSE 'Junior'
END AS NivelSalarial, COUNT(R.IdRepara)AS CantidadReparaciones
from Empleado e
left join Repara r on r.IdEmp = e.IdEmp
GROUP BY e.IdEmp,e.NomEmp,e.TipoEmp,e.SueldoEmp
ORDER BY e.SueldoEmp DESC,CantidadReparaciones DESC;


--f. Muestra el costo total de reparaciones por empleado y un resumen general.
select r.IdEmp,e.NomEmp,COUNT(r.CostoRepara) as cantidadReparaciones, sum(r.CostoRepara) as CostoTotal
from Repara r
inner join Empleado e on e.IdEmp = r.IdEmp 
group by r.IdEmp,e.NomEmp


--g. Muestra los datos de los Empleados Técnicos que repararon todos los
--productos.
select e.IdEmp,e.FchNacEmp,e.NomEmp,e.SueldoEmp,e.TipoEmp
from Empleado e
inner join Repara r on r.IdEmp = e.IdEmp
where TipoEmp = 'T'
group by e.IdEmp,e.FchNacEmp,e.NomEmp,e.SueldoEmp,e.TipoEmp
HAVING COUNT(DISTINCT(r.IdProd))=(SELECT COUNT(IdProd) FROM Producto)

