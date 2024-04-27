-- DROP TABLE IF EXISTS ads.ads_repeat_purchase_by_tm;
CREATE EXTERNAL TABLE if not exists ads.ads_repeat_purchase_by_tm
(
    `dt`                STRING COMMENT '统计日期',
    `recent_days`       BIGINT COMMENT '最近天数,30:最近30天',
    `tm_id`             STRING COMMENT '品牌ID',
    `tm_name`           STRING COMMENT '品牌名称',
    `order_repeat_rate` DECIMAL(16, 2) COMMENT '复购率'
) COMMENT '最近30日各品牌复购率统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_repeat_purchase_by_tm/';



insert overwrite table ads.ads_repeat_purchase_by_tm
select * from ads.ads_repeat_purchase_by_tm
union
select
    '${hiveconf:etl_date}',
    30,
    tm_id,
    tm_name,
    cast(sum(if(order_count >= 2, 1, 0)) / sum(if(order_count >= 1, 1, 0)) as decimal(16, 2))
from
(
    select
        user_id,
        tm_id,
        tm_name,
        sum(order_count_30d) order_count
    from dws.dws_trade_user_sku_order_nd
    where dt='${hiveconf:etl_date}'
    group by user_id, tm_id, tm_name
)t1
group by tm_id, tm_name;