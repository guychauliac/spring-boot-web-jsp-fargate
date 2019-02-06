set GIT_URL=%1
set APP_NAME=%2
git clone %GIT_URL%
mvn clean install
cd docker
oc apply -f deployconfig.yaml
oc apply -f buildconfig.yaml
call oc start-build %APP_NAME% --from-dir . --follow