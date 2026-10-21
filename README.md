# Performance, Resource Utilization, and Cost Analysis of Web Applications: Virtual Machines vs. Docker Containers

SEN421 Cloud Architecture and Services, Fall 2026, Topic 2 Part A. The same FastAPI service is run under a 2 vCPU / 2 GB cap in Docker and in an Ubuntu 24.04 guest, then loaded with the same k6 script. AWS cost is a price-list projection. No cloud resource is created.

The request path is Fig. 1 in [`paper/report.tex`](paper/report.tex): k6 on the host calls `127.0.0.1:8000`, and only one of the two targets listens at a time.

## Run the container

From `Project/`:

```powershell
docker compose -f app/docker-compose.yml up --build -d
curl http://127.0.0.1:8000/health
```

The image is `sen421-api:latest`. Compose sets 2 CPUs and 2 GB. Stop it before starting the guest, because both use host port 8000:

```powershell
docker compose -f app/docker-compose.yml stop
```

## Run the guest

VirtualBox 7.2.22 on this host fell back to NEM (VT-x unavailable) and did not finish boot. The measured guest is QEMU 11.1.0 with WHPX, using the existing VMDK, 2 vCPU and 2048 MiB. The API is installed by `vm-setup/provision.sh` and started by systemd.

```powershell
& "C:\Program Files\qemu\qemu-system-x86_64.exe" -accel whpx,kernel-irqchip=off -cpu max -smp 2 -m 2048 -drive file="C:\Users\eavci\VirtualBox VMs\sen421-topic2\ubuntu-24.04-amd64-disk001.vmdk",format=vmdk,if=ide -netdev user,id=n0,hostfwd=tcp:127.0.0.1:2224-:22,hostfwd=tcp:127.0.0.1:8000-:8000 -device virtio-net-pci,netdev=n0 -display none
curl http://127.0.0.1:8000/health
```

The guest address inside the VM is `10.0.2.15`. The host reaches it through the forward above.

## Load test

k6 2.2.0, 50 virtual users, 30 seconds, `/compute` and `/payload`, three runs, 15 seconds between runs:

```powershell
powershell -File load-tests/run_benchmarks.ps1 -ResultDir results/docker
powershell -File load-tests/run_benchmarks.ps1 -BaseUrl http://127.0.0.1:8000 -ResultDir results/vm
```

Summaries are `load-tests/results/<target>/results_run1.json` through `results_run3.json`. A non-zero k6 exit means a threshold was missed. The JSON is still written.

## Result summary

Mean of three runs ± sample standard deviation (divisor n−1). Docker run 3 missed the p95 &lt; 500 ms bar. All three guest runs missed both the HTTP 200 rate and the p95 bar. Those runs were kept.

| Metric | Docker | QEMU/WHPX |
|---|---|---|
| Median (ms) | 224.121 ± 75.998 | 214.347 ± 70.009 |
| p95 (ms) | 585.389 ± 194.322 | 734.976 ± 67.310 |
| Requests/s | 174.925 ± 8.026 | 157.792 ± 6.847 |
| Image or disk | 49.701 MiB | 2.792 GB file |
| Ready time (s) | 1.450 ± 0.221 | 47.660 ± 6.244 |

Monthly list price in `eu-central-1`, 730 hours, accessed 21 October 2026, free-tier allowance not subtracted: EC2 `t3.micro` + 20 GB gp3 = 28.35872 USD; Fargate 0.25 vCPU / 0.5 GB = 28.05707 USD. Experiment spend: 0 USD.

Repository: https://github.com/Emre1071/sen421-cloud-vm-vs-docker

Report: `paper/report.tex`. Slides: `paper/slides.md` (8 slides).
