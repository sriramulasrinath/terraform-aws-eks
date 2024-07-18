#!bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "$R$2...FAILED$N"
    exit 1
  else
    echo -e "$G$2...SUCCESS$N"
  fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

# docker
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
VALIDATE $? "Docker installation"

#install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin
eksctl version
VALIDATE $? "eksctl installation"

#install kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/amd64/kubectl
chmod +x ./kubectl &>>$LOGFILE
mv kubectl /usr/local/bin/kubectl &>>$LOGFILE
VALIDATE $? "installed kubectl....$Y SKIPPING $N" 


#installing kubens
git clone https://github.com/ahmetb/kubectx /opt/kubectx &>>$LOGFILE
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens
VALIDATE $? "kubens installed....$Y SKIPPING $N"

dnf install mysql -y
VALIDATE $? "MySQL installation"
# extend disk
# growpart /dev/nvme0n1 4 &>>$LOGFILE
# lvextend -l +50%FREE /dev/RootVG/rootVol &>>$LOGFILE
# lvextend -l +50%FREE /dev/RootVG/varVol &>>$LOGFILE
# xfs_growfs / &>>$LOGFILE
# xfs_growfs /var &>>$LOGFILE
# VALIDATE $? "Disk Resized....$Y SKIPPING $N" 



#installing ebs drivers
# kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.32" #installing ebs drivers
# VALIDATE $? "installed ebs drivers....$Y SKIPPING $N"

# #installing efs drivers
# kubectl kustomize \
#     "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-2.0" > public-ecr-driver.yaml #installing eks drivers
# VALIDATE $? "installed efs drivers....$Y SKIPPING $N"

#installing k9s
curl -sS https://webinstall.dev/k9s | bash #k9s installing 
VALIDATE $? "installed k9s....$Y SKIPPING $N"

#cloning git repositories
git clone https://github.com/sriramulasrinath/k8-expense-volumes.git
git clone https://github.com/sriramulasrinath/k8-eksctl.git
git clone https://github.com/sriramulasrinath/k8-resources.git
git clone https://github.com/sriramulasrinath/helm-expense.git

#helm install
# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
# chmod 700 get_helm.sh
# ./get_helm.sh
# VALIDATE $? "installed HElM....$Y SKIPPING $N"

cd k8-eksctl &>>$LOGFILE
eksctl create cluster --config-file=eks.yml &>>$LOGFILE
VALIDATE $? "created eksctl cluster...$Y SKIPPING $N"

echo -e "${G}Log file: $LOGFILE${N}"

## FOR CREATE AUTHENTICATION TO EKS##
# eksctl utils associate-iam-oidc-provider \
#     --region <region-code> \ 
#     --cluster <your-cluster-name> \
#     --approve  

## PERMISSIONS FOR EC2 WORKER NODES TO CREATE LOADBALANCERS DYNAMICALLY  ##
# curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.8.1/docs/install/iam_policy.json


## CREATE THE ROLE ##
# aws iam create-policy \
#     --policy-name AWSLoadBalancerControllerIAMPolicy \
#     --policy-document file://iam-policy.json



# eksctl create iamserviceaccount \
# --cluster=<cluster-name> \
# --namespace=kube-system \
# --name=aws-load-balancer-controller \
# --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
# --override-existing-serviceaccounts \
# --region <region-code> \
# --approve

# helm repo add eks https://aws.github.io/eks-charts

# helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=<cluster-name> --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller


#Connect Kubectl to Eks Cluster
#aws eks update-kubeconfig --region region-code --name my-cluster
