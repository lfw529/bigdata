package kafka.producer;

import org.apache.kafka.clients.producer.*;

import java.util.Properties;

/**
 * 异步发送
 */
public class CustomProducerCallback {
    public static void main(String[] args) {
        //1.创建 kafka 生产者的配置对象
        Properties properties = new Properties();

        //2.给 kafka 配置对象添加配置信息：bootstrap.servers
        properties.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "hadoop102:9092");

        //key, value 序列化(必须)：key.serializer, value.serializer
        properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer");
        properties.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer");

        //3.创建 kafka 生产者对象
        KafkaProducer<String, String> kafkaProducer = new KafkaProducer<String, String>(properties);

        //4.调用 send 方法，发送消息
        for (int i = 0; i < 5; i++) {
            // 添加回调
            kafkaProducer.send(new ProducerRecord<>("first", "lfw " + i), new Callback() {
                //该方法在 Producer 收到 ack 时调用，为异步调用
                @Override
                public void onCompletion(RecordMetadata metadata, Exception exception) {
                    if (exception == null) {
                        // 没有异常,输出信息到控制台
                        System.out.println("主题：" + metadata.topic() + "->" + "分区：" + metadata.partition());
                    } else {
                        // 出现异常打印
                        exception.printStackTrace();
                    }
                }
            });
        }

        //5.关闭资源
        kafkaProducer.close();
    }
}
