rm -rf dockerImageReference.txt
rm -rf dockerImageStreamTag.txt

oc login https://api.ocp.nonpro.dsl:6443 -u kubeadmin -p DaSmC-icqXi-PXYwm-ui9E5
for i in $(oc get images -o jsonpath='{range .items[*]}{.dockerImageReference} {.dockerImageMetadata.Created} {.dockerImageMetadata.Size}{"\n"}{end}'|sed 's/@/ /'|sort -k1,1 -k3,3|egrep -v "registry.redhat.io|quay.io"|awk '{print $1}'|uniq)
do 
    oc get images -o jsonpath='{range .items[*]}{.dockerImageReference} {.dockerImageMetadata.Created} {.dockerImageMetadata.Size}{"\n"}{end}'|sed 's/@/ /'|sort -r -k1,1 -k3,3|grep -w ^$i|tail -n +4|awk '{print $2}' >> dockerImageReference.txt
    oc get images -o jsonpath='{range .items[*]}{.dockerImageReference} {.dockerImageMetadata.Created} {.dockerImageMetadata.Size}{"\n"}{end}'|sed 's/@/ /'|sort -r -k1,1 -k3,3|grep -w ^$i|tail -n +4|awk '{print $2}'|xargs -i oc delete image {}
done

for i in $(cat dockerImageReference.txt)
do 
    oc get imagestreamtag --all-namespaces|grep -i $i >> dockerImageStreamTag.txt
    oc get imagestreamtag --all-namespaces|grep -i $i|awk '{ system("oc delete istag/"$2" -n "$1) }'
done
