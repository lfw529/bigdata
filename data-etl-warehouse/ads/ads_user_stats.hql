-- DROP TABLE IF EXISTS ads.ads_user_stats;
CREATE EXTERNAL TABLE if not exists ads.ads_user_stats
(
    `dt`                STRING COMMENT '统计日期',
    `recent_days`       BIGINT COMMENT '最近n日,1:最近1日,7:最近7日,30:最近30日',
    `new_user_count`    BIGINT COMMENT '新增用户数',
    `active_user_count` BIGINT COMMENT '活跃用户数'
) COMMENT '用户新增活跃统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_user_stats/';


insert overwrite table ads.ads_user_stats
select * from ads.ads_user_stats
union
select '${hiveconf:etl_date}' dt,
       recent_days,
       sum(if(login_date_first >= date_add('${hiveconf:etl_date}', -recent_days + 1), 1, 0)) new_user_count,
       count(*) active_user_count
from dws.dws_user_user_login_td lateral view explode(array(1, 7, 30)) tmp as recent_days
where dt = '${hiveconf:etl_date}'
  and login_date_last >= date_add('${hiveconf:etl_date}', -recent_days + 1)
group by recent_days;