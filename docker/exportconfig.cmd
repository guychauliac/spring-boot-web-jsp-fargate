oc export buildconfig spring-boot-web-jsp -o yaml > buildconfig.yaml
oc export deploymentconfig spring-boot-web-jsp -o yaml > deployconfig.yaml
oc export service spring-boot-web-jsp -o yaml > serviceconfig.yaml
