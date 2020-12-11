FROM corda/corda-corretto-java1.8-4.5

COPY --chown=corda:corda . .
COPY --chown=corda:corda example/node.conf /etc/corda/node.conf
COPY --chown=corda:corda example/certificates /opt/corda/certificates

USER root

RUN mv run-corda.sh bin/run-corda  

RUN ls /etc/corda/ \ 
      && ls /opt/corda/certificates

USER corda

# -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:+UseG1GC are added by run-corda.sh
# -Dlog4j2.debug 
ENV JVM_ARGS="-XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:+UseG1GC -XX:NativeMemoryTracking=summary -XX:+PrintNMTStatistics "
ENV CORDA_ARGS="--log-to-console --no-local-shell"
ENV CERTIFICATES_FOLDER=/opt/corda/certificates
ENV CONFIG_FOLDER=/etc/corda

EXPOSE 10200
EXPOSE 8080
EXPOSE 2222

CMD ["run-corda"]
# CMD ["sleep","3600"]
