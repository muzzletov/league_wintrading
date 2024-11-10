FROM gcr.io/distroless/static-debian12

COPY --chown=nobody:nobody prometheus        /bin/prometheus
COPY --chown=nobody:nobody promtool          /bin/promtool
COPY --chown=nobody:nobody prometheus.yml  /etc/prometheus/prometheus.yml

WORKDIR /prometheus

USER       nobody
EXPOSE     9090
VOLUME     [ "/prometheus" ]
ENTRYPOINT [ "/bin/prometheus" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus" ]
