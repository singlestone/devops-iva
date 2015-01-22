DevOps InnovateVA
=================
This repository contains application and infrastructure code to provision an AWS VPC with a Jenkins server that polls this repository and a Tomcat application server that executes the application code.  The application is a simple Spring MVC Java app that is capable of displaying text messages and their senders via the third-party service Twilio.  The application writes to a DynamoDB table in Amazon and the UI displays the values stored in the database.

Prerequisites
=================
This demo depends on a running Chef Server with all the necessary cookbooks already uploaded.  Additionally, the validation key that the Chef Client uses to bootstrap itself (validation.pem) needs to be correctly uploaded to S3 and available for the Jenkins and Tomcat instance to download.  This can either be accomplished by making the validation.pem public (not preferred) or including the attachment of an IAM role with access to S3 to each of the two servers (in progress). We will be removing the Chef Server dependency in the next release of the demo.

Workflow
=================
The entire stack is kicked off with a call to CloudFormation.  This can either be through the AWS Console or through the AWS CLI.  If using the CLI, the appropriate command would be: 

```aws cloudformation create-stack --stack-name InnovateVA --template-url https://s3.amazonaws.com/singlestone/cfn/master.template```

Note that you will need to replace the S3 URL with the URL that you use to host the CloudFormation templates in the /cfn directory on GitHub.  Also, you will need to ensure that your CLI has API access to AWS; this can be accomplished by installing the CLI tools locally and setting your PATH variable such that it includes /usr/local/bin (the location of the AWS executables).  To determine if /usr/local/bin is already in your PATH, run:

```echo $PATH```

If /usr/local/bin is not already in your PATH, run:

```export PATH=$PATH:/usr/local/bin```

If you are using the AWS Console, simply navigate to CloudFormation and create a new stack, pointing CloudFormation at the correct S3 location of the master.template.

What Happens
=================
After the CloudFormation API call has taken place, the master.template begins creating a new VPC in AWS.  Once the VPC has been created, the jenkins.template and web.template are simultaneously kicked off.  They require the VPCID and PublicSubnetID outputs from the vpc.template, so the master.template specifies "DependsOn" : "IvaVpcStack" for both the Jenkins and Web template. The Jenkins and Web templates include custom scripts in the UserData sections that download the appropriate artifacts from S3 (e.g. the Jenkins instance pulls down a runlist specifically for installing Jenkins, while the Tomcat instance pulls down a runlist specifically for installing Tomcat). After the instances become available, they download those files and run a script that bootstraps them to the Chef Server.  

Once bootstrapped, the two nodes execute Chef runs against themselves, at which point they are available as Jenkins and Tomcat instances.  The Jenkins Chef cookbook also includes a file in /templates/default that installs the necessary job to pull code from GitHub and push it to the Tomcat instance.  After the Jenkins cookbook has successfully executed (meaning the job XML file has been placed and the Jenkins service has restarted), Jenkins will immediately kick off the job as it sees a 'change' to the GitHub repository that it points to.  This initial build should complete and push ROOT.war to /usr/share/tomcat7/webapps/ROOT.war on the Tomcat instance.  

While the Jenkins server has been building itself with Chef, the Tomcat instance has also been executing its own Chef run based on a runlist containing the tomcat::default recipe.  Part of that recipe includes pulling down a shell script from S3 containing the access keys for the Twilio API.  This script simply echoes the JAVA_OPTS environment variable containing the twilio.authToken and twilio.sid parameters into /etc/tomcat7/tomcat7.conf.

Since the application has been compiled and installed in the correct directory for Tomcat to serve the file by the Jenkins job, Tomcat should start and the app should be available at singlestonedemo:8080.
