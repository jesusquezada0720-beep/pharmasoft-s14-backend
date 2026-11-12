-- SOLO DESARROLLO LOCAL. No ejecutar en producción.
-- Requiere las tablas base existentes y al menos una categoría y un cliente activos.
-- Esta carga corresponde al paso 2 de la guía; no ejecutarla hasta completar
-- la revisión del script y confirmar que se usa una base local de desarrollo.
-- Inserta 5 000 productos y 20 000 ventas con un detalle por venta.
-- Ejecutar una sola vez en PHARMADB. El bloque impide duplicar la carga.

SET SERVEROUTPUT ON;

DECLARE
    v_categoria_id productos.id_categoria%TYPE;
    v_cliente_id ventas.cliente_id%TYPE;
    v_producto_id productos.id%TYPE;
    v_precio productos.precio%TYPE;
    v_venta_id ventas.id%TYPE;
    v_existentes NUMBER;
    v_marca VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'YYMMDDHH24MISSFF3');
BEGIN
    SELECT COUNT(*)
      INTO v_existentes
      FROM productos
     WHERE nombre LIKE 'S14-CARGA-%';

    IF v_existentes > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ya hay productos S14-CARGA. No se repite la carga.');
    END IF;

    SELECT MIN(id)
      INTO v_categoria_id
      FROM categorias
     WHERE estado = 1;

    SELECT MIN(id)
      INTO v_cliente_id
      FROM clientes
     WHERE estado = 1;

    IF v_categoria_id IS NULL OR v_cliente_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'Se necesita al menos una categoría y un cliente activo.');
    END IF;

    FOR i IN 1..5000 LOOP
        INSERT INTO productos (
            nombre, precio, stock, estado, id_categoria, fecha_creacion
        ) VALUES (
            'S14-CARGA-' || v_marca || '-' || LPAD(i, 5, '0'),
            10 + MOD(i, 100),
            100,
            1,
            v_categoria_id,
            SYSTIMESTAMP
        );
    END LOOP;

    SELECT id, precio
      INTO v_producto_id, v_precio
      FROM (
          SELECT id, precio
            FROM productos
           WHERE nombre LIKE 'S14-CARGA-' || v_marca || '-%'
           ORDER BY id
      )
     WHERE ROWNUM = 1;

    FOR i IN 1..20000 LOOP
        INSERT INTO ventas (
            fecha, total, estado, cliente_id
        ) VALUES (
            SYSTIMESTAMP - NUMTODSINTERVAL(MOD(i, 8760), 'HOUR'),
            v_precio,
            'REGISTRADA',
            v_cliente_id
        ) RETURNING id INTO v_venta_id;

        INSERT INTO detalle_ventas (
            venta_id, producto_id, cantidad, precio, subtotal
        ) VALUES (
            v_venta_id,
            v_producto_id,
            1,
            v_precio,
            v_precio
        );
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Carga S14 completada: 5 000 productos y 20 000 ventas.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, 'Falta una categoría, un cliente o un producto válido para la carga.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
