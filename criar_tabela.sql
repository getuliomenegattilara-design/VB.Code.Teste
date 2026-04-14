-- Execute este script no SQL Server para criar a tabela Pessoas
CREATE TABLE Pessoas (
    Id            INT           IDENTITY(1,1) PRIMARY KEY,
    Nome          VARCHAR(100)  NOT NULL,
    DataCadastro  DATETIME      NOT NULL DEFAULT GETDATE()
);
