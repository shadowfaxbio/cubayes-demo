NEXTFLOW_VERSION=25.10.6
APPTAINER_VERSION=1.4.5
curl -LR -o apptainer_${APPTAINER_VERSION}_amd64.deb https://github.com/apptainer/apptainer/releases/download/v${APPTAINER_VERSION}/apptainer_${APPTAINER_VERSION}_amd64.deb
sudo apt install -y ./apptainer_${APPTAINER_VERSION}_amd64.deb
rm apptainer_${APPTAINER_VERSION}_amd64.deb

curl -LR -o nextflow https://github.com/nextflow-io/nextflow/releases/download/v${NEXTFLOW_VERSION}/nextflow-${NEXTFLOW_VERSION}-dist
chmod +x nextflow
