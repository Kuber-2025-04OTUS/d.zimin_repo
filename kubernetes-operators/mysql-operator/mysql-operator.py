import kopf
import kubernetes.client as k8s
from kubernetes.client.rest import ApiException
from kubernetes import config, client
import os

try:
    config.load_incluster_config()
except config.config_exception.ConfigException:
    config.load_kube_config()

core = k8s.CoreV1Api()
apps = k8s.AppsV1Api()

@kopf.on.create('otus.homework', 'v1', 'mysqls')
def mysql_on_create(spec, name, namespace, logger, **kwargs):
    storage_size = spec.get('storage', '1Gi')
    labels = {"app": name}

    logger.info("Creating pv, pvc for mysql data and svc...")

    # PV
    pv = k8s.V1PersistentVolume(
        metadata=k8s.V1ObjectMeta(name=f"{name}-pv"),
        spec=k8s.V1PersistentVolumeSpec(
            access_modes=["ReadWriteOnce"],
            capacity={"storage": storage_size},
            host_path=k8s.V1HostPathVolumeSource(path=f"/mnt/data/{name}"),
            persistent_volume_reclaim_policy="Delete",
            storage_class_name=""  # <--- добавь это
        )
    )
    try:
        core.create_persistent_volume(pv)
    except ApiException as e:
        if e.status != 409:
            raise

    # PVC
    pvc = k8s.V1PersistentVolumeClaim(
        metadata=k8s.V1ObjectMeta(name=f"{name}-pvc", namespace=namespace),
        spec=k8s.V1PersistentVolumeClaimSpec(
            access_modes=["ReadWriteOnce"],
            resources=k8s.V1ResourceRequirements(requests={"storage": storage_size}),
            volume_name=f"{name}-pv",
            storage_class_name=""  # <--- добавь это
        )
    )
    core.create_namespaced_persistent_volume_claim(namespace, pvc)

    # Service
    svc = k8s.V1Service(
        metadata=k8s.V1ObjectMeta(name=f"{name}-svc", namespace=namespace),
        spec=k8s.V1ServiceSpec(
            selector=labels,
            ports=[k8s.V1ServicePort(port=3306, target_port=3306)]
        )
    )
    core.create_namespaced_service(namespace, svc)

    # Deployment
    dep = k8s.V1Deployment(
        metadata=k8s.V1ObjectMeta(name=name, namespace=namespace),
        spec=k8s.V1DeploymentSpec(
            replicas=1,
            selector=k8s.V1LabelSelector(match_labels=labels),
            template=k8s.V1PodTemplateSpec(
                metadata=k8s.V1ObjectMeta(labels=labels),
                spec=k8s.V1PodSpec(containers=[
                    k8s.V1Container(
                        name="mysql",
                        image="mysql:8",
                        ports=[k8s.V1ContainerPort(container_port=3306)],
                        env=[
                            k8s.V1EnvVar(name="MYSQL_ROOT_PASSWORD", value="admin")
                        ],
                        volume_mounts=[k8s.V1VolumeMount(
                            name="mysql-persistent-storage", mount_path="/var/lib/mysql"
                        )]
                    )
                ],
                volumes=[k8s.V1Volume(
                    name="mysql-persistent-storage",
                    persistent_volume_claim=k8s.V1PersistentVolumeClaimVolumeSource(
                        claim_name=f"{name}-pvc"
                    )
                )])
            )
        )
    )
    apps.create_namespaced_deployment(namespace, dep)
    logger.info(f"MySQL instance {name} and its children resources created!")


@kopf.on.delete('otus.homework', 'v1', 'mysqls')
def mysql_on_delete(name, namespace, logger, **kwargs):
    logger.info(f"Deleting resources for {name}...")

    # Delete Deployment
    apps.delete_namespaced_deployment(name=name, namespace=namespace)

    # Delete Service
    core.delete_namespaced_service(name=f"{name}-svc", namespace=namespace)

    # Delete PVC
    core.delete_namespaced_persistent_volume_claim(name=f"{name}-pvc", namespace=namespace)

    # Delete PV
    try:
        core.delete_persistent_volume(name=f"{name}-pv")
    except ApiException as e:
        if e.status != 404:
            raise

    logger.info(f"MySQL {name} resources deleted.")
