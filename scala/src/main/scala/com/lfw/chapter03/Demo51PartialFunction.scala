package com.lfw.chapter03

object Demo51PartialFunction {
  def main(args: Array[String]): Unit = {
    val list: List[(String, Int)] = List(("a", 12), ("b", 35), ("c", 27), ("a", 13))
    //1.map转换，实现key不变，value 2倍
    val newList: List[(String, Int)] = list.map((tuple: (String, Int)) => (tuple._1, tuple._2 * 2))
    //2.用模式匹配对元组元素赋值，实现功能
    val newList2: List[(String, Int)] = list.map(
      tuple => {
        tuple match {
          case (word, count) => (word, count * 2)
        }
      }
    )
    //3.省略lambda表达式的写法，进行化简[偏函数]，单个
    val newList3: List[(String, Int)] = list.map {
      case (word, count) => (word, count * 2)
    }
    println(newList)
    println(newList2)
    println(newList3)

    //偏函数的应用，求绝对值
    //对输入数据分为不同的情形：正、负、0
    val positiveAbs: PartialFunction[Int, Int] = {
      case x if x > 0 => x
    }

    val negativeAbs: PartialFunction[Int, Int] = {
      case x if x < 0 => -x
    }

    val zeroAbs: PartialFunction[Int, Int] = {
      case 0 => 0
    }

    //该部分功能与后备部分功能组成
    def abs(x: Int): Int = (positiveAbs orElse negativeAbs orElse zeroAbs) (x)

    println(abs(-67)) //67
    println(abs(35)) //35
    println(abs(0)) //0
  }
}
