-- =====================================================================
-- HoodHead - Migración 001: esquema inicial
-- Base de datos: PostgreSQL 18 | Codificación: UTF8
-- Ejecutar con el usuario de la aplicación (dueño de la base):
--   psql -U hoodhead_app -h localhost -d hoodhead -f 001_initial_schema.sql
-- Este archivo NO contiene contraseñas ni datos sensibles.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- Categorías (origen: hoja CATEGORIAS)
-- ---------------------------------------------------------------------
CREATE TABLE categories (
    id        integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name      text    NOT NULL UNIQUE,
    is_active boolean NOT NULL DEFAULT true
);

-- ---------------------------------------------------------------------
-- Modelos (origen: hoja PRODUCTOS). Una fila por ID_MODELO.
-- unit_cost y unit_price admiten NULL: hay modelos todavía sin cargar.
-- ---------------------------------------------------------------------
CREATE TABLE products (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code        text    NOT NULL UNIQUE,               -- ej. 'MOD-001'
    name        text    NOT NULL,
    category_id integer REFERENCES categories (id),
    color       text,
    unit_cost   numeric(12,2) CHECK (unit_cost  >= 0),
    unit_price  numeric(12,2) CHECK (unit_price >= 0),
    image_url   text,
    is_active   boolean NOT NULL DEFAULT true,
    notes       text
);

-- ---------------------------------------------------------------------
-- Medios de pago
-- ---------------------------------------------------------------------
CREATE TABLE payment_methods (
    id        integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name      text    NOT NULL UNIQUE,
    is_active boolean NOT NULL DEFAULT true
);

INSERT INTO payment_methods (name)
VALUES ('EFECTIVO'), ('DEBITO'), ('MERCADO_PAGO');

-- ---------------------------------------------------------------------
-- Ventas: cabecera (origen: hoja VENTAS)
-- ---------------------------------------------------------------------
CREATE TABLE sales (
    id                bigint  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sold_on           date    NOT NULL,
    payment_method_id integer NOT NULL REFERENCES payment_methods (id),
    notes             text,
    created_at        timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Ventas: renglones. Precio y costo quedan congelados al momento de vender,
-- para que cambiar el precio de un modelo no reescriba el historial.
-- ---------------------------------------------------------------------
CREATE TABLE sale_items (
    id         bigint  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id    bigint  NOT NULL REFERENCES sales (id),
    product_id integer NOT NULL REFERENCES products (id),
    quantity   integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(12,2) NOT NULL CHECK (unit_price >= 0),
    unit_cost  numeric(12,2) NOT NULL CHECK (unit_cost  >= 0),
    line_total numeric(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    line_cost  numeric(12,2) GENERATED ALWAYS AS (quantity * unit_cost)  STORED
);

-- ---------------------------------------------------------------------
-- Movimientos de stock (reemplaza el cálculo de la hoja STOCK).
-- quantity lleva signo: positivo = entra mercadería, negativo = sale.
-- ---------------------------------------------------------------------
CREATE TABLE stock_movements (
    id            bigint  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id    integer NOT NULL REFERENCES products (id),
    movement_type text    NOT NULL
                  CHECK (movement_type IN ('INITIAL', 'PURCHASE', 'SALE', 'ADJUSTMENT')),
    quantity      integer NOT NULL CHECK (quantity <> 0),
    occurred_on   date    NOT NULL,
    sale_item_id  bigint  REFERENCES sale_items (id),
    notes         text
);

-- ---------------------------------------------------------------------
-- Gastos (origen: hoja GASTOS)
-- ---------------------------------------------------------------------
CREATE TABLE expenses (
    id                bigint  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    spent_on          date    NOT NULL,
    expense_type      text    NOT NULL,
    description       text,
    amount            numeric(12,2) NOT NULL CHECK (amount > 0),
    payment_method_id integer REFERENCES payment_methods (id),
    supplier          text,
    receipt           text,
    notes             text
);

-- ---------------------------------------------------------------------
-- Índices: PostgreSQL no los crea solo para las claves foráneas.
-- Aceleran las búsquedas más comunes (ventas por fecha, stock por modelo).
-- ---------------------------------------------------------------------
CREATE INDEX idx_products_category     ON products (category_id);
CREATE INDEX idx_sales_sold_on         ON sales (sold_on);
CREATE INDEX idx_sale_items_sale       ON sale_items (sale_id);
CREATE INDEX idx_sale_items_product    ON sale_items (product_id);
CREATE INDEX idx_stock_mov_product     ON stock_movements (product_id);
CREATE INDEX idx_expenses_spent_on     ON expenses (spent_on);

-- ---------------------------------------------------------------------
-- Vista: stock actual por modelo = suma de sus movimientos
-- ---------------------------------------------------------------------
CREATE VIEW product_stock AS
SELECT p.id,
       p.code,
       p.name,
       COALESCE(SUM(m.quantity), 0) AS current_stock
FROM products p
LEFT JOIN stock_movements m ON m.product_id = p.id
GROUP BY p.id, p.code, p.name;

COMMIT;
