#!/bin/sh
image="saltmin"
vol="-v /media/sf_GitHub/saltstack-couchbase/couchbase:/srv/salt/couchbase"
pil="-v /media/sf_GitHub/saltstack-couchbase/pillar.example:/srv/pillar/couchbase/init.sls"
hos="--hostname=server01"
del="--rm=true"
docker run $vol $pil $hos $del -ti $image $@
