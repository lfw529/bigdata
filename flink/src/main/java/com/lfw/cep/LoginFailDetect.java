package com.lfw.cep;

import com.lfw.pojo.LoginCEP;
import org.apache.flink.api.common.eventtime.SerializableTimestampAssigner;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.cep.CEP;
import org.apache.flink.cep.PatternSelectFunction;
import org.apache.flink.cep.PatternStream;
import org.apache.flink.cep.pattern.Pattern;
import org.apache.flink.cep.pattern.conditions.SimpleCondition;
import org.apache.flink.streaming.api.datastream.KeyedStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

import java.util.List;
import java.util.Map;

public class LoginFailDetect {
    public static void main(String[] args) throws Exception {
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);

        // 获取登录事件流，并提取时间戳、生成水位线
        KeyedStream<LoginCEP, String> stream = env
                .fromElements(
                        new LoginCEP("user_1", "192.168.0.1", "fail", 2000L),
                        new LoginCEP("user_1", "192.168.0.2", "fail", 3000L),
                        new LoginCEP("user_2", "192.168.1.29", "fail", 4000L),
                        new LoginCEP("user_1", "171.56.23.10", "fail", 5000L),
                        new LoginCEP("user_2", "192.168.1.29", "success", 6000L),
                        new LoginCEP("user_2", "192.168.1.29", "fail", 7000L),
                        new LoginCEP("user_2", "192.168.1.29", "fail", 8000L)
                ).assignTimestampsAndWatermarks(
                        WatermarkStrategy.<LoginCEP>forMonotonousTimestamps()
                                .withTimestampAssigner(
                                        new SerializableTimestampAssigner<LoginCEP>() {
                                            @Override
                                            public long extractTimestamp(LoginCEP loginEvent, long l) {
                                                return loginEvent.timestamp;
                                            }
                                        }
                                )
                ).keyBy(r -> r.userId);

        //1.定义 Pattern,连续的三个登录失败事件
        Pattern<LoginCEP, LoginCEP> pattern = Pattern.<LoginCEP>begin("first")  //以第一个登录失败事件开始
                .where(new SimpleCondition<LoginCEP>() {
                    @Override
                    public boolean filter(LoginCEP loginCEP) throws Exception {
                        return loginCEP.eventType.equals("fail");
                    }
                })
                .next("second")   //接着是第二个登录事件
                .where(new SimpleCondition<LoginCEP>() {
                    @Override
                    public boolean filter(LoginCEP loginCEP) throws Exception {
                        return loginCEP.eventType.equals("fail");
                    }
                })
                .next("third")     // 接着是第三个登录失败事件
                .where(new SimpleCondition<LoginCEP>() {
                    @Override
                    public boolean filter(LoginCEP loginCEP) throws Exception {
                        return loginCEP.eventType.equals("fail");
                    }
                });

        //2.将Pattern应用到流上，检测匹配的复杂事件，得到一个PatternStream
        PatternStream<LoginCEP> patternStream = CEP.pattern(stream, pattern);

        //3.将匹配到的复杂事件选择出来，然后包装成字符串报警信息输出
        patternStream.select(new PatternSelectFunction<LoginCEP, String>() {
            @Override
            public String select(Map<String, List<LoginCEP>> map) throws Exception {
                LoginCEP first = map.get("first").get(0);
                LoginCEP second = map.get("second").get(0);
                LoginCEP third = map.get("third").get(0);
                return first.userId + " 连续三次登录失败！登录时间：" + first.timestamp + ", " + second.timestamp + ", " + third.timestamp;
            }
        }).print("warning");

        env.execute();
    }
}