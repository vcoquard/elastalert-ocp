# elastalert-ocp
Run [Elastalert](https://github.com/Yelp/elastalert) in Openshift Container Platform

Run below commands as **cluster-admin** user
```
oc adm new-project openshift-elastalert
oc project openshift-elastalert
oc get secret elasticsearch -n openshift-logging -o yaml --export > es-secret.yaml
oc create -f es-secret.yaml
wget https://raw.githubusercontent.com/jstakun/elastalert-ocp/master/elastalert-ocp.yaml
#this commands will pull images from quay.io registry, make sure to whitelist quay.io in your cluster following the docs: https://docs.openshift.com/container-platform/4.1/openshift_images/image-configuration.html#images-configuration-insecure_image-configuration
oc create -f elastalert-ocp.yaml
```
This should provision for you sample fully functional elastsearch pod with fakesmtp mail server. Please have a look at created config maps to customize the configuration for your needs:

Elastalert configuration:
```
oc edit cm config-cm -n openshift-elastalert
```
Elastalert example rule:
```
oc edit cm rules-alerting -n openshift-elastalert
```
This repo has been inspired by https://github.com/kilimandjango/openshift-elastalert

For more details about Elastalert refer to https://github.com/Yelp/elastalert
