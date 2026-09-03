Docker networking homework. Screenshots are in the screenshots folder. Ran on minty@homelab.

01-networks-ping.png shows three networks and that backend is on frontend-net and backend-net. frontend can ping backend. backend can ping database. frontend cannot reach database.

02-bind-mount.png shows nginx with a bind mount of Hello students, then the file edited and curl showing Hello students - updated without restarting the container.

Host network and overlay: host network shares the host ports. overlay is for multi-host Docker and needs swarm. Not required on one laptop.
