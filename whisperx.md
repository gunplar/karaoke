```
curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu$(lsb_release -sr | sed -e 's/\.//')/x86_64/3bf863cc.pub | sudo gpg --dearmor -o /etc/apt/keyrings/cuda-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/cuda-archive-keyring.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu$(lsb_release -sr | sed -e 's/\.//')/x86_64 /" | sudo tee /etc/apt/sources.list.d/cuda.list
sudo apt-get install libcudnn8=8.9.2.26-1+cuda12.1
```
Example `ubuntu2204`
