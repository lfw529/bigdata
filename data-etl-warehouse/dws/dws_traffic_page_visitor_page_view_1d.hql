-- DROP TABLE IF EXISTS dws.dws_traffic_page_visitor_page_view_1d;
CREATE EXTERNAL TABLE if not exists dws.dws_traffic_page_visitor_page_view_1d
(
    `mid_id`         STRING COMMENT '访客ID',
    `brand`          string comment '手机品牌',
    `model`          string comment '手机型号',
    `operate_system` string comment '操作系统',
    `page_id`        STRING COMMENT '页面ID',
    `during_time_1d` BIGINT COMMENT '最近1日浏览时长',
    `view_count_1d`  BIGINT COMMENT '最近1日访问次数'
) COMMENT '流量域访客页面粒度页面浏览最近1日汇总表'
PARTITIONED BY (`dt` STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_traffic_page_visitor_page_view_1d'
TBLPROPERTIES ('orc.compress' = 'snappy');


--SQL--
-- ********************************************************************
-- Author: lfw
-- CreateTime: 2023-10-04 18:01:52
-- Comment: dws层-流量域访客页面粒度页面浏览最近1日汇总表
-- ********************************************************************

insert overwrite table dws.dws_traffic_page_visitor_page_view_1d partition(dt='${hiveconf:etl_date}')
select
    mid_id,
    brand,
    model,
    operate_system,
    page_id,
    sum(during_time),
    count(*)
from dwd.dwd_traffic_page_view_inc
where dt='${hiveconf:etl_date}'
group by mid_id,brand,model,operate_system,page_id;