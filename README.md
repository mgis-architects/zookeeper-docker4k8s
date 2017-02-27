ZooKeeper Docker Image for k8s
================================

A ZooKeeper Docker Image for use with Kubernetes (based on modified fabric8 zookeeper image).

# Clustered Mode
To start the image in clustered mode you need to specify a couple of environment variables for the container.

| Environment Variable                          | Description                                    |
| --------------------------------------------- | -----------------------------------------------|
| NAMESPACE                                     | namespace of the POD matching the service name |
| MAX_SERVERS                                   | The number of servers in the ensemble          |


Each container started with both of the above variables will use the following env variable setup:

    server.1=zookeeper-1.<NAMESPACE>:2888:3888
    server.2=zookeeper-2.<NAMESPACE>:2888:3888
    server.3=zookeeper-3.<NAMESPACE>:2888:3888
    ...
    server.N=zookeeper-N:2888:3888

Image uses KubeDNS service to resolve zookeper host names.

## Inside Kubernetes

Inside Kubernetes you can use a pod setup that looks like:

```
apiVersion: v1
kind: Pod
metadata:
  name: zookeeper-1
  labels:
    name: zookeeper-po
spec:
  hostname: zookeeper-1
  subdomain: zookeeper
  containers:
  - name: server
    image: zookeeper
    env:
    - name: NAMESPACE
      value: "zookeeper"
    - name: MAX_SERVERS
      value: "3"
    ports:
    - containerPort: 2181
    - containerPort: 2888
    - containerPort: 3888
---
apiVersion: v1
kind: Pod
metadata:
  name: zookeeper-2
  labels:
    name: zookeeper-po
spec:
  hostname: zookeeper-2
  subdomain: zookeeper
  containers:
  - name: server
    image: zookeeper
    env:
    - name: NAMESPACE
      value: "zookeeper"
    - name: MAX_SERVERS
      value: "3"
    ports:
    - containerPort: 2181
    - containerPort: 2888
    - containerPort: 3888
---
apiVersion: v1
kind: Pod
metadata:
  name: zookeeper-3
  labels:
    name: zookeeper-po
spec:
  hostname: zookeeper-3
  subdomain: zookeeper
  containers:
  - name: server
    image: zookeeper
    env:
    - name: NAMESPACE
      value: "zookeeper"
    - name: MAX_SERVERS
      value: "3"
    ports:
    - containerPort: 2181
    - containerPort: 2888
    - containerPort: 3888
---
apiVersion: v1
kind: Service
metadata:
  name: zookeeper
spec:
  selector:
    name: zookeeper-po
  clusterIP: None
  ports:
    - name: client
      port: 2181
      targetPort: 2181
    - name: followers
      port: 2888
      targetPort: 2888
    - name: election
      port: 3888
      targetPort: 3888
```

The container is configured to use the environment variable required for a clustered setup.
Last but not least pod is carefully named (as zookeeper-${SERVER_ID}) so that the other zookeeper servers can easily find it by hostname.