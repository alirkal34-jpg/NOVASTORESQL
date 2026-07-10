-- ================================================================
-- NovaStore E-Ticaret Veri Yonetim Sistemi
-- Teslim SQL Dosyasi
-- Dosya: AliRikal_NovaStore_Proje.sql
-- Platform: Microsoft SQL Server
-- ================================================================

-- BOLUM 1: Veri tabani tasarimi (DDL)

USE master;
GO

IF DB_ID('NovaStoreDB') IS NOT NULL
BEGIN
    ALTER DATABASE NovaStoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NovaStoreDB;
END;
GO

CREATE DATABASE NovaStoreDB
COLLATE Turkish_CI_AS;
GO

USE NovaStoreDB;
GO

-- Tablo: Categories
CREATE TABLE dbo.Categories
(
    CategoryID   INT IDENTITY(1,1) NOT NULL,
    CategoryName VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID)
);
GO

-- Tablo: Customers
CREATE TABLE dbo.Customers
(
    CustomerID INT IDENTITY(1,1) NOT NULL,
    FullName   VARCHAR(50) NOT NULL,
    City       VARCHAR(20) NOT NULL,
    Email      VARCHAR(100) NOT NULL,

    CONSTRAINT PK_Customers PRIMARY KEY (CustomerID),
    CONSTRAINT UQ_Customers_Email UNIQUE (Email)
);
GO

-- Tablo: Products
CREATE TABLE dbo.Products
(
    ProductID   INT IDENTITY(1,1) NOT NULL,
    ProductName VARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL,
    Stock       INT NOT NULL
        CONSTRAINT DF_Products_Stock DEFAULT (0),
    CategoryID  INT NOT NULL,

    CONSTRAINT PK_Products PRIMARY KEY (ProductID),
    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES dbo.Categories(CategoryID),
    CONSTRAINT CK_Products_Price
        CHECK (Price >= 0),
    CONSTRAINT CK_Products_Stock
        CHECK (Stock >= 0)
);
GO

-- Tablo: Orders
CREATE TABLE dbo.Orders
(
    OrderID     INT IDENTITY(1,1) NOT NULL,
    CustomerID  INT NOT NULL,
    OrderDate   DATETIME NOT NULL
        CONSTRAINT DF_Orders_OrderDate DEFAULT (GETDATE()),
    TotalAmount DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Orders PRIMARY KEY (OrderID),
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers(CustomerID),
    CONSTRAINT CK_Orders_TotalAmount
        CHECK (TotalAmount >= 0)
);
GO

-- Tablo: OrderDetails
CREATE TABLE dbo.OrderDetails
(
    DetailID  INT IDENTITY(1,1) NOT NULL,
    OrderID   INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity  INT NOT NULL,

    CONSTRAINT PK_OrderDetails PRIMARY KEY (DetailID),
    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY (OrderID)
        REFERENCES dbo.Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY (ProductID)
        REFERENCES dbo.Products(ProductID),
    CONSTRAINT CK_OrderDetails_Quantity
        CHECK (Quantity > 0)
);
GO

-- BOLUM 2: Veri girisi (DML - INSERT)

-- Gorev 1: 5 adet kategori ekleme
INSERT INTO dbo.Categories (CategoryName)
VALUES
    ('Elektronik'),
    ('Giyim'),
    ('Kitap'),
    ('Kozmetik'),
    ('Ev ve Yasam');
GO

-- Gorev 2: Her kategoriye ait toplam 12 urun ekleme
INSERT INTO dbo.Products (ProductName, Price, Stock, CategoryID)
VALUES
    ('Oyuncu Laptop',          35000.00,  15, 1),
    ('Akilli Telefon',         22000.00,  25, 1),
    ('Klasik Deri Ceket',       2500.00,  40, 2),
    ('Pamuklu Tisort',           450.00, 100, 2),
    ('Spor Ayakkabi',           1800.00,  12, 2),
    ('SQL Ogreniyorum Kitabi',    350.00,   8, 3),
    ('Veri Bilimi Rehberi',       420.00,  12, 3),
    ('Nemlendirici Krem',         180.00,  50, 4),
    ('Parfum EDP',              1200.00,  18, 4),
    ('Calisma Masasi',          2100.00,   5, 5),
    ('Ortopedik Yastik',         650.00,  30, 5),
    ('Filtre Kahve Makinesi',   3200.00,  22, 5);
GO

-- Gorev 3: 6 adet musteri kaydi olusturma
INSERT INTO dbo.Customers (FullName, City, Email)
VALUES
    ('Ahmet Yilmaz',  'Istanbul',  'ahmet.yilmaz@novastore.test'),
    ('Mehmet Ozturk', 'Ankara',    'mehmet.ozturk@novastore.test'),
    ('Ayse Demir',    'Izmir',     'ayse.demir@novastore.test'),
    ('Canan Kaya',    'Bursa',     'canan.kaya@novastore.test'),
    ('Ali Can',       'Antalya',   'ali.can@novastore.test'),
    ('Zeynep Sahin',  'Eskisehir', 'zeynep.sahin@novastore.test');
GO

-- Gorev 4: Farkli tarihlerde yapilmis 10 siparis ekleme
INSERT INTO dbo.Orders (CustomerID, OrderDate, TotalAmount)
VALUES
    (1, '2026-06-01T10:00:00', 35350.00),
    (1, '2026-06-15T14:30:00',   900.00),
    (2, '2026-05-20T11:15:00', 22000.00),
    (3, '2026-06-10T09:00:00',  4300.00),
    (4, '2026-04-01T16:45:00',  1380.00),
    (5, '2026-06-22T18:20:00',  2750.00),
    (2, '2026-06-23T12:00:00',   840.00),
    (3, '2026-06-24T15:00:00',  1200.00),
    (6, '2026-06-25T13:30:00',  3200.00),
    (6, '2026-06-26T17:10:00',  4050.00);
GO

-- Gorev 4: Siparislere ait detay kayitlari ekleme
INSERT INTO dbo.OrderDetails (OrderID, ProductID, Quantity)
VALUES
    (1, 1, 1),
    (1, 6, 1),
    (2, 4, 2),
    (3, 2, 1),
    (4, 3, 1),
    (4, 5, 1),
    (5, 8, 1),
    (5, 9, 1),
    (6, 10, 1),
    (6, 11, 1),
    (7, 7, 2),
    (8, 9, 1),
    (9, 12, 1),
    (10, 5, 2),
    (10, 4, 1);
GO

-- BOLUM 3: Sorgulama ve analiz (DQL)

-- Sorgu 1: Stok miktari 20'den az olan urunleri stok miktarina gore azalan sirada listeleme
SELECT
    ProductName,
    Stock
FROM dbo.Products
WHERE Stock < 20
ORDER BY
    Stock DESC,
    ProductName ASC;
GO

-- Sorgu 2: Hangi musteri hangi tarihte siparis vermis?
SELECT
    c.FullName,
    c.City,
    o.OrderDate,
    o.TotalAmount
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID
ORDER BY
    o.OrderDate ASC;
GO

-- Sorgu 3: Ahmet Yilmaz isimli musterinin aldigi urunler, fiyatlar ve kategoriler
SELECT
    p.ProductName,
    p.Price,
    cat.CategoryName
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID
INNER JOIN dbo.OrderDetails AS od
    ON o.OrderID = od.OrderID
INNER JOIN dbo.Products AS p
    ON od.ProductID = p.ProductID
INNER JOIN dbo.Categories AS cat
    ON p.CategoryID = cat.CategoryID
WHERE c.FullName = 'Ahmet Yilmaz'
ORDER BY
    o.OrderDate ASC,
    p.ProductName ASC;
GO

-- Sorgu 4: Kategorilere gore toplam urun sayisi
SELECT
    cat.CategoryName,
    COUNT(p.ProductID) AS ProductCount
FROM dbo.Categories AS cat
LEFT JOIN dbo.Products AS p
    ON cat.CategoryID = p.CategoryID
GROUP BY
    cat.CategoryID,
    cat.CategoryName
ORDER BY
    cat.CategoryID ASC;
GO

-- Sorgu 5: Her musterinin toplam cirosu, en cok harcama yapandan en aza
SELECT
    c.CustomerID,
    c.FullName,
    COALESCE(SUM(o.TotalAmount), 0.00) AS TotalRevenue
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.FullName
ORDER BY
    TotalRevenue DESC,
    c.FullName ASC;
GO

-- Sorgu 6: Siparislerin bugune gore uzerinden gecen gun sayisi
SELECT
    OrderID,
    OrderDate,
    DATEDIFF(DAY, OrderDate, GETDATE()) AS DaysSinceOrder
FROM dbo.Orders
ORDER BY
    DaysSinceOrder DESC,
    OrderID ASC;
GO

-- Ek kontrol: Kaydedilen siparis toplam tutarlari ile detaylardan hesaplanan tutarlar esit mi?
SELECT
    o.OrderID,
    o.TotalAmount AS RecordedTotalAmount,
    SUM(p.Price * od.Quantity) AS CalculatedTotalAmount,
    o.TotalAmount - SUM(p.Price * od.Quantity) AS Difference
FROM dbo.Orders AS o
INNER JOIN dbo.OrderDetails AS od
    ON o.OrderID = od.OrderID
INNER JOIN dbo.Products AS p
    ON od.ProductID = p.ProductID
GROUP BY
    o.OrderID,
    o.TotalAmount
ORDER BY
    o.OrderID ASC;
GO

-- Ek subquery ornegi: Ortalama siparis tutarinin uzerindeki siparisler
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount
FROM dbo.Orders
WHERE TotalAmount > (SELECT AVG(TotalAmount) FROM dbo.Orders)
ORDER BY
    TotalAmount DESC;
GO

-- BOLUM 4: Ileri seviye veri tabani nesneleri

-- View: Musteri adi, siparis tarihi, urun adi ve adet bilgisini tek gorunumde toplama
CREATE VIEW dbo.vw_SiparisOzet
AS
SELECT
    c.FullName,
    o.OrderDate,
    p.ProductName,
    od.Quantity
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID
INNER JOIN dbo.OrderDetails AS od
    ON o.OrderID = od.OrderID
INNER JOIN dbo.Products AS p
    ON od.ProductID = p.ProductID;
GO

-- View sonucunu test etme
SELECT
    FullName,
    OrderDate,
    ProductName,
    Quantity
FROM dbo.vw_SiparisOzet
ORDER BY
    OrderDate ASC,
    FullName ASC,
    ProductName ASC;
GO

-- Yedekleme: C:\Yedek klasorunun SQL Server tarafindan erisilebilir oldugundan emin olun.
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak'
WITH
    INIT,
    NAME = 'NovaStoreDB Full Backup',
    STATS = 10;
GO
