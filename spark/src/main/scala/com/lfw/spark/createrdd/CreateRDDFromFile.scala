package com.lfw.spark.createrdd

import org.apache.hadoop.io.{LongWritable, Text}
import org.apache.hadoop.mapred.lib.CombineFileInputFormat
import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

object CreateRDDFromFile {
  def main(args: Array[String]): Unit = {
    //1.创建SparkConf并设置App名称
    val conf: SparkConf = new SparkConf().setAppName("文件映射RDD").setMaster("local[*]")

    //2.创建SparkContext，该对象是提交Spark App的入口
    val sc: SparkContext = new SparkContext(conf)

    //3.1 加载本地 .txt 文件 --测试1
    val rdd1: RDD[String] = sc.textFile("spark/input/data_battle.txt")

    //3.2 读取文件。如果是集群路径：hdfs://hadoop102:8020/input   --测试2
    val rdd2: RDD[String] = sc.textFile("hdfs://hadoop102:8020/spark/input/")

    //4.打印
    rdd1.foreach(println)
    println("-------------------------")
    rdd2.foreach(println)

    //5.关闭
    sc.stop()
  }
}