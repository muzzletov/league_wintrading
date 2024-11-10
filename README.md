## A wintrading backend and App for League of Legends

### What is win trading?

The idea is that you can request a win from someone on the opposing
team who would ideally have the win trading app installed on their phone. 

Once you issue a request, the request notification pops up at the player's
phone. \
He/she can then choose to give a win to you in some way or another - for example, by not playing as eagerly. 

### TODO:
- ~~extract configuration into environment variables~~
- ~~add tls~~
- ~~add kubernetes configuration~~
- ~~switch to valkey~~
- add tests (especially for app)
- add automated deployment
- add rate limiting (write load balancing plugin)
- add reverse (offering a win)
- add possibility of payment
- add limiting requests for a win per day
- add statistics
- add observability service and extend middleware
- add logging middleware and implement interface
- style app and refactor

### Setting up the project

run the cluster
- `KIND_EXPERIMENTAL_PROVIDER=podman  systemd-run --scope --user -p "Delegate=yes" kind create cluster`

install cert manager
- `kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.yaml`

build, load images, scaffold everything and run a test locally
```
# yes, we need to supply docker.io here, as kubernetes tries to match that specific registry's domain
podman build -t docker.io/library/scp:latest -f scp.dockerfile 
podman build -t docker.io/library/fcm:latest -f fcm.dockerfile 
podman pull valkey/valkey:latest

# push the images so they become available to kubernetes as we dont have a local registry running
kind load docker-image fcm
kind load docker-image scp
kind load docker-image valkey/valkey

# create fcm's certificates
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout fcm.key -out fcm.crt -subj "/CN=fcm-service" -addext "subjectAltName = DNS:fcm-service"

# create scp's certificates
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout scp.key -out scp.crt -subj "/CN=scp-service" -addext "subjectAltName = DNS:scp-service"

# create scp service certificate
kubectl create secret generic scp-secret --from-file=tls.crt=scp.crt --from-file=tls.key=scp.key

# create scp service certificate
kubectl create secret generic fcm-secret --from-file=tls.crt=fcm.crt --from-file=tls.key=fcm.key

# FCM credentials file
kubectl create configmap fcm-cred --from-file=credentials.json=credentials.json
kubectl create configmap fcm-pubkey --from-file=ca.crt=fcm.crt

# finally run our infrastructure
kubectl apply -f kubernetes.yaml

# forwarding the cluster pod's client facing port
kubectl port-forward $(kubectl get pods --selector=app=scp -o name) 5552:5552

# adding the alias 'scp-service' to localhost is necessary at this point
# you are on your own here tho

# run
dart test/bin/grpc_test.dart 
```

things you would ultimately have to solve yourself
- no load balancer yet and no means to offload to a specific pod -\
consider using the nginx ingress controller
- the service's certificate should be issued by a CA

additionally, if you want to debug the services, you'd need this: \
`kubectl port-forward $(kubectl get pods --selector=app=scp -o name) 12221:12221` # for the scraping service \
`kubectl port-forward $(kubectl get pods --selector=app=fcm -o name) 12222:12222` # for the messaging service \
port forwarding for the debugging ports



