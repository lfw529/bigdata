-- DROP TABLE IF EXISTS ads.ads_user_retention;
CREATE EXTERNAL TABLE if not exists ads.ads_user_retention
(
    `dt`              STRING COMMENT '统计日期',
    `create_date`     STRING COMMENT '用户新增日期',
    `retention_day`   INT COMMENT '截至当前日期留存天数',
    `retention_count` BIGINT COMMENT '留存用户数量',
    `new_user_count`  BIGINT COMMENT '新增用户数量',
    `retention_rate`  DECIMAL(16, 2) COMMENT '留存率'
) COMMENT '用户留存率'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_user_retention/';



insert overwrite table ads.ads_user_retention
select * from ads.ads_user_retention
union
select
    '${hiveconf:etl_date}' dt,
    login_date_first create_date,
    datediff('${hiveconf:etl_date}', login_date_first) retention_day,
    sum(if(login_date_last = '${hiveconf:etl_date}', 1, 0)) retention_count,
    count(*) new_user_count,
    cast(sum(if(login_date_last = '${hiveconf:etl_date}', 1, 0)) / count(*) * 100 as decimal(16, 2)) retention_rate
from
(
    select user_id,
           login_date_last,
           login_date_first
    from dws.dws_user_user_login_td
    where dt = '${hiveconf:etl_date}'
      and login_date_first >= date_add('${hiveconf:etl_date}', -7)
      and login_date_first < '${hiveconf:etl_date}'
) t1
group by login_date_first;