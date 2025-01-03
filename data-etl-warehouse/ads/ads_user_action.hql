-- DROP TABLE IF EXISTS ads.ads_user_action;
CREATE EXTERNAL TABLE if not exists ads.ads_user_action
(
    `dt`                STRING COMMENT '统计日期',
    `home_count`        BIGINT COMMENT '浏览首页人数',
    `good_detail_count` BIGINT COMMENT '浏览商品详情页人数',
    `cart_count`        BIGINT COMMENT '加入购物车人数',
    `order_count`       BIGINT COMMENT '下单人数',
    `payment_count`     BIGINT COMMENT '支付人数'
) COMMENT '漏斗分析'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_user_action/';



insert overwrite table ads.ads_user_action
select * from ads.ads_user_action
union
select
    '${hiveconf:etl_date}' dt,
    home_count,
    good_detail_count,
    cart_count,
    order_count,
    payment_count
from
(
    select
        1 recent_days,
        sum(if(page_id = 'home', 1, 0))        home_count,
        sum(if(page_id = 'good_detail', 1, 0)) good_detail_count
    from dws.dws_traffic_page_visitor_page_view_1d
    where dt='${hiveconf:etl_date}'
      and page_id in ('home','good_detail')
)page
join
(
    select
        1 recent_days,
        count(*) cart_count
    from dws.dws_trade_user_cart_add_1d
    where dt='${hiveconf:etl_date}'
)cart
on page.recent_days=cart.recent_days
join
(
    select
        1 recent_days,
        count(*) order_count
    from dws.dws_trade_user_order_1d
    where dt='${hiveconf:etl_date}'
)ord
on page.recent_days=ord.recent_days
join
(
    select
        1 recent_days,
        count(*) payment_count
    from dws.dws_trade_user_payment_1d
    where dt='${hiveconf:etl_date}'
)pay
on page.recent_days=pay.recent_days;

