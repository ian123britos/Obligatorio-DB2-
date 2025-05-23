 


CREATE DATABASE DeviceRepair
GO

USE DeviceRepair
GO


CREATE TABLE Empleado (
IdEmp INT IDENTITY PRIMARY KEY not null, 
NomEmp VARCHAR (30) not null, 
FchNacEmp DATE not null, 
SueldoEmp INT not null, 
TipoEmp CHAR(1) not null CHECK(TipoEmp IN('T' ,'C')) 
)
--Los empleados pueden ser de dos tipos, técnicos “T” o controllers “C”, si son técnicos
--participan en la reparación de equipos, si son controllers son los que hacen el control de
--calidad de las reparaciones (QA).
go

CREATE TABLE Producto (
IdProd INT IDENTITY PRIMARY KEY not null, 
Dscprod VARCHAR(30) not null, 
StkProd INT,
CostoProd INT 
)
--Cada producto tiene un identificador autonumérico y siempre se conoce tanto su descripción,
--el stock y el costo de los mismos.
GO

CREATE TABLE Unidad (
NumSerie CHAR(10) NOT NULL,
IdProd INT NOT NULL,
FchFab DATE,
FchVhasta DATE,
CONSTRAINT pk_Unidad PRIMARY KEY (NumSerie,IdProd),
CONSTRAINT fk_ProdUnidad FOREIGN KEY (IdProd) REFERENCES Producto(IdProd)
);



--Son las unidades de cada producto, están identificadas con un número de serie dependiente
--del producto,también se conoce la fecha de fabricación y la fecha de vencimiento del
--producto.
GO



CREATE TABLE Repara(
IdRepara INT IDENTITY PRIMARY KEY not null, 
NumSerie CHARACTER (10) not null, 
IdProd INT not null, 
IdEmp INT not null, 
FchRepara DATETIME not null, 
CostoRepara INT,
StsRepara VARCHAR (20) Default 'Iniciado',
IdEmpQA INT,--No se puede check si empqa es C o T
CONSTRAINT UK_Repara UNIQUE (NumSerie,IdProd,IdEmp,FchRepara),
CONSTRAINT CK_StsRepara check(StsRepara in ('Iniciado','En testing','Terminado','Cancelado')),
CONSTRAINT FK_UnidadRepara FOREIGN KEY (NumSerie,IdProd) REFERENCES Unidad(NumSerie,IdProd),
CONSTRAINT FK_EmpleadoRepara FOREIGN KEY (IdEmp) REFERENCES Empleado (IdEmp),
CONSTRAINT FK_EmpleadoQA FOREIGN KEY (IdEmpQA) REFERENCES Empleado(IdEmp),
)


CREATE TABLE HistoricoReparacion (
IdHist INT IDENTITY PRIMARY KEY,
IdRepara INT NOT NULL,
NumSerie CHAR(10) NOT NULL,
IdProd INT NOT NULL,
EstadoAnterior VARCHAR(20) NOT NULL,
EstadoNuevo VARCHAR(20) NOT NULL,
FchCambio DATETIME DEFAULT GETDATE());


CREATE TABLE HistoricoEliminacionReparaciones (
IdHist INT IDENTITY PRIMARY KEY,
IdRepara INT NOT NULL,
NumSerie CHAR(10) NOT NULL,
IdProd INT NOT NULL,
StsRepara VARCHAR(20) NOT NULL,
FchEliminacion DATETIME DEFAULT GETDATE()
);

INSERT INTO Empleado (NomEmp, FchNacEmp, SueldoEmp, TipoEmp)
VALUES 
( 'Lucia', '1990-03-15', 22000, 'T'),
( 'Carlos', '1987-07-20', 21000, 'C'),
( 'Mateo', '1992-01-10', 23000, 'T'),
( 'Laura', '1989-11-05', 25000, 'C'),
( 'Sofia', '1991-06-30', 24000, 'T'),
( 'Andres', '1986-09-12', 20000, 'C');



INSERT INTO Producto (Dscprod, StkProd, CostoProd)
VALUES 
('ProductoA', 12, 120),
('ProductoB', 18, 180),
('ProductoC', 25, 250),
('ProductoD', 8, 80),
('ProductoE', 14, 140),
('ProductoF', 20, 200);



--Son las unidades de cada producto, están identificadas con un número de serie dependiente
--del producto,también se conoce la fecha de fabricación y la fecha de vencimiento del
--producto.
GO
INSERT INTO Unidad (NumSerie, IdProd, FchFab, FchVhasta) VALUES
('SN00000001', 1, '2022-01-10', '2025-01-10'),
('SN00000002', 2, '2022-02-15', '2025-02-15'),
('SN00000003', 3, '2021-06-01', '2024-06-01'),
('SN00000004', 4, '2023-03-20', '2026-03-20'),
('SN00000005', 5, '2020-11-11', '2023-11-11'),
('SN00000006', 6, '2022-12-05', '2025-12-05');


INSERT INTO Repara (NumSerie, IdProd, IdEmp, FchRepara, CostoRepara, IdEmpQA)
VALUES 
('SN00000001', 1, 1, '2023-01-15', 300, 2),
('SN00000002', 2, 1, '2023-02-20', 190, 2),
('SN00000003', 3, 1, '2023-03-25', 310, 2),
('SN00000004', 4, 1, '2023-04-10', 150, 2),
('SN00000005', 5, 1, '2023-05-05', 330, NULL), -- Sin QA
('SN00000002', 2, 1, '2023-06-01', 190, 2),
('SN00000006', 6, 1, '2023-06-01', 100, 2);


