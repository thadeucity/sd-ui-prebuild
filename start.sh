echo "pod started"

echo "installing dependencies"

apt-get install -y python3
apt-get install -y python3-pip
apt-get install -y python3-venv
apt-get install -y libgl1

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
echo "Clone stable-diffusion webui"
cd /workspace
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

echo "Repo Cloned" 
echo "---------------------------------"
echo "Add extra dependencies"
cd stable-diffusion-webui

mkdir repositories
git clone https://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion
git clone https://github.com/CompVis/taming-transformers.git repositories/taming-transformers
git clone https://github.com/sczhou/CodeFormer.git repositories/CodeFormer
git clone https://github.com/salesforce/BLIP.git repositories/BLIP

pip install transformers==4.19.2 diffusers invisible-watermark --prefer-binary

# install k-diffusion
pip install git+https://github.com/crowsonkb/k-diffusion.git --prefer-binary

# (optional) install GFPGAN (face restoration)
pip install git+https://github.com/TencentARC/GFPGAN.git --prefer-binary

# (optional) install requirements for CodeFormer (face restoration)
pip install -r repositories/CodeFormer/requirements.txt --prefer-binary

# install requirements of web ui
pip install -r requirements.txt  --prefer-binary

# update numpy to latest version
pip install -U numpy  --prefer-binary


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