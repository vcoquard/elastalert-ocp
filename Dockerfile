FROM registry.access.redhat.com/rhscl/python-36-rhel7

MAINTAINER Jaroslaw Stakun "jstakun@redhat.com"

ENV ELASTALERT_VERSION 0.2.4

# Elastalert rules directory.
ENV ELASTALERT_HOME /opt/elastalert
ENV RULES_DIRECTORY $ELASTALERT_HOME/rules
ENV CONFIG_DIRECTORY $ELASTALERT_HOME/config

USER root

RUN INSTALL_PKGS="python3-devel python3-setuptools net-tools" && \
    yum -y --disablerepo=* --enablerepo=rhel-7-server-rpms --enablerepo=rhel-server-rhscl-7-rpms install ${INSTALL_PKGS} && \
    yum -y update && \
    yum -q clean all && \
    cd $HOME

COPY elastalert-0.2.4.tar.gz /elastalert-0.2.4.tar.gz

RUN tar xvf /elastalert-0.2.4.tar.gz

# Copy config
COPY /configuration/run.sh $ELASTALERT_HOME/run.sh

# Create default user, change ownership of files
# Create dirs
# Install workaround
RUN useradd -u 1000 -r -g 0 -m -d $HOME -s /sbin/nologin -c "elastalert user" elastalert && \
    cp -r /etc/skel/. $HOME && \
    chown -R elastalert:0 $HOME && \
    fix-permissions $HOME && \
    fix-permissions /opt/app-rootI && \
    chmod +x $ELASTALERT_HOME/run.sh && \
    ln -s $ELASTALERT_HOME/run.sh $HOME/run.sh && \
    mkdir $ELASTALERT_HOME/rules && \
    mkdir $ELASTALERT_HOME/config && \
    . /opt/app-root/etc/scl_enable && \
    pip install --upgrade pip && \
    pip install --upgrade setuptools && \
    pip install elastalert

VOLUME $RULES_DIRECTORY

VOLUME $CONFIG_DIRECTORY

# switch to elastalert
USER 1000

ENTRYPOINT ["/opt/app-root/src/run.sh"]
