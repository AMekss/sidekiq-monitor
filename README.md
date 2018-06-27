# Sidekiq-monitor

Aims to provide a sidekiq prometheus exporter service ready to be packed and shipped to k8s cluster.
This project wraps this [library](https://github.com/Strech/sidekiq-prometheus-exporter) and adds health checks for running it in cluster

## Development

Development build
```
docker-compose build
```

Development run
```
docker-compose up
```

Once your done with changes commit and push it upstream. That will build a container in our private GCR.
