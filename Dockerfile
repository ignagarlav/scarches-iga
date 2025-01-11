# Use a lightweight base image
FROM ubuntu:20.04

# Avoid interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive

# 1) Install system dependencies
#    We also install 'git' so we can clone the scarches repo inside Docker.
RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    git \
    && rm -rf /var/lib/apt/lists/*

# 2) Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/miniconda \
    && rm /tmp/miniconda.sh

# Make sure RUN commands use /bin/bash
SHELL ["/bin/bash", "-c"]

# 4) Clone scArches repo
RUN git clone https://github.com/theislab/scarches /tmp/scarches

# 5) Create scarches environment using scArches’ own YAML
RUN conda env create -f /tmp/scarches/envs/scarches_linux.yaml \
    && conda clean -afy

# 6) Register scArches kernel (optional but recommended)
RUN conda run -n scarches python -m ipykernel install --sys-prefix \
    --name scarches --display-name "scArches Environment"

# 7) Default to using PATH from scarches environment
ENV PATH="/opt/miniconda/envs/scarches/bin:${PATH}"

# 8) Start a bash shell by default
CMD ["/bin/bash"]
