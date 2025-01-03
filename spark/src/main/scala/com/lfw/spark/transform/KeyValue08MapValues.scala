package com.lfw.spark.transform

import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

object KeyValue08MapValues {
  def main(args: Array[String]): Unit = {
    //1.创建SparkConf并设置App名称
    val conf: SparkConf = new SparkConf().setAppName("MapValues").setMaster("local[*]")
    //2.创建SparkContext，该对象是提交Spark App的入口
    val sc: SparkContext = new SparkContext(conf)

    //3具体业务逻辑
    //3.1 创建第一个RDD
    val rdd: RDD[(Int, String)] = sc.makeRDD(Array((1, "a"), (1, "d"), (2, "b"), (3, "c")))
    //3.2 对value添加字符串"|||"
    rdd.mapValues(_ + "|||").collect().foreach(println)
//    (1,a|||)
//    (1,d|||)
//    (2,b|||)
//    (3,c|||)

    //4.关闭连接
    sc.stop()
  }
}
