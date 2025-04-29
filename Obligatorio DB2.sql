

CREATE DATABASE DeviceRepair
GO

USE DeviceRepair

DROP TABLE IF EXISTS Empleado;
DROP TABLE IF EXISTS Producto;
DROP TABLE IF EXISTS Unidad;
DROP TABLE IF EXISTS Repara;


CREATE TABLE Empleado (
IdEmp INT PRIMARY KEY not null, 
NomEmp VARCHAR (30) not null, 
FchNacEmp DATE not null, 
SueldoEmp INT not null, 
TipoEmp CHAR(1) not null  CHECK(TipoEmp IN('T' ,'C')) 
)
--Los empleados pueden ser de dos tipos, técnicos “T” o controllers “C”, si son técnicos
--participan en la reparación de equipos, si son controllers son los que hacen el control de
--calidad de las reparaciones (QA).

CREATE TABLE Producto (
IdProd INT IDENTITY PRIMARY KEY not null, 
Dscprod VARCHAR(225) not null, 
StkProd INT not null,
CostoProd INT not null 
)
--Cada producto tiene un identificador autonumérico y siempre se conoce tanto su descripción,
--el stock y el costo de los mismos.

CREATE TABLE Unidad (
NumSerie INT PRIMARY KEY,
IdProd INT , 
FchFab DATE, 
FchVto DATE,
CONSTRAINT FK_ProductoPorUnidad FOREIGN KEY (IdProd) REFERENCES Producto(IdProd)
)
--Son las unidades de cada producto, están identificadas con un número de serie dependiente
--del producto,también se conoce la fecha de fabricación y la fecha de vencimiento del
--producto.

CREATE TABLE Repara(
IdRepara INT IDENTITY PRIMARY KEY not null, 
NumSerie INT not null, 
IdProd INT not null, 
IdEmp INT not null, 
FchRepara DATE not null, 
CostoRepara INT not null, 
IdEmpQA INT 
--CONSTRAINT FK_UnidadRepara FOREIGN KEY (NumSerie) REFERENCES Unidad(NumSerie), esto tenemos que descomentarlo
CONSTRAINT FK_ProductoRepara FOREIGN KEY (IdProd) REFERENCES Producto(IdProd),
CONSTRAINT FK_EmpleadoRepara FOREIGN KEY (IdEmp) REFERENCES Empleado(IdEmp),
CONSTRAINT FK_EmpControlReparacionesRepara FOREIGN KEY (IdEmpQA) REFERENCES Empleado (IdEmp),
--Falta avisar en una condicion que IdEmpQA sea 'C', puede ir en el insert.
--Falta check de idemp que sea 'T'
)
--Las reparaciones de las unidades de cada producto por parte de los empleados técnicos,
--están identificadas con un autonumérico, se conocen los datos, se conoce además de los
--datos identificatorios de las unidades, el identificador deltécnico que repara, la fecha el costo
--y el identificador deltécnico que realiza el control de calidad.
--INSERT INTO Empleado(IdEmp,NomEmp,FchNacEmp,SueldoEmp,TipoEmp)
--VALUES
--(1,'Juan','1985-12-25',20000,'T'),
--(2,'Eva','1985-12-25',20000,'C'),
--(3,'Alvaro','1985-12-25',20000,'T'),
--(4,'Roberto','1985-12-25',20000,'C');
--SELECT * FROM Empleado
INSERT INTO Empleado (IdEmp, NomEmp, FchNacEmp, SueldoEmp, TipoEmp)
VALUES 
(5, 'Lucia', '1990-03-15', 22000, 'T'),
(6, 'Carlos', '1987-07-20', 21000, 'C'),
(7, 'Mateo', '1992-01-10', 23000, 'T'),
(8, 'Laura', '1989-11-05', 25000, 'C'),
(9, 'Sofia', '1991-06-30', 24000, 'T'),
(10, 'Andres', '1986-09-12', 20000, 'C');


--INSERT INTO Producto(Dscprod,StkProd ,CostoProd)
--VALUES
--('El mejor producto',10,100),
--('El mejor ',15,150),
--('La mejor calidad',20,200),
--('Calidad intermedia',5,50);
INSERT INTO Producto (Dscprod, StkProd, CostoProd)
VALUES 
('Producto A', 12, 120),
('Producto B', 18, 180),
('Producto C', 25, 250),
('Producto D', 8, 80),
('Producto E', 14, 140),
('Producto F', 20, 200);
SELECT * FROM Producto


INSERT INTO Unidad (NumSerie, IdProd, FchFab, FchVto)
VALUES 
(5, 5, '2022-01-01', '2025-01-01'),
(6, 6, '2022-02-01', '2025-02-01'),
(7, 7, '2022-03-01', '2025-03-01'),
(8, 8, '2022-04-01', '2025-04-01'),
(9, 9, '2022-05-01', '2025-05-01'),
(10, 10, '2022-06-01', '2025-06-01');
SELECT * FROM Producto;


--INSERT INTO Repara(NumSerie,IdProd,IdEmp,FchRepara,CostoRepara,IdEmpQA)
--VALUES
--(1,1,1,'1985-12-25',100,null),
--(2,1,1,'1995-12-25',200,2),
--(3,3,1,'1980-12-25',50,null),
--(4,2,1,'1985-12-25',150,2);
INSERT INTO Repara (NumSerie, IdProd, IdEmp, FchRepara, CostoRepara, IdEmpQA)
VALUES 
(5, 5, 5, '2023-01-15', 300, 6),
(6, 6, 7, '2023-02-20', 320, 8),
(7, 7, 9, '2023-03-25', 310, 6),
(8, 8, 5, '2023-04-10', 290, 10),
(9, 9, 7, '2023-05-05', 330, NULL), -- Sin QA
(10, 10, 9, '2023-06-01', 280, 8);

select * from Repara


--a. Para todos los productos existentes, mostrar código y descripción, cantidad de
--reparaciones con control de calidad realizado, cantidad sin control realizado y
--cantidad de reparaciones cuyo valor fue superior a $100.
SELECT 
p.IdProd AS Codigo,
p.Dscprod AS Descripcion,
--//conta en el caso cuando idempqa no es null entonces agregale 1 y terminalo
count(Case when r.IdEmpQA IS NOT NULL then 1 else 0 end) as ConControl,
SUM(Case when r.IdEmpQA IS NULL then 1 else 0 end) as SinControl,
SUM(Case when r.CostoRepara > 100 then 1 else 0 end) as CantidadMayoresAcien
FROM Producto p
LEFT JOIN Repara r ON R.IdProd = P.IdProd
GROUP BY P.IdProd , p.Dscprod


--b. Muestra los datos del Empleado con mayor cantidad de reparaciones realizadas.select TOP 1 e.*, COUNT(r.IdRepara) CantidadReparacionesRealizadas
from Empleado e
INNER JOIN Repara r ON r.IdEmp = e.IdEmp
group by e.FchNacEmp,e.IdEmp,e.NomEmp,e.SueldoEmp,e.TipoEmp
order by CantidadReparacionesRealizadas
