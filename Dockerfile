# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Install Miniconda
RUN apt-get update && apt-get install -y wget bzip2 \
    && if [ "$(uname -m)" = "aarch64" ]; then \
           wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh; \
       else \
           wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh; \
       fi \
    && bash /tmp/miniconda.sh -b -p /root/miniconda \
    && rm /tmp/miniconda.sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Mamba using Miniconda and create a new environment with Python 3.11
RUN /root/miniconda/bin/conda install mamba -c conda-forge -y \
    && /root/miniconda/bin/mamba create -n team2_env python=3.11 -y \
    && /root/miniconda/bin/mamba clean --all -f -y

# Set environment path to use team2_env and ensure bash is used
ENV PATH="/root/miniconda/envs/team2_env/bin:$PATH"

# Use bash shell to activate the environment in the next steps
SHELL ["/bin/bash", "-c"]

# Copy requirements.txt into the container
COPY requirements.txt /app/requirements.txt

# Activate the environment and install packages from requirements.txt
RUN source /root/miniconda/bin/activate team2_env \
    && mamba install --yes --file /app/requirements.txt \
    && mamba clean --all -f -y

# Copy the rest of the current directory contents into the container
COPY . /app

# Expose ports for Streamlit and Jupyter
EXPOSE 5002
EXPOSE 8888

# Start both Streamlit and Jupyter
CMD ["bash", "-c", "streamlit run app.py --server.port=5002 & jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root"]
