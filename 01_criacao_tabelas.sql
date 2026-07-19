CREATE DATABASE IF NOT EXISTS teste_intuitive_care
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE teste_intuitive_care;

CREATE TABLE stg_operadoras (
    registro_operadora VARCHAR(20),
    cnpj VARCHAR(30),
    razao_social VARCHAR(255),
    nome_fantasia VARCHAR(255),
    modalidade VARCHAR(100),
    logradouro VARCHAR(255),
    numero VARCHAR(50),
    complemento VARCHAR(255),
    bairro VARCHAR(150),
    cidade VARCHAR(150),
    uf VARCHAR(10),
    cep VARCHAR(20),
    ddd VARCHAR(10),
    telefone VARCHAR(30),
    fax VARCHAR(30),
    endereco_eletronico VARCHAR(255),
    representante VARCHAR(255),
    cargo_representante VARCHAR(150),
    regiao_de_comercializacao VARCHAR(50),
    data_registro_ans VARCHAR(50)
);

CREATE TABLE stg_despesas_consolidadas (
    cnpj VARCHAR(30),
    razao_social VARCHAR(255),
    trimestre VARCHAR(50),
    ano VARCHAR(10),
    valor_despesas VARCHAR(50)
);

CREATE TABLE stg_despesas_agregadas (
    razao_social VARCHAR(255),
    registro_ans VARCHAR(20),
    modalidade VARCHAR(100),
    uf VARCHAR(10),
    total_despesas VARCHAR(50),
    media_despesas_trimestre VARCHAR(50),
    desvio_padrao VARCHAR(50)
);

CREATE TABLE operadoras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    registro_ans VARCHAR(10) NOT NULL,
    cnpj CHAR(14) NOT NULL,
    razao_social VARCHAR(255) NOT NULL,
    modalidade VARCHAR(100) NOT NULL,
    uf CHAR(2) NOT NULL,

    CONSTRAINT uk_operadoras_registro_ans
        UNIQUE (registro_ans),

    CONSTRAINT uk_operadoras_cnpj
        UNIQUE (cnpj)
);

CREATE TABLE despesas_consolidadas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    operadora_id INT NOT NULL,
    ano INT NOT NULL,
    trimestre INT NOT NULL,
    valor_despesas DECIMAL(18, 2) NOT NULL,

    CONSTRAINT fk_despesas_operadora
        FOREIGN KEY (operadora_id)
        REFERENCES operadoras(id),

    CONSTRAINT uk_despesa_operadora_periodo
        UNIQUE (operadora_id, ano, trimestre)
);

CREATE TABLE despesas_agregadas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    operadora_id INT NOT NULL,
    total_despesas DECIMAL(18, 2) NOT NULL,
    media_despesas_trimestre DECIMAL(18, 2) NOT NULL,
    desvio_padrao DECIMAL(18, 2) NOT NULL,

    CONSTRAINT fk_agregadas_operadora
        FOREIGN KEY (operadora_id)
        REFERENCES operadoras(id),

    CONSTRAINT uk_agregadas_operadora
        UNIQUE (operadora_id)
);

CREATE INDEX idx_operadoras_uf
    ON operadoras(uf);

CREATE INDEX idx_despesas_periodo
    ON despesas_consolidadas(ano, trimestre);

CREATE INDEX idx_agregadas_total
    ON despesas_agregadas(total_despesas);