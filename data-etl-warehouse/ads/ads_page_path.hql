-- DROP TABLE IF EXISTS ads.ads_page_path;
CREATE EXTERNAL TABLE if not exists ads.ads_page_path
(
    `dt`          STRING COMMENT '统计日期',
    `source`      STRING COMMENT '跳转起始页面ID',
    `target`      STRING COMMENT '跳转终到页面ID',
    `path_count`  BIGINT COMMENT '跳转次数'
) COMMENT '页面浏览路径分析'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/ads/ads_page_path/';


insert overwrite table ads.ads_page_path
select * from ads.ads_page_path
union
select
    '${hiveconf:etl_date}' dt,
    source,
    nvl(target,'null'),
    count(*) path_count
from
(
    select
        concat('step-',rn,':',page_id) source,
        concat('step-',rn+1,':',next_page_id) target
    from
    (
        select
            page_id,
            lead(page_id,1,null) over(partition by session_id order by view_time) next_page_id,
            row_number() over (partition by session_id order by view_time) rn
        from dwd.dwd_traffic_page_view_inc
        where dt='${hiveconf:etl_date}'
    )t1
)t2
group by source,target;