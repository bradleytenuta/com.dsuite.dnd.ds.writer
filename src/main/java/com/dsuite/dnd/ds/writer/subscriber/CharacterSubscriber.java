package com.dsuite.dnd.ds.writer.subscriber;

import com.google.cloud.spring.pubsub.core.PubSubTemplate;
import com.google.cloud.spring.pubsub.support.BasicAcknowledgeablePubsubMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;

@Slf4j
@Component
public class CharacterSubscriber {

    @Autowired
    private PubSubTemplate pubSubTemplate;

    @Value("${dnd.ds.character}")
    private String topic;

    @PostConstruct
    public void subscribeToTopic() {
        // Subscribe to a topic and receive messages
        pubSubTemplate.subscribe(topic, (BasicAcknowledgeablePubsubMessage message) -> {
            // Process the message
            String messageContent = message.getPubsubMessage().getData().toStringUtf8();
            System.out.println(messageContent);

            // Acknowledge the message
            message.ack();
        });
        log.info("Created subscription to Topic: {}", topic);
    }
}