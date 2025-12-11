FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive

# Work directory
WORKDIR /app

# 1. System + Python + tools
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        build-essential \
        git \
        curl \
        jq \
        software-properties-common \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# 2. Install Node.js 22 (for React frontend)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update -y && \
    apt-get install -y nodejs && \
    node --version && npm --version && \
    rm -rf /var/lib/apt/lists/*

# 3. Install Python dependencies using requirements.txt
COPY requirements.txt /app/requirements.txt
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# 4. Install Node dependencies
COPY package.json package-lock.json /app/
RUN npm ci

# 5. Copy the rest of the project
COPY . /app

# 6. Build frontend
RUN npm run build

# 7. Start app (docker-compose can override this)
CMD ["npm", "start"]
