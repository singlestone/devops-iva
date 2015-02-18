#!/bin/bash -v
echo 'JAVA_OPTS="-Dtwilio.authToken=your_auth_token -Dtwilio.sid=your_sid -javaagent:/opt/appdynamics/javaagent.jar"' >> /etc/tomcat7/tomcat7.conf
