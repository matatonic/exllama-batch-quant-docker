FROM ghcr.io/theroyallab/tabbyapi:latest

RUN apt-get update && apt-get install --no-install-recommends -y git vim bash && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/turboderp-org/exllamav2 /app/exllamav2 --single-branch
RUN git clone https://github.com/turboderp-org/exllamav3 /app/exllamav3 --single-branch
RUN pip install datasets

ENTRYPOINT []
ENV CLI_ARGS="python3 exllamav2/convert.py"
CMD ${CLI_ARGS}
