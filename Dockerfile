# 파일명: Dockerfile
FROM ubuntu:20.04

# 필수 패키지 설치
RUN apt-get update && \
    apt-get install -yq tzdata && \
    ln -f /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata
RUN apt-get install -y \
    curl \
    docker.io \
    gnupg \
    ca-certificates \
    supervisor \
    iptables \
    net-tools \
    vim \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Kubernetes 패키지 다운로드 및 설치
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubelet" && \
    chmod +x kubelet && \
    mv kubelet /usr/local/bin/

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-proxy" && \
    chmod +x kube-proxy && \
    mv kube-proxy /usr/local/bin/

# SSH 설정 파일 복사 및 설정
RUN mkdir /var/run/sshd && echo 'root:root' | chpasswd && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# kubeconfig 디렉토리 생성 및 파일 복사
RUN mkdir -p /root/.kube
COPY ./kubeconfig /root/.kube/config

# Supervisor 설정 파일 추가
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 작업 디렉토리 설정
WORKDIR /etc/kubernetes

# 포트 열기
EXPOSE 22

# Supervisor로 프로세스 실행
CMD ["/usr/bin/supervisord"]
