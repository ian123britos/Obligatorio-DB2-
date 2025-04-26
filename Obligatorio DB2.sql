

CREATE DATABASE DeviceRepair
GO

USE DeviceRepair

DROP TABLE IF EXISTS Empleado;
DROP TABLE IF EXISTS Empleado;
DROP TABLE IF EXISTS Producto;


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
FchVto DATE
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
INSERT INTO Empleado(IdEmp,NomEmp,FchNacEmp,SueldoEmp,TipoEmp)
VALUES
(1,'Juan','1985-12-25',20000,'T'),
(2,'Eva','1985-12-25',20000,'C'),
(3,'Alvaro','1985-12-25',20000,'T'),
(4,'Roberto','1985-12-25',20000,'C');
SELECT * FROM Empleado

INSERT INTO Producto(Dscprod,StkProd ,CostoProd)
VALUES
('El mejor producto',10,100),
('El mejor ',15,150),
('La mejor calidad',20,200),
('Calidad intermedia',5,50);
SELECT * FROM Producto

INSERT INTO Repara(NumSerie,IdProd,IdEmp,FchRepara,CostoRepara,IdEmpQA)
VALUES
(1,1,1,'1985-12-25',100,null),
(2,1,1,'1995-12-25',200,2),
(3,3,1,'1980-12-25',50,null),
(4,2,1,'1985-12-25',150,2);











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
