use DeviceRepair

--Aca van todos los index
CREATE INDEX index_Producto ON Unidad(IdProd);

CREATE INDEX index_Unidad ON Repara(NumSerie);
CREATE INDEX index_Producto ON Repara(IdProd);
CREATE INDEX index_EmpleadoRepara ON Repara(IdEmp);
CREATE INDEX index_EmpleadoQA ON Repara(IdEmpQA);



