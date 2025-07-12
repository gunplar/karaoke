# Use Amazon Linux 2023 as the base image
FROM public.ecr.aws/amazonlinux/amazonlinux:2023

# Install dependencies
RUN yum -y update && \
    yum -y install \
        ffmpeg \
        python3 \
        unzip \
        zip \
        which \
        findutils \
        bash && \
    yum clean all

# Install pip (if not included)
RUN python3 -m ensurepip || true && \
    python3 -m pip install --upgrade pip

# Set workdir
WORKDIR /app

# Copy scripts and all repo files
COPY . /app

# (Optional) Install Python dependencies if tunesplit.py requires any
# RUN pip install -r requirements.txt

# Make scripts executable
RUN chmod +x mp3_to_mp4.sh process_audio.sh

# Default command (can be overridden)
CMD ["/bin/bash"]
