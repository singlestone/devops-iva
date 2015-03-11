name "innovateva_app"
description "Creates the Innovate VA application server."
run_list "recipe[appdynamics]", "recipe[openssl]", "recipe[tomcat]"