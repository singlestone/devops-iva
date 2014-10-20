package com.singlestoneconsulting.web;

import com.singlestoneconsulting.participant.Participant;
import com.singlestoneconsulting.participant.ParticipantRepository;
import com.singlestoneconsulting.sms.SmsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.PostConstruct;
import java.util.Set;

import static org.springframework.http.MediaType.*;
import static org.springframework.web.bind.annotation.RequestMethod.*;

@RestController
@RequestMapping("/api")
public class ApiController {

    private final ParticipantRepository participantRepository;
    private final SmsService smsService;

    @Autowired
    public ApiController(ParticipantRepository participantRepository, SmsService smsService) {
        this.participantRepository = participantRepository;
        this.smsService = smsService;
    }

    @RequestMapping(value = "/participants", method = GET, produces = APPLICATION_JSON_VALUE)
    public Set<Participant> participants() {
        return participantRepository.all();
    }

    @RequestMapping(value = "/broadcast", method = POST)
    public ResponseEntity<String> broadcast(String message) {
        for (Participant p : participantRepository.all()) {
            smsService.sendText(p.getPhoneNumber(), message);
        }
        return new ResponseEntity<>("ok", HttpStatus.OK);
    }

    @RequestMapping(value = "/twilio", method = RequestMethod.POST)
    public ResponseEntity<String> register(@RequestParam("From") String from, @RequestParam("Body") String body) {
        Participant participant = participantRepository.get(from);
        if (participant == null) {
            participant = new Participant(from);
        }
        participant.setName(body);

        participantRepository.save(participant);

        return sendXml(smsService.getResponse("Got it! Thanks " + participant.getName()));
    }

    @PostConstruct
    public void postConstruct() {
        for (Participant p : participantRepository.all()) {
            smsService.sendText(p.getPhoneNumber(), "Hi " + p.getName() + ", check out the new version.");
        }
    }

    private ResponseEntity<String> sendXml(String xml) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_XML);
        return new ResponseEntity<>(xml, headers, HttpStatus.OK);
    }
}
