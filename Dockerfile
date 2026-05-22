# ── Stage 1: Build ──────────────────────────────────────────────
FROM debian:trixie-slim AS builder

RUN apt-get update
RUN apt-get install -y --no-install-recommends gcc libgl-dev libglu1-mesa-dev freeglut3-dev git ca-certificates
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .
RUN gcc -O3 -Wall -Wextra -o nw -DTARGET_GLUT color.c config.c display.c main.c network.c simulation.c vector.c -lGL -lGLU -lglut -lm

# ── Stage 2: Runtime ─────────────────────────────────────────────
FROM debian:trixie-slim

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    # OpenGL (Software-Rendering via Mesa)
    libglut3.12 libglu1 libgl1 mesa-utils \
    # Virtuelles Display
    xvfb \
    # VNC-Server
    x11vnc \
    # noVNC (Browser-Client)
    novnc websockify \
    # Telnet / SSH connection
    socat openssh-server \
    # Supervisor (startet alle Prozesse)
    supervisor
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /src/nw .
COPY --from=builder /src/font24.raw .

COPY ./docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY ./docker/index.html /usr/share/novnc/index.html

COPY ./docker/run_newtonwars.sh /app/run_newtonwars.sh
COPY ./docker/sshd_config.conf /etc/ssh/sshd_config.d/newtonwars.conf
RUN chmod +x /app/run_newtonwars.sh

RUN useradd --no-create-home --shell /bin/sh nw

EXPOSE 8080 3490 22

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
