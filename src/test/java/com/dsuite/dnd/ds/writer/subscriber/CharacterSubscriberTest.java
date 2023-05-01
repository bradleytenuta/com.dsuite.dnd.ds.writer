package com.dsuite.dnd.ds.writer.subscriber;

import com.google.cloud.spring.pubsub.core.PubSubTemplate;
import com.google.cloud.spring.pubsub.support.BasicAcknowledgeablePubsubMessage;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
@ExtendWith(MockitoExtension.class)
public class CharacterSubscriberTest {

    @Mock
    private PubSubTemplate pubSubTemplate;

    @Autowired
    private CharacterSubscriber characterSubscriber;

    @Captor
    private ArgumentCaptor<BasicAcknowledgeablePubsubMessage> messageCaptor;

    @Test
    public void testSubscribeToTopic() {
        // Call the post construct method manually
        characterSubscriber.subscribeToTopic();
        // Verify that the pubSubTemplate.subscribe() method is called with the expected arguments
        Mockito.verify(pubSubTemplate).subscribe("my-subscription", ArgumentMatchers.any());
    }
}