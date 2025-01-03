package com.lfw.spark.transform

import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

object DoubleValue03Subtract {
  def main(args: Array[String]): Unit = {
    //1.创建SparkConf并设置App名称
    val conf: SparkConf = new SparkConf().setAppName("Subtract").setMaster("local[*]")
    //2.创建SparkContext，该对象是提交Spark App的入口
    val sc: SparkContext = new SparkContext(conf)
    //3具体业务逻辑
    //3.1 创建第一个RDD
    val rdd: RDD[Int] = sc.makeRDD(1 to 4)
    //3.2 创建第二个RDD
    val rdd1: RDD[Int] = sc.makeRDD(4 to 8)
    //3.3 计算第一个RDD与第二个RDD的差集并打印
    rdd.subtract(rdd1).collect().foreach(println)
    //4.关闭连接
    sc.stop()
  }
}
