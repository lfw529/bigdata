-- DROP TABLE IF EXISTS dws.dws_tool_user_coupon_coupon_used_1d;
CREATE EXTERNAL TABLE if not exists dws.dws_tool_user_coupon_coupon_used_1d
(
    `user_id`          STRING COMMENT '用户ID',
    `coupon_id`        STRING COMMENT '优惠券ID',
    `coupon_name`      STRING COMMENT '优惠券名称',
    `coupon_type_code` STRING COMMENT '优惠券类型编码',
    `coupon_type_name` STRING COMMENT '优惠券类型名称',
    `benefit_rule`     STRING COMMENT '优惠规则',
    `used_count_1d`    STRING COMMENT '使用(支付)次数'
) COMMENT '工具域用户优惠券粒度优惠券使用(支付)最近1日汇总表'
PARTITIONED BY (`dt` STRING)
STORED AS ORC
LOCATION '/warehouse/gmall/dws/dws_tool_user_coupon_coupon_used_1d'
TBLPROPERTIES ('orc.compress' = 'snappy');



--SQL--
-- ********************************************************************
-- Author: lfw
-- CreateTime: 2023-10-04 18:01:52
-- Comment: dws层-工具域用户优惠券粒度优惠券使用(支付)最近1日汇总表
-- ********************************************************************

-- 首日装载
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table dws.dws_tool_user_coupon_coupon_used_1d partition(dt)
select
    user_id,
    coupon_id,
    coupon_name,
    coupon_type_code,
    coupon_type_name,
    benefit_rule,
    used_count,
    dt
from
(
    select
        dt,
        user_id,
        coupon_id,
        count(*) used_count
    from dwd.dwd_tool_coupon_used_inc
    group by dt,user_id,coupon_id
)t1
left join
(
    select
        id,
        coupon_name,
        coupon_type_code,
        coupon_type_name,
        benefit_rule
    from dim.dim_coupon_full
    where dt='2022-06-08'
)t2
on t1.coupon_id=t2.id;


-- 每日装载
insert overwrite table dws.dws_tool_user_coupon_coupon_used_1d partition(dt='${hiveconf:etl_date}')
select
    user_id,
    coupon_id,
    coupon_name,
    coupon_type_code,
    coupon_type_name,
    benefit_rule,
    used_count
from
(
    select
        user_id,
        coupon_id,
        count(*) used_count
    from dwd.dwd_tool_coupon_used_inc
    where dt='${hiveconf:etl_date}'
    group by user_id,coupon_id
)t1
left join
(
    select
        id,
        coupon_name,
        coupon_type_code,
        coupon_type_name,
        benefit_rule
    from dim.dim_coupon_full
    where dt='${hiveconf:etl_date}'
)t2
on t1.coupon_id=t2.id;