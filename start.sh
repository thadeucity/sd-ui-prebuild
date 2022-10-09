echo "pod started"

echo "installing dependencies"

apt-get install -y python3
apt-get install -y python3-pip
apt-get install -y python3-venv
# apt-get install -y python3-opencv // FIX Later

python3 -V

echo "dependencies installed"
echo "---------------------------------"
echo "installing pip libs"

pip install gdown
pip install jupyterlab
pip install ipywidgets
pip install jupyter-archive

jupyter nbextension enable --py widgetsnbextension

echo "Libs installed"
echo "---------------------------------"
echo "Copy python actions to workspace"

cp /workspace/sd-ui-prebuild/run-ui.ipynb /workspace/run-ui.ipynb

echo "Copied"
echo "---------------------------------"
echo "clone stable-diffusion webui"
cd /workspace
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

if [[ $PUBLIC_KEY ]]
then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >> authorized_keys
    chmod 700 -R ~/.ssh
    cd /
    service ssh start
fi

if [[ $JUPYTER_PASSWORD ]]
then
    cd /
    jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace
else
    sleep infinity
fi