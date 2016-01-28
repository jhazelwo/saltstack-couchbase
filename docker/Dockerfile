FROM centos:6
MAINTAINER "John Hazelwood" <jhazelwo@users.noreply.github.com>

RUN yum clean expire-cache && \
 yum update -y && \
 yum install -y wget virt-what python-libnacl

# Install Salt
RUN curl -L https://bootstrap.saltstack.com | sh

RUN mkdir -p /etc/salt/minion.d
RUN echo "random_reauth_delay: 5" > /etc/salt/minion.d/custom.conf
# run in master-less mode
RUN echo "file_client: local" >> /etc/salt/minion.d/custom.conf

RUN echo "alias Apply='/usr/bin/salt-call --local state.apply couchbase.install'" >> /root/.bashrc
RUN echo "alias Remove='/usr/bin/salt-call --local state.apply couchbase.remove'" >> /root/.bashrc

CMD /usr/bin/salt-call --local state.highstate -l debug
