--Repositorio github https://github.com/noraraal/SIMM_Practica1.git
--Ejercicio 1
-- 1. Tipos básicos
CREATE OR REPLACE TYPE Telefon_Type AS OBJECT (
    tipus VARCHAR2(20),
    numero VARCHAR2(15)
);
/

-- 2. Tipo cliente con VARRAY
CREATE OR REPLACE TYPE Client_Type AS OBJECT (
    codi NUMBER,
    nom VARCHAR2(50),
    adreça VARCHAR2(100),
    vec_telefon VARRAY(3) OF Telefon_Type,
    correu VARCHAR2(100)
);
/

-- 3. Tipos para comandas
CREATE OR REPLACE TYPE Producte_Type AS OBJECT (
    codi NUMBER,
    nom VARCHAR2(50),
    descripcio VARCHAR2(200),
    preu NUMBER(10,2)
);
/

CREATE OR REPLACE TYPE Linia_Type AS OBJECT (
    codi NUMBER,
    ref_producte REF Producte_Type,
    unitats NUMBER,
    MEMBER FUNCTION import_linia RETURN NUMBER
);
/

CREATE OR REPLACE TYPE TaulaLinies_Type AS TABLE OF Linia_Type;
/

CREATE OR REPLACE TYPE Comanda_Type AS OBJECT (
    codi NUMBER,
    data DATE,
    ref_client REF Client_Type,
    taula_linies TaulaLinies_Type,
    MEMBER FUNCTION import_total RETURN NUMBER
);
/

-- Implementación de métodos
CREATE OR REPLACE TYPE BODY Linia_Type AS
    MEMBER FUNCTION import_linia RETURN NUMBER IS
        v_preu NUMBER;
    BEGIN
        SELECT p.preu INTO v_preu 
        FROM Productes p 
        WHERE REF(p) = SELF.ref_producte;
        RETURN v_preu * SELF.unitats;
    END;
END;
/

CREATE OR REPLACE TYPE BODY Comanda_Type AS
    MEMBER FUNCTION import_total RETURN NUMBER IS
        total NUMBER := 0;
    BEGIN
        FOR i IN 1..SELF.taula_linies.COUNT LOOP
            total := total + SELF.taula_linies(i).import_linia();
        END LOOP;
        RETURN total;
    END;
END;
/

--Ejercicio 2
-- Jerarquía Persona
CREATE OR REPLACE TYPE Persona_Type AS OBJECT (
    codi NUMBER,
    dni VARCHAR2(9),
    nom VARCHAR2(50),
    adreça VARCHAR2(100),
    telefon VARCHAR2(15),
    NOT FINAL
) NOT FINAL;
/

-- Subtipos
CREATE OR REPLACE TYPE Empleat_Type UNDER Persona_Type (
    sou NUMBER,
    data_contracte DATE,
    telefon_feina VARCHAR2(15),
    lloc_treball VARCHAR2(50),
    MEMBER FUNCTION antiguitat RETURN NUMBER
);
/

CREATE OR REPLACE TYPE Estudiant_Type UNDER Persona_Type (
    num_est VARCHAR2(10),
    correu VARCHAR2(100),
    data_naixement DATE,
    MEMBER FUNCTION edat RETURN NUMBER
);
/

-- Subtipos de Empleat
CREATE OR REPLACE TYPE Professor_Type UNDER Empleat_Type (
    titulacions VARCHAR2(200),
    docencia VARCHAR2(100),
    MEMBER FUNCTION triennis RETURN NUMBER
);
/

CREATE OR REPLACE TYPE PAS_Type UNDER Empleat_Type (
    feina VARCHAR2(50),
    tipus_contracte VARCHAR2(20),
    MEMBER FUNCTION sou_anual RETURN NUMBER
);
/

-- Subtipos de Estudiant
CREATE OR REPLACE TYPE Est_grau_Type UNDER Estudiant_Type (
    titulacio VARCHAR2(50),
    durada NUMBER,
    any_1a_matricula NUMBER,
    CONSTRUCTOR FUNCTION Est_grau_Type RETURN SELF AS RESULT
);
/

CREATE OR REPLACE TYPE Est_cicles_Type UNDER Estudiant_Type (
    nivell VARCHAR2(20),
    cicle VARCHAR2(50),
    curs NUMBER,
    MEMBER FUNCTION descripcio RETURN VARCHAR2,
    CONSTRUCTOR FUNCTION Est_cicles_Type RETURN SELF AS RESULT
);
/

--Ejercicio 3
-- 1. Eliminación segura de todos los objetos en orden inverso para evitar conflictos
BEGIN
    FOR obj IN (SELECT object_name, object_type 
                FROM user_objects 
                WHERE object_type IN ('TABLE','TYPE') 
                ORDER BY object_type DESC, object_name DESC) 
    LOOP
        BEGIN
            EXECUTE IMMEDIATE 
                CASE obj.object_type
                    WHEN 'TABLE' THEN 'DROP TABLE ' || obj.object_name || ' CASCADE CONSTRAINTS'
                    WHEN 'TYPE' THEN 'DROP TYPE ' || obj.object_name || ' FORCE'
                END;
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

-- 2. Definición de tipos
CREATE OR REPLACE TYPE Client_Type AS OBJECT (
    nif VARCHAR2(9),
    nom VARCHAR2(25),
    cognoms VARCHAR2(50),
    adreça VARCHAR2(100),
    telefon NUMBER(9),
    MEMBER FUNCTION contarProj RETURN NUMBER
) NOT FINAL;
/

CREATE OR REPLACE TYPE Empleat_Type AS OBJECT (
    dni VARCHAR2(9),
    nom VARCHAR2(25),
    cognoms VARCHAR2(50),
    adreça VARCHAR2(100),
    telefon NUMBER(9),
    dataContracte DATE,
    MEMBER FUNCTION calcularAntiguitat RETURN NUMBER,
    MEMBER FUNCTION contarProjDir RETURN NUMBER,
    MEMBER FUNCTION contarProjTreballa RETURN NUMBER
) NOT FINAL;
/

-- Subtipos con sintaxis
CREATE OR REPLACE TYPE Analista_Type UNDER Empleat_Type (
    dataInici DATE,
    despatx VARCHAR2(10)
);
/

CREATE OR REPLACE TYPE Programador_Type UNDER Empleat_Type (
    llenguatge VARCHAR2(40)
);
/

CREATE OR REPLACE TYPE Tecnic_Type UNDER Empleat_Type (
    titolAcad VARCHAR2(40)
);
/

CREATE OR REPLACE TYPE Projecte_Type AS OBJECT (
    idProjecte NUMBER(6),
    nom VARCHAR2(50),
    descripcio VARCHAR2(100),
    director REF Empleat_Type,
    cliente REF Client_Type,
    MEMBER FUNCTION obtenerDirector RETURN VARCHAR2,
    MEMBER FUNCTION faseActual RETURN VARCHAR2
);
/

-- Resto de tipos
CREATE OR REPLACE TYPE Dirigeix_Type AS OBJECT (
    projecte REF Projecte_Type,
    empleat REF Empleat_Type
);
/

CREATE OR REPLACE TYPE Treballa_Type AS OBJECT (
    projecte REF Projecte_Type,
    empleat REF Empleat_Type
);
/

CREATE OR REPLACE TYPE Fase_Type AS OBJECT (
    idFase NUMBER(2),
    nom VARCHAR2(30),
    tipus VARCHAR2(30)
);
/

CREATE OR REPLACE TYPE ProjDesenv_Type AS OBJECT (
    dataInici DATE,
    dataPrevistaFi DATE,
    dataProvisoriaFi DATE
);
/

CREATE OR REPLACE TYPE ProjEstudi_Type AS OBJECT (
    preu NUMBER(8,2),
    termini NUMBER(3)
);
/

CREATE OR REPLACE TYPE FasesProj_Type AS OBJECT (
    dataInici DATE,
    dataFi DATE,
    fase REF Fase_Type
);
/

-- 3. Creación de tablas
CREATE TABLE Clients OF Client_Type (
    nif PRIMARY KEY
);

CREATE TABLE Empleats OF Empleat_Type (
    dni PRIMARY KEY
);

CREATE TABLE Analistes OF Analista_Type;
CREATE TABLE Programadors OF Programador_Type;
CREATE TABLE Tecnics OF Tecnic_Type;

CREATE TABLE Projectes OF Projecte_Type (
    idProjecte PRIMARY KEY
);

CREATE TABLE Dirigeix OF Dirigeix_Type;
CREATE TABLE Treballa OF Treballa_Type;
CREATE TABLE Fases OF Fase_Type (
    idFase PRIMARY KEY
);

CREATE TABLE ProjDesenv OF ProjDesenv_Type;
CREATE TABLE ProjEstudi OF ProjEstudi_Type;
CREATE TABLE FasesProj OF FasesProj_Type;

-- 4. Implementación de cuerpos de tipo
CREATE OR REPLACE TYPE BODY Client_Type AS
    MEMBER FUNCTION contarProj RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count 
        FROM Projectes p
        WHERE p.cliente.nif = SELF.nif;
        RETURN v_count;
    END;
END;
/

CREATE OR REPLACE TYPE BODY Empleat_Type AS
    MEMBER FUNCTION calcularAntiguitat RETURN NUMBER IS
    BEGIN
        RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, dataContracte)/12);
    END;

    MEMBER FUNCTION contarProjDir RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count 
        FROM Projectes p
        WHERE p.director.dni = SELF.dni;
        RETURN v_count;
    END;

    MEMBER FUNCTION contarProjTreballa RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count 
        FROM Treballa t
        WHERE t.empleat.dni = SELF.dni;
        RETURN v_count;
    END;
END;
/

CREATE OR REPLACE TYPE BODY Projecte_Type AS
    MEMBER FUNCTION obtenerDirector RETURN VARCHAR2 IS
        v_nom VARCHAR2(100);
        emp_ref REF Empleat_Type;
    BEGIN
        emp_ref := SELF.director;
        SELECT e.nom || ' ' || e.cognoms INTO v_nom
        FROM Empleats e
        WHERE REF(e) = emp_ref;
        RETURN v_nom;
    END;

    MEMBER FUNCTION faseActual RETURN VARCHAR2 IS
        v_fase VARCHAR2(30);
    BEGIN
        SELECT f.nom INTO v_fase
        FROM FasesProj fp, Fases f
        WHERE fp.fase = REF(f)
        AND fp.dataFi IS NULL;
        RETURN v_fase;
    END;
END;
/