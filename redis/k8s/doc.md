# Arquitetura de implantação
Vamos usar o operator Spotahome para implantar e configurar um Redis altamente disponível no GKE (Google Kubernetes Engine) com um nó líder e duas réplicas de leitura, além do Redis Sentinel.

Também vamos implantar um cluster regional do GKE altamente disponível para o Redis, com vários nós do Kubernetes espalhados por várias zonas de disponibilidade. Essa configuração ajuda a garantir tolerância a falhas, escalabilidade e redundância geográfica.

O diagrama a seguir mostra como o Redis será executado em vários nós e zonas em um cluster do GKE:

![](img/gke-spotahome-sentinel.svg)

Para controlar como o GKE implanta o StatefulSet em nós e zonas, foi definida [topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) na especificação dos pods.

Importante: O tutorial não aborda todas as questões relacionadas a ambiente produtivo. Sendo assim, pense criticamente antes de cogitar a adoção desse procedimento.

# Configuração inicial do ambiente
Execute os seguintes comandos no Cloud Shell:

```bash
gcloud services enable compute.googleapis.com iam.googleapis.com container.googleapis.com gkebackup.googleapis.com cloudresourcemanager.googleapis.com

export PROJECT_ID=$(gcloud config get-value core/project)
export KUBERNETES_CLUSTER_PREFIX=redis
export REGION=us-central1

git clone https://github.com/tavaresdb/db
cd db/redis/k8s
```

# Criação da infraestrutura do cluster
O diagrama a seguir mostra um cluster privado regional standard do GKE implantado em três zonas diferentes:

![](img/gke-spotahome-standard-architecture.svg)

Para implantar essa infraestrutura, execute os seguintes comandos no Cloud Shell:
```bash
export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)
terraform -chdir=iac/gke-standard init
terraform -chdir=iac/gke-standard apply -var project_id=${PROJECT_ID} \
  -var region=${REGION} \
  -var cluster_prefix=${KUBERNETES_CLUSTER_PREFIX}
```

O Terraform criará os seguintes recursos:

• Uma rede VPC e uma sub-rede privada para os nós do Kubernetes.

• Um roteador para acessar a internet usando NAT.

• Um cluster privado do GKE na região us-central1.

• Node pool com escalonamento automático ativado (de um a dois nós por zona, sendo no mínimo um nó por zona).

• Uma ServiceAccount com permissões de registro e monitoramento.

• Backup do GKE para recuperação de desastres.

• Google Cloud Managed Service para Prometheus para monitoramento de clusters.

Concluída a criação dos recursos, recupere as credencias do cluster conforme comando abaixo:

```bash
gcloud container clusters get-credentials ${KUBERNETES_CLUSTER_PREFIX}-cluster --region ${REGION}
```

# Implantação do operator Spotahome no cluster

## Criação do namespace
```bash
export NAMESPACE=ns-redis
kubectl create ns ${NAMESPACE}
kubectl config set-context --current --namespace=${NAMESPACE}
```

## Instalação do operator c/ Helm
```bash
helm repo add redis-operator https://spotahome.github.io/redis-operator
helm repo update

helm -n ${NAMESPACE} install redis-operator redis-operator/redis-operator --version 3.2.9
NAME: redis-operator
LAST DEPLOYED: Sun Aug  4 03:40:00 2024
NAMESPACE: ns-redis
STATUS: deployed
REVISION: 1
TEST SUITE: None

helm -n ${NAMESPACE} ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
redis-operator  ns-redis        1               2024-08-04 03:40:00.911902026 +0000 UTC deployed        redis-operator-3.2.9    1.2.4      

helm -n ${NAMESPACE} get manifest redis-operator
helm -n ${NAMESPACE} get values redis-operator/redis-operator

kubectl get all
```

# Implantação do Redis Sentinel
A configuração do Redis contará com os seguintes componentes:

• Três réplicas de nós do Redis: uma líder e duas réplicas de leitura.

• Três réplicas de nós do Sentinel, formando um quórum.

• Ao especificar a solicitação de recurso para contêineres em um pod, o kube-scheduler usará essas informações para decidir em qual nó o pod será alocado. Ao especificar um limite de recurso para um contêiner, o kubelet aplicará esse limite para que o contêiner não tenha permissão para usar mais desse recurso do que o limite definido. Essas especificações foram definidas para o Redis e o Sentinel.

• As topologySpreadConstraints configuradas para cada carga de trabalho, garantindo a distribuição adequada entre os nós do Kubernetes em diferentes zonas de disponibilidade.

```bash
export PASSWORD=$(openssl rand -base64 12)
kubectl create secret generic my-user \
    --from-literal=password="$PASSWORD"

kubectl apply -f manifests/redis-spotahome/my-cluster.yaml

kubectl wait pods -l redisfailovers.databases.spotahome.com/name=my-cluster --for condition=Ready --timeout=300s
pod/rfr-my-cluster-0 condition met
pod/rfr-my-cluster-1 condition met
pod/rfr-my-cluster-2 condition met
pod/rfs-my-cluster-7d976dcbcb-bgsts condition met
pod/rfs-my-cluster-7d976dcbcb-lqql6 condition met
pod/rfs-my-cluster-7d976dcbcb-q66md condition met

kubectl get pod,svc,sts,pvc,deploy,pdb
NAME                                  READY   STATUS    RESTARTS   AGE
pod/redis-operator-77c795fc5f-nckpg   1/1     Running   0          10m
pod/rfr-my-cluster-0                  2/2     Running   0          8m44s
pod/rfr-my-cluster-1                  2/2     Running   0          8m44s
pod/rfr-my-cluster-2                  2/2     Running   0          8m44s
pod/rfs-my-cluster-7d976dcbcb-bgsts   2/2     Running   0          8m44s
pod/rfs-my-cluster-7d976dcbcb-lqql6   2/2     Running   0          8m44s
pod/rfs-my-cluster-7d976dcbcb-q66md   2/2     Running   0          8m44s

NAME                     TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)     AGE
service/redis-operator   ClusterIP   10.52.9.86    <none>        9710/TCP    10m
redis-my-cluster         ClusterIP   10.52.4.231   <none>        6379/TCP    8m45s
service/rfr-my-cluster   ClusterIP   None          <none>        9121/TCP    8m45s
service/rfs-my-cluster   ClusterIP   10.52.7.230   <none>        26379/TCP   8m45s

NAME                              READY   AGE
statefulset.apps/rfr-my-cluster   3/3     8m44s

NAME                                                                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/redisfailover-persistent-data-rfr-my-cluster-0   Bound    pvc-aba64c96-c04a-43ff-84f6-d6d7e5b72555   2Gi        RWO            premium-rwo    <unset>                 8m46s
persistentvolumeclaim/redisfailover-persistent-data-rfr-my-cluster-1   Bound    pvc-52d07d5f-9c0c-4390-a927-3a2f317043fd   2Gi        RWO            premium-rwo    <unset>                 8m46s
persistentvolumeclaim/redisfailover-persistent-data-rfr-my-cluster-2   Bound    pvc-d0c9ac8c-6d18-4919-8127-5ea6f2566599   2Gi        RWO            premium-rwo    <unset>                 8m46s

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-operator   1/1     1            1           10m
deployment.apps/rfs-my-cluster   3/3     3            3           8m44s

NAME                                        MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
poddisruptionbudget.policy/rfr-my-cluster   2               N/A               1                     8m44s
poddisruptionbudget.policy/rfs-my-cluster   2               N/A               1                     8m44s

kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.topology\.kubernetes\.io/zone}{"\n"}{end}'    
gke-redis-cluster-default-node-pool-1891411a-mhwb       us-central1-f
gke-redis-cluster-default-node-pool-aca6b2b2-jrnt       us-central1-a
gke-redis-cluster-default-node-pool-f785f43a-jm57       us-central1-b

kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}'
rfr-my-cluster-0        gke-redis-cluster-default-node-pool-1891411a-mhwb
rfr-my-cluster-1        gke-redis-cluster-default-node-pool-f785f43a-jm57
rfr-my-cluster-2        gke-redis-cluster-default-node-pool-aca6b2b2-jrnt
rfs-my-cluster-7d976dcbcb-bgsts gke-redis-cluster-default-node-pool-1891411a-mhwb
rfs-my-cluster-7d976dcbcb-lqql6 gke-redis-cluster-default-node-pool-f785f43a-jm57
rfs-my-cluster-7d976dcbcb-q66md gke-redis-cluster-default-node-pool-aca6b2b2-jrnt
```

O operator criará os seguintes recursos:

• Um StatefulSet do Redis e um Deployment do Sentinel.

• Três réplicas de pods para o Redis.

• Três réplicas de pods para o Sentinel.

• Dois PodDisruptionBudgets, garantindo no mínimo duas réplicas disponíveis para a consistência do cluster.

• O serviço redis-my-cluster, que tem como destino o nó líder do cluster do Redis.

• O serviço rfr-my-cluster, que expõe métricas do Redis.

• O serviço rfs-my-cluster, que permite que os clientes se conectem ao cluster usando Sentinels. O suporte ao Sentinel é necessário para bibliotecas de cliente.

# Conexão com o Redis
```bash
kubectl apply -f manifests/redis-spotahome/client-pod.yaml
kubectl wait pod redis-client --for=condition=Ready --timeout=300s
kubectl exec -it redis-client -- /bin/sh

redis-cli -h redis-my-cluster -a $PASS --no-auth-warning SET my-key "testvalue"
redis-cli -h redis-my-cluster -a $PASS --no-auth-warning GET my-key
exit
```

# Coleta de métricas com o Prometheus
O diagrama a seguir mostra como funcionará a coleta de métricas com o Prometheus:

![](img/gke-spotahome-metrics-architecture.svg)

No diagrama, o cluster privado do GKE contém os seguintes componentes:

• Um pod Redis que coleta métricas no caminho / e na porta 9121.

• Coletores baseados em Prometheus que processam as métricas do pod do Redis.

• Um recurso de PodMonitoring que envia métricas ao Cloud Monitoring.

O Google Cloud Managed Service para Prometheus é compatível com a coleta de métricas no formato do Prometheus. O Cloud Monitoring usa um [painel integrado](https://cloud.google.com/stackdriver/docs/managed-prometheus/exporters/redis?hl=pt-br) para métricas do Redis.

O operador do Spotahome expõe as métricas de cluster no formato do Prometheus usando o [redis_exporter](https://github.com/oliver006/redis_exporter) como um arquivo secundário.

1. Crie o recurso PodMonitoring para coletar métricas por labelSelector.
```bash
kubectl apply -f manifests/redis-spotahome/pod-monitoring.yaml
```

2. No console do Google Cloud, acesse a página [Painel de clusters do GKE](https://console.cloud.google.com/monitoring/dashboards/resourceList/gmp_gke_cluster?hl=pt-br). O painel mostrará uma taxa de ingestão de métricas diferente de 0.

3. No console do Google Cloud, acesse a página [Painéis](https://console.cloud.google.com/monitoring/dashboards?hl=pt-br).

4. Abra o painel de informações gerais do Redis Prometheus. O painel mostra a quantidade de conexões e chaves. Pode levar vários minutos para que o painel seja provisionado automaticamente.

5. Conecte-se ao pod cliente.
```bash
kubectl exec -it redis-client -- /bin/sh
```

6. Crie novas chaves via redis-cli.
```bash
seq 1 10000 | xargs -I{} redis-cli -h redis-my-cluster -a $PASS --no-auth-warning SET mykey-{} "myvalue-{}"
redis-cli -h redis-my-cluster -a $PASS --no-auth-warning SAVE
redis-cli -h redis-my-cluster -a $PASS --no-auth-warning SCAN 0
exit
```

Obs.: O comando SAVE é opcional. O intuito é persistir os dados no disco e posteriormente na seção de Backup e Restore abordaremos a recuperação dos dados.

7. Atualize a página e observe que os gráficos 'Comandos por segundo' e 'Chaves' foram atualizados para mostrar o estado real do banco de dados.

![](img/01.png)

![](img/02.png)

![](img/03.png)

# Backup e Restore
Existem algumas formas de fazer backup e restauração dos dados. Aqui optei por utilizar o [Backup for GKE](https://cloud.google.com/kubernetes-engine/docs/add-on/backup-for-gke/concepts/backup-for-gke?hl=pt-br). A documentação oficial é bem completa, então a ideia aqui é somente compartilhar o roteiro.

## Definição de uma lógica personalizada de backup e restauração
```bash
export SELECTED_APPS=ns-redis/protected-application-redis

kubectl apply -f manifests/redis-spotahome/protected.yaml
kubectl describe protectedapplication protected-application-redis

Name:         protected-application-redis
Namespace:    ns-redis
Labels:       <none>
Annotations:  <none>
API Version:  gkebackup.gke.io/v1
Kind:         ProtectedApplication
Metadata:
  Creation Timestamp:  2024-08-06T02:52:29Z
  Finalizers:
    gkebackup.gke.io/protected-application-protection
  Generation:        1
  Resource Version:  23051
  UID:               28820e0d-356c-4deb-83fa-79cc08839ce1
Spec:
  Components:
    Name:           my-cluster
    Resource Kind:  StatefulSet
    Resource Names:
      rfr-my-cluster
    Strategy:
      Backup One Restore All:
        Backup Target Name:  rfr-my-cluster
      Type:                  BackupOneRestoreAll
  Resource Selection:
    Selector:
      Match Labels:
        app.kubernetes.io/name:  my-cluster
    Type:                        Selector
Status:
  Ready To Backup:  true
Events:             <none>
```

## Plano de Backup
```bash
gcloud beta container backup-restore backup-plans create ${KUBERNETES_CLUSTER_PREFIX}-backup-plan \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --cluster=projects/${PROJECT_ID}/locations/${REGION}/clusters/${KUBERNETES_CLUSTER_PREFIX}-cluster \
    --selected-applications=${SELECTED_APPS} \
    --include-secrets \
    --include-volume-data \
    --cron-schedule="30 3 * * *" \
    --backup-retain-days=1
```

## Backup Manual
```bash
gcloud beta container backup-restore backups create manual-01 \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --backup-plan=${KUBERNETES_CLUSTER_PREFIX}-backup-plan \
    --wait-for-completion

Creating backup manual-01...done.
Waiting for backup to complete... Backup state: IN_PROGRESS.
Backup completed. Backup state: SUCCEEDED

gcloud beta container backup-restore backups list \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --backup-plan=${KUBERNETES_CLUSTER_PREFIX}-backup-plan

NAME: manual-01
LOCATION: us-central1
BACKUP_PLAN: redis-backup-plan
CREATE_TIME: 2024-08-06T03:03:24 UTC
COMPLETE_TIME: 2024-08-06T03:04:46 UTC
STATE: SUCCEEDED

gcloud beta container backup-restore backups describe manual-01 \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --backup-plan=${KUBERNETES_CLUSTER_PREFIX}-backup-plan

clusterMetadata:
  backupCrdVersions:
    backupjobs.gkebackup.gke.io: v1
    protectedapplicationgroups.gkebackup.gke.io: v1
    protectedapplications.gkebackup.gke.io: v1
    restorejobs.gkebackup.gke.io: v1
  ...
  gkeVersion: v1.29.6-gke.1254000
  k8sVersion: '1.29'
completeTime: '2024-08-06T03:04:46.100083700Z'
configBackupSizeBytes: '715010'
containsSecrets: true
containsVolumeData: true
createTime: '2024-08-06T03:03:24.219718795Z'
deleteLockExpireTime: '2024-08-06T03:03:24.214172425Z'
etag: '8'
manual: true
...
podCount: 6
resourceCount: 426
retainDays: 1
retainExpireTime: '2024-08-07T03:54:24.214172425Z'
selectedApplications:
  namespacedNames:
  - name: protected-application-redis
    namespace: ns-redis
sizeBytes: '741442'
state: SUCCEEDED
uid: 66e40e1e-6014-43e1-aa49-32b67777c2ef
updateTime: '2024-08-06T03:04:48.307460668Z'
volumeCount: 1

gcloud beta container backup-restore volume-backups list \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --backup-plan=${KUBERNETES_CLUSTER_PREFIX}-backup-plan \
    --backup=manual-01

NAME: vb-52d07d5f-9c0c-4390-a927-3a2f317043fd
LOCATION: us-central1
BACKUP_PLAN: redis-backup-plan
BACKUP: manual-01
SOURCE_PVC: ns-redis/redisfailover-persistent-data-rfr-my-cluster-1
CREATE_TIME: 2024-08-06T03:03:33 UTC
COMPLETE_TIME: 2024-08-06T03:04:45 UTC
STATE: SUCCEEDED

gcloud beta container backup-restore volume-backups describe vb-52d07d5f-9c0c-4390-a927-3a2f317043fd \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --backup-plan=${KUBERNETES_CLUSTER_PREFIX}-backup-plan \
    --backup=manual-01

completeTime: '2024-08-06T03:04:45.881293534Z'
createTime: '2024-08-06T03:03:33.272794304Z'
diskSizeBytes: '2147483648'
etag: '6'
format: GCE_PERSISTENT_DISK
...
sourcePvc:
  name: redisfailover-persistent-data-rfr-my-cluster-1
  namespace: ns-redis
state: SUCCEEDED
storageBytes: '26432'
updateTime: '2024-08-06T03:04:45.904165915Z'
...
```

## Remoção das chaves
```bash
kubectl exec -it redis-client -- /bin/sh

redis-cli -h redis-my-cluster -a $PASS --no-auth-warning FLUSHALL
exit
```

## Plano de Restauraçao
```bash
gcloud beta container backup-restore restore-plans create ${KUBERNETES_CLUSTER_PREFIX}-restore-plan \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --cluster=projects/${PROJECT_ID}/locations/${REGION}/clusters/${KUBERNETES_CLUSTER_PREFIX}-cluster \
    --selected-applications=${SELECTED_APPS} \
    --backup-plan=projects/${PROJECT_ID}/locations/${REGION}/backupPlans/${KUBERNETES_CLUSTER_PREFIX}-backup-plan \
    --namespaced-resource-restore-mode=delete-and-restore \
    --cluster-resource-conflict-policy=use-backup-version \
    --cluster-resource-scope-no-group-kinds \
    --volume-data-restore-policy=restore-volume-data-from-backup
```

## Restauração
```bash
gcloud beta container backup-restore restores create manual-01 \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --restore-plan=${KUBERNETES_CLUSTER_PREFIX}-restore-plan \
    --backup=projects/${PROJECT_ID}/locations/${REGION}/backupPlans/${KUBERNETES_CLUSTER_PREFIX}-backup-plan/backups/manual-01 \
    --wait-for-completion

kubectl get pods -l redisfailovers.databases.spotahome.com/name=my-cluster --watch

NAME                              READY   STATUS              RESTARTS   AGE
rfr-my-cluster-0                  2/2     Running             0          42m
rfr-my-cluster-1                  2/2     Running             0          42m
rfr-my-cluster-2                  2/2     Running             0          42m
rfs-my-cluster-7d976dcbcb-bgsts   2/2     Running             0          42m
rfs-my-cluster-7d976dcbcb-lqql6   2/2     Running             0          42m
rfs-my-cluster-7d976dcbcb-q66md   2/2     Running             0          42m
...
rfs-my-cluster-7d976dcbcb-lqql6   2/2     Terminating         0          43m
rfs-my-cluster-7d976dcbcb-bgsts   2/2     Terminating         0          43m
rfs-my-cluster-7d976dcbcb-q66md   2/2     Terminating         0          43m
rfr-my-cluster-0                  2/2     Terminating         0          43m
rfr-my-cluster-2                  2/2     Terminating         0          43m
rfr-my-cluster-1                  2/2     Terminating         0          43m
...
rfs-my-cluster-7d976dcbcb-pxthl   0/2     Pending             0          0s
rfs-my-cluster-7d976dcbcb-vlnqd   0/2     Pending             0          0s
rfs-my-cluster-7d976dcbcb-bz6sc   0/2     Pending             0          0s
rfs-my-cluster-7d976dcbcb-pxthl   0/2     Init:0/1            0          1s
rfs-my-cluster-7d976dcbcb-vlnqd   0/2     Init:0/1            0          0s
rfs-my-cluster-7d976dcbcb-bz6sc   0/2     Init:0/1            0          0s
rfs-my-cluster-7d976dcbcb-pxthl   0/2     PodInitializing     0          2s
rfs-my-cluster-7d976dcbcb-vlnqd   0/2     PodInitializing     0          1s
rfs-my-cluster-7d976dcbcb-bz6sc   0/2     PodInitializing     0          2s
rfs-my-cluster-7d976dcbcb-pxthl   1/2     Running             0          3s
rfs-my-cluster-7d976dcbcb-vlnqd   1/2     Running             0          2s
rfs-my-cluster-7d976dcbcb-bz6sc   1/2     Running             0          3s
rfs-my-cluster-7d976dcbcb-pxthl   2/2     Running             0          41s
rfs-my-cluster-7d976dcbcb-vlnqd   2/2     Running             0          40s
rfs-my-cluster-7d976dcbcb-bz6sc   2/2     Running             0          40s
...
rfr-my-cluster-0                  0/2     Pending             0          0s
rfr-my-cluster-2                  0/2     Pending             0          0s
rfr-my-cluster-1                  0/2     Pending             0          0s
rfr-my-cluster-0                  0/2     ContainerCreating   0          25s
rfr-my-cluster-2                  0/2     ContainerCreating   0          25s
rfr-my-cluster-1                  0/2     ContainerCreating   0          25s
rfr-my-cluster-0                  1/2     Running             0          34s
rfr-my-cluster-2                  1/2     Running             0          35s
rfr-my-cluster-1                  1/2     Running             0          38s
rfr-my-cluster-0                  2/2     Running             0          64s
rfr-my-cluster-2                  2/2     Running             0          64s
rfr-my-cluster-1                  2/2     Running             0          76s

gcloud beta container backup-restore restores list \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --restore-plan=${KUBERNETES_CLUSTER_PREFIX}-restore-plan

NAME: manual-01
LOCATION: us-central1
RESTORE_PLAN: redis-restore-plan
BACKUP: manual-01
CREATE_TIME: 2024-08-06T03:22:54 UTC
COMPLETE_TIME: 2024-08-06T03:23:31 UTC
STATE: SUCCEEDED

gcloud beta container backup-restore restores describe manual-01 \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --restore-plan=${KUBERNETES_CLUSTER_PREFIX}-restore-plan

...
completeTime: '2024-08-06T03:23:31.659950313Z'
createTime: '2024-08-06T03:22:54.844197802Z'
etag: '4'
...
resourcesExcludedCount: 10
resourcesRestoredCount: 16
restoreConfig:
  clusterResourceConflictPolicy: USE_BACKUP_VERSION
  clusterResourceRestoreScope:
    noGroupKinds: true
  namespacedResourceRestoreMode: DELETE_AND_RESTORE
  selectedApplications:
    namespacedNames:
    - name: protected-application-redis
      namespace: ns-redis
  volumeDataRestorePolicy: RESTORE_VOLUME_DATA_FROM_BACKUP
state: SUCCEEDED
stateReason: restore is successful
uid: e70067e4-2579-4464-8184-4729e3a6da00
updateTime: '2024-08-06T03:23:31.677016758Z'
volumesRestoredCount: 3

gcloud beta container backup-restore volume-restores list \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --restore-plan=${KUBERNETES_CLUSTER_PREFIX}-restore-plan \
    --restore=manual-01

NAME: vr-a60f732a4c108213
LOCATION: us-central1
RESTORE_PLAN: redis-restore-plan
RESTORE: manual-01
TARGET_PVC: ns-redis/redisfailover-persistent-data-rfr-my-cluster-0
CREATE_TIME: 2024-08-06T03:23:30 UTC
COMPLETE_TIME: 2024-08-06T03:24:04 UTC
STATE: SUCCEEDED

NAME: vr-a60f752a4c108579
LOCATION: us-central1
RESTORE_PLAN: redis-restore-plan
RESTORE: manual-01
TARGET_PVC: ns-redis/redisfailover-persistent-data-rfr-my-cluster-2
CREATE_TIME: 2024-08-06T03:23:30 UTC
COMPLETE_TIME: 2024-08-06T03:24:04 UTC
STATE: SUCCEEDED

NAME: vr-a60f722a4c108060
LOCATION: us-central1
RESTORE_PLAN: redis-restore-plan
RESTORE: manual-01
TARGET_PVC: ns-redis/redisfailover-persistent-data-rfr-my-cluster-1
CREATE_TIME: 2024-08-06T03:23:30 UTC
COMPLETE_TIME: 2024-08-06T03:24:04 UTC
STATE: SUCCEEDED
```

## Avaliação das chaves restauradas
```bash
kubectl exec -it redis-client -- /bin/sh

redis-cli -h redis-my-cluster -a $PASS --no-auth-warning SCAN 0
exit
```

## Exclusão de uma Restauraçao
```bash
gcloud beta container backup-restore restores delete manual-01 \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --restore-plan=${KUBERNETES_CLUSTER_PREFIX}-restore-plan
```

## Exclusão do Plano de Restauração
```bash
gcloud beta container backup-restore restore-plans delete ${KUBERNETES_CLUSTER_PREFIX}-restore-plan \
    --project=${PROJECT_ID} \
    --location=${REGION}
```

## Exclusão de um Backup
```bash
gcloud beta container backup-restore backups delete manual-01 \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --backup-plan=${KUBERNETES_CLUSTER_PREFIX}-backup-plan

gcloud beta container backup-restore backups delete sched-2024-0806-0330 \
    --project=${PROJECT_ID} \
    --location=${REGION} \
    --backup-plan=${KUBERNETES_CLUSTER_PREFIX}-backup-plan
```

## Exclusão do Plano de Backup
```bash
gcloud beta container backup-restore backup-plans delete ${KUBERNETES_CLUSTER_PREFIX}-backup-plan \
    --project=${PROJECT_ID} \
    --location=${REGION}
```

# Exclusão dos recursos
```bash
terraform -chdir=iac/gke-standard destroy -var project_id=${PROJECT_ID} \
  -var region=${REGION} \
  -var cluster_prefix=${KUBERNETES_CLUSTER_PREFIX}

export disk_list=$(gcloud compute disks list --filter="-users:* AND labels.goog-k8s-cluster-name=${KUBERNETES_CLUSTER_PREFIX}-cluster" --format "value[separator=|](name,zone)")

for i in $disk_list; do
  disk_name=$(echo $i| cut -d'|' -f1)
  disk_zone=$(echo $i| cut -d'|' -f2|sed 's|.*/||')
  echo "Deleting $disk_name"
  gcloud compute disks delete $disk_name --zone $disk_zone --quiet
done
```

# Referências
- https://cloud.google.com/kubernetes-engine/docs/tutorials/stateful-workloads/spotahome-redis?hl=pt-br

- https://github.com/spotahome/redis-operator

- https://cloud.google.com/kubernetes-engine/docs/add-on/backup-for-gke/how-to/protected-application?hl=pt-br

- https://cloud.google.com/kubernetes-engine/docs/add-on/backup-for-gke/how-to/backup-plan?hl=pt-br#create

- https://cloud.google.com/kubernetes-engine/docs/add-on/backup-for-gke/how-to/backup?hl=pt-br

- https://cloud.google.com/kubernetes-engine/docs/add-on/backup-for-gke/how-to/restore-plan?hl=pt-br#create_a_restore_plan

- https://cloud.google.com/kubernetes-engine/docs/add-on/backup-for-gke/how-to/restore?hl=pt-br

- https://www.cloudskillsboost.google/catalog_lab/5172