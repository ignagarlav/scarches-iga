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

# 3) Add conda to PATH
ENV PATH="/opt/miniconda/bin:${PATH}"

# Ensure all RUN commands use /bin/bash
SHELL ["/bin/bash", "-c"]

# 4) Copy your environment.yml into the container
#    This file should define the environment name, e.g. name: scarches
COPY environment.yml /tmp/environment.yml

# 5) Create the Conda environment inside Docker
RUN conda init bash \
    && source ~/.bashrc \
    && conda env create -f /tmp/environment.yml \
    && conda clean -afy

# 6) Clone and install scarches from GitHub
RUN git clone https://github.com/theislab/scarches /tmp/scarches && \
    conda run -n scarches pip install -e /tmp/scarches

# 7) Register the IPython kernel (named "scarches")
RUN conda run -n scarches python -m ipykernel install --user \
    --name scarches --display-name "scArches Environment"

# 8) Make the scarches environment the default PATH
#    This means commands like 'python' or 'jupyter' will come from the env
ENV PATH="/opt/miniconda/envs/scarches/bin:${PATH}"

# 9) Default command: start a bash shell
CMD ["/bin/bash"]

