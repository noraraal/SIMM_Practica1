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

