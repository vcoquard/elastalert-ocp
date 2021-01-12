# elastalert-ocp
Run [Elastalert](https://github.com/Yelp/elastalert) in Openshift Container Platform 4.x

Run below commands as **cluster-admin** user
```
$ oc adm new-project openshift-elastalert
$ oc project openshift-elastalert

#copy this secret to access Elasticsearch pods from elastalert
$ oc get secret elasticsearch -n openshift-logging -o yaml --export | oc apply -n openshift-elastalert -f -

$ wget https://raw.githubusercontent.com/jstakun/elastalert-ocp/ocp-4.5%2B/elastalert-ocp.yaml
#this commands will pull images from quay.io registry, make sure to whitelist quay.io in your cluster following the docs: https://docs.openshift.com/container-platform/4.4/openshift_images/image-configuration.html#images-configuration-insecure_image-configuration
$ oc create -f elastalert-ocp.yaml

#get elastalert service account token and paste it to cm-config es_bearer variable value
$ oc sa get-token elastalert 
$ oc edit configmap config-cm
   ...
   es_bearer: <ELASTALERT_SA_TOKEN>
   ...
```
Now you need to assign Elasticsearch admin role to elastalert service account. As of now I don't know the way to do it in persistent way hence each time Elasticsearch pod will be restarted you'll need to repeat the steps below, otherwise you'll see 403 errors in elastalert pod.

```
$ oc project openshift-logging
#repeat this step in all elasticsearch pods
$ oc rsh elasticsearch-cdm-luzbzv0n-1-58b4f47b4-g4tfc

sh-4.2$ vi sgconfig/roles_mapping.yml
   ...
   sg_role_admin:
     users:
       - 'CN=system.admin,OU=OpenShift,O=Logging'
       - 'system:serviceaccount:openshift-elastalert:elastalert'
   ...
sh-4.2$ es_seed_acl
```

Verify both pods are up and running:
```
$ oc get pods | grep Running
elastalert-ocp-1-6nk5k    1/1     Running     0          4m32s
mailman-1-fhsnq           1/1     Running     0          4m34s

$ oc logs -f elastalert-ocp-1-6nk5k
Checking Elastic Version
Elastic Version: 6.8.1
Reading Elastic 6 index mappings:
Reading index mapping 'es_mappings/6/silence.json'
Reading index mapping 'es_mappings/6/elastalert_status.json'
Reading index mapping 'es_mappings/6/elastalert.json'
Reading index mapping 'es_mappings/6/past_elastalert.json'
Reading index mapping 'es_mappings/6/elastalert_error.json'
Index elastalert_status already exists. Skipping index creation.
1 rules loaded
INFO:elastalert:Starting up
INFO:elastalert:Disabled rules are: []
INFO:elastalert:Sleeping for 59.999889 seconds
INFO:elastalert:Queried rule rules/my-rules from 2021-01-08 00:00 UTC to 2021-01-08 00:15 UTC: 0 / 0 hits
...
INFO:elastalert:Ran rules/my-rules from 2021-01-08 00:00 UTC to 2021-01-08 15:43 UTC: 0 query hits (0 already seen), 0 matches, 0 alerts sent
```

Now you can adjust configuration to your needs:

1. Elastalert configuration:
```
oc edit cm config-cm -n openshift-elastalert
```
2. Elastalert example rule:
```
oc edit cm rules-alerting -n openshift-elastalert
```


This repo has been inspired by https://github.com/kilimandjango/openshift-elastalert

For more details about Elastalert refer to https://github.com/Yelp/elastalert
