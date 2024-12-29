-- Membuat tabel analisa yang menggabungkan data dari transaksi, cabang, dan produk
CREATE OR REPLACE TABLE kimia_farma.kf_analysis AS
SELECT
    trans.transaction_id,
    trans.date,
    trans.branch_id,
    branch.branch_name,
    branch.kota, 
    branch.provinsi,   
    branch.rating AS rating_cabang, 
    trans.customer_name, 
    trans.product_id, 
    prod.product_name, 
    trans.price AS actual_price,
    trans.discount_percentage, 

    -- Menghitung total penjualan setelah diskon
    trans.price * (1 - (trans.discount_percentage / 100)) AS nett_sales,

    -- Menentukan persentase laba berdasarkan harga setelah diskon
    CASE
        WHEN trans.price * (1 - (trans.discount_percentage / 100)) <= 50000 THEN 0.10
        WHEN trans.price * (1 - (trans.discount_percentage / 100)) > 50000 
             AND trans.price * (1 - (trans.discount_percentage / 100)) <= 100000 THEN 0.15
        WHEN trans.price * (1 - (trans.discount_percentage / 100)) > 100000 
             AND trans.price * (1 - (trans.discount_percentage / 100)) <= 300000 THEN 0.20
        WHEN trans.price * (1 - (trans.discount_percentage / 100)) > 300000 
             AND trans.price * (1 - (trans.discount_percentage / 100)) <= 500000 THEN 0.25
        ELSE 0.30
    END AS persentase_gross_laba,

    -- Menghitung keuntungan bersih berdasarkan laba yang seharusnya diterima
    (trans.price * (1 - (trans.discount_percentage / 100)) * 
    CASE
        WHEN trans.price * (1 - (trans.discount_percentage / 100)) <= 50000 THEN 0.10
        WHEN trans.price * (1 - (trans.discount_percentage / 100)) > 50000 
             AND trans.price * (1 - (trans.discount_percentage / 100)) <= 100000 THEN 0.15
        WHEN trans.price * (1 - (trans.discount_percentage / 100)) > 100000 
             AND trans.price * (1 - (trans.discount_percentage / 100)) <= 300000 THEN 0.20
        WHEN trans.price * (1 - (trans.discount_percentage / 100)) > 300000 
             AND trans.price * (1 - (trans.discount_percentage / 100)) <= 500000 THEN 0.25
        ELSE 0.30
    END) AS nett_profit,
    trans.rating AS rating_transaksi 

FROM
    kimia_farma.kf_final_transaction trans 
JOIN
    kimia_farma.kf_kantor_cabang branch ON trans.branch_id = branch.branch_id 
JOIN
    kimia_farma.kf_product prod ON trans.product_id = prod.product_id;