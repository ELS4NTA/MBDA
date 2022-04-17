/*DANIEL SANTANILLA*/
/*1*/
CREATE TABLE ususarios (idUsuario NUMBER NOT NULL, correo VARCHAR(50) NOT NULL, nombre VARCHAR(100) NOT NULL, foto VARCHAR(100));
CREATE TABLE consultas (fecha DATE NOT NULL, usuarios_id NUMBER NOT NULL, colecciones_recursosDoc_codigo VARCHAR(10) NOT NULL);
CREATE TABLE curadores (usuario_id NUMBER NOT NULL, tipoDocumento VARCHAR(2) NOT NULL, numeroDocumento NUMBER(11) NOT NULL, nivelAcceso NUMBER(1) NOT NULL, recursosAdministrados NUMBER NOT NULL);
CREATE TABLE colecciones (recursosDoc_codigo VARCHAR(10) NOT NULL, nivelDescripcion VARCHAR(2) NOT NULL, recursos NUMBER NOT NULL, url VARCHAR(20) NOT NULL, fechaInicial DATE NOT NULL, fechaFinal DATE NOT NULL);
CREATE TABLE recursosDocumentales (codigo VARCHAR(10) NOT NULL, titulo VARCHAR(100) NOT NULL, fechaCreacion DATE NOT NULL, nivelAcceso NUMBER(1) NOT NULL, estado VARCHAR(9) NOT NULL, curador_id NUMBER NOT NULL, autor_id NOT NULL);
CREATE TABLE autores (usuario_id NUMBER NOT NULL, nacionalidad VARCHAR(3));
CREATE TABLE observaciones (recurso_recursoDoc_codigo VARCHAR(10) NOT NULL, observacion VARCHAR(100), codigoObservacion NUMBER NOT NULL);
CREATE TABLE recursos (recursoDoc_codigo VARCHAR(10) NOT NULL, fechaInicial DATE NOT NULL, fechaFinal DATE NOT NULL, contexto VARCHAR(500) NOT NULL, coleccion_recursoDoc_codigo NOT NULL);
CREATE TABLE anexos (titutlo VARCHAR(100) NOT NULL, fecha DATE NOT NULL, formato VARCHAR(3) NOT NULL, idioma VARCHAR(2) NOT NULL, recurso_recursoDoc_codigo VARCHAR(10) NOT NULL, codigoAnexo NUMBER NOT NULL);
CREATE TABLE etiquetas (sigla VARCHAR(3) NOT NULL, texto VARCHAR(20) NOT NULL, color VARCHAR(7) NOT NULL, curador_usuario_id NUMBER NOT NULL);
CREATE TABLE recursoXUbicaciones (recursoDoc_codigo VARCHAR(10) NOT NULL, ubicacion_longitud NUMBER NOT NULL, ubicaicon_latitud NUMBER NOT NULL);
CREATE TABLE recursoXEtiquetas (recurosoDoc_codigo VARCHAR(10) NOT NULL, etiqueta_sigla VARCHAR(3) NOT NULL);
CREATE TABLE ubicaciones (longitud NUMBER NOT NULL, latitud NUMBER NOT NULL);

/*2*/
CREATE DOMAIN TEstado AS VARCHAR(20)CONSTRAINT CHECK (VALUES IN ('Aceptado', 'Rechazado', 'Pendiente'));
CREATE ASSERTION CK_colecciones_nievelDescripcion CHECK (NOT EXIST(SELECT * FROM colecciones WHERE nivelDescripcion = 'ET' AND url NOT LIKE ('https://archivobogota.%')));
ALTER TABLE recursosDocumentales ADD CONSTRAINT CK_recursosDocumentales_nivelAcceso CHECK (nivelAcceso BETWEEN 1 AND 4);
/*Exclusiva*/
CREATE ASSERTION CK_herencia_exclusiva_coleccion_recurso CHECK (NOT EXIST((SELECT * FROM colecciones) INTERSECT (SELECT * FROM recursos)));
/*completa*/
CREATE ASSERTION CK_herencia_completa_coleccioon_recurso CHECK (EXIST ((SELECT * FROM colecciones) INTERSECT (SELECT * FROM colecciones)));

/*3*/
CREATE TRIGGER TG_COLECCIONES_BI
BEFORE INSERT ON colecciones
FOR EACH ROW 
DECLARE
    actual_date DATE;
    etiquetasAsociadas NUMBER;
    codigo VARCHAR(10);
    año VARCHAR(10);
BEGIN 
    SELECT CURRENT_DATE INTO actual_date FROM DUAL;
    UPDATE recursosDocumentales SET fechaCreacion = actual_date;
    codigo := :new.recursosDoc_codigo;
    SELECT COUNT(sigla)INTO etiquetasAsociadas FROM recursoXEtiquetas JOIN etiquetas ON (etiquetas_sigla = sigla) WHERE recurosoDoc_codigo = codigo;
    IF etiquetasAsociadas > 10 THEN
         RAISE_APPLICATION_ERROR(-20600,'La coleccion puuede tener maximo 10 etiquetas.');
    END IF;
    año := TO_CHAR('actual_date', 'YYYY');
    :new.recursosDoc_codigo := año || _ || 0000);
END;

CREATE TRIGGER TG_COLECCIONES_AI
AFTER INSERT ON colecciones
FOR EACH ROW
BEGIN
    IF nivelDescripcion = 'Desconocido' THEN
        UPDATE colecciones SET nivelDescripcion = 'ET';
    END IF;
END;

CREATE TRIGGER TG_COLECCIONES_BU
BEFORE UPDATE ON colecciones
FOR EACH ROW
BEGIN
    IF :new.recursos != :old.recursos OR :new.url != :old.url OR :new.fechaInicial != :old.fechaInicial THEN
        RAISE_APPLICATION_ERROR(-20601,'No se puede actualizar la coleccion.');
    END IF;
    IF :new.nivelAcceso > :old.nivelAcceso THEN
        RAISE_APPLICATION_ERROR(-20601,'El nivel de acceso no puede aumentar.');
    END IF;
END;
    
