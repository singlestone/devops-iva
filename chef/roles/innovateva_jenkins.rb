name "innovateva_jenkins"
description "Creates the Innovate VA build server."
run_list "recipe[java]", "recipe[maven]", "recipe[git]", "recipe[jenkins::master]"