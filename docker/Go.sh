#!/bin/sh
image="saltmin"
vol="-v /media/sf_GitHub/saltstack-couchbase/couchbase:/srv/salt/couchbase"
hos="--hostname=minion"
del="--rm=true"
docker run $vol $hos $del -ti $image $@
