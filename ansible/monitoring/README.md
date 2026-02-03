# Ansible Monitoring Stack – Architecture & Deployment Guide

## 1. What this project does (High‑level)

This Ansible project installs and configures a **full monitoring & observability stack** on Linux servers using roles.

It deploys and wires together:

* **Prometheus** – metrics collection
* **Alertmanager** – alert routing
* **Node Exporter** – host metrics
* **MySQL Exporter** – MySQL metrics
* **Blackbox Exporter** – endpoint probing
* **Loki + Promtail** – log aggregation
* **Grafana** – dashboards & visualization

Everything is automated using **Ansible roles, templates, handlers, and inventory‑based configuration**.

---

## 2. Directory Structure & What Goes Where

```
ansible/
├── inventory/
│   ├── inventory.ini
│   ├── inventory.yml
│   └── group_vars/
│       ├── all.yml
│       └── prometheus.yml
│
├── roles/
│   ├── site.yml
│   ├── prometheus/
│   ├── alertmanager/
│   ├── grafana/
│   ├── loki/
│   └── exporters/
│       ├── node_exporter/
│       ├── mysql_exporter/
│       └── blackbox_exporter/
```

### inventory/

Defines **where things are installed**.

* `inventory.ini / inventory.yml`

  * List of servers
  * Grouping (prometheus, grafana, exporters, etc.)

* `group_vars/all.yml`

  * Global variables shared across all roles
  * Ports, paths, common settings

* `group_vars/prometheus.yml`

  * Prometheus‑specific configuration
  * Scrape targets & exporters

---

## 3. Role‑by‑Role Breakdown

### 3.1 site.yml (Entry Point)

`roles/site.yml` is the **main playbook**.

It:

* Decides which roles run
* Controls execution order

Typical flow:

1. Install exporters
2. Install Prometheus
3. Install Alertmanager
4. Install Loki + Promtail
5. Install Grafana

---

### 3.2 Prometheus Role

**Path:** `roles/prometheus/`

**What it does:**

* Installs Prometheus binary
* Creates Prometheus systemd service
* Generates Prometheus config

**Key files:**

* `tasks/main.yml` – install & configure Prometheus
* `templates/prometheus.yml.j2` – scrape configuration
* `templates/rules.yml.j2` – alerting rules
* `templates/prometheus.service.j2` – systemd unit

**How config works:**

* Uses variables from:

  * `group_vars/prometheus.yml`
  * `group_vars/all.yml`
* Inventory groups define scrape targets automatically

---

### 3.3 Alertmanager Role

**Path:** `roles/alertmanager/`

**What it does:**

* Installs Alertmanager
* Configures alert routing
* Registers systemd service

**Key files:**

* `templates/alertmanager.yml.j2` – routing & receivers
* `templates/alertmanager.service.j2`
* `handlers/main.yml` – restart on config change

---

### 3.4 Exporters

#### Node Exporter

**Path:** `roles/exporters/node_exporter/`

* Exposes CPU, memory, disk, network metrics
* Installed on **every monitored node**

Files:

* `templates/node_exporter.service.j2`

---

#### MySQL Exporter

**Path:** `roles/exporters/mysql_exporter/`

* Exposes MySQL metrics

Files:

* `templates/my.cnf.j2` – DB credentials
* `templates/mysql_exporter.service.j2`

> ⚠️ Requires MySQL credentials via variables

---

#### Blackbox Exporter

**Path:** `roles/exporters/blackbox_exporter/`

* Probes HTTP, HTTPS, TCP endpoints

Files:

* `templates/blackbox.yml.j2`
* `templates/blackbox.service.j2`

Targets defined in Prometheus config

---

### 3.5 Loki & Promtail

**Path:** `roles/loki/`

**What it does:**

* Installs Loki (log store)
* Installs Promtail (log shipper)

Files:

* `templates/loki-config.yml.j2`
* `templates/promtail.yml.j2`
* `templates/loki.service.j2`
* `templates/promtail.service.j2`

**How logs work:**

* Promtail tails files defined in config
* Sends logs to Loki
* Labels are attached (job, app, env)

---

### 3.6 Grafana

**Path:** `roles/grafana/`

**What it does:**

* Installs Grafana
* Configures data sources
* Auto‑imports dashboards

Files:

* `files/prometheus-datasource.yml`
* `templates/loki-datasource.yml.j2`
* `templates/dashboards.yml.j2`
* Dashboard JSON templates

Grafana comes up **ready‑to‑use**, no manual clicks.

---

## 4. Configuration Flow (Very Important)

```
Inventory → group_vars → role defaults → templates → services
```

Example:

* You add a server to `inventory.ini`
* Prometheus auto‑scrapes it
* Grafana dashboards show metrics
* Alerts fire automatically

No hardcoding of IPs in templates.

---

## 5. Deployment Steps (How to Use This)

### Step 1: Prerequisites

* Ansible installed (>=2.12)
* SSH access to all servers
* Python available on targets

---

### Step 2: Update Inventory

Edit:

* `inventory/inventory.ini` or `inventory.yml`

Add hosts under correct groups:

* prometheus
* grafana
* exporters

---

### Step 3: Configure Variables

Edit:

* `group_vars/all.yml`
* `group_vars/prometheus.yml`

Set:

* Ports
* Alert receivers
* MySQL credentials
* Log paths

---

### Step 4: Run Deployment

From `ansible/` directory:

```bash
ansible-playbook -i inventory/inventory.ini roles/site.yml
```

---

## 6. What Happens After Deployment

* Services run via systemd
* Prometheus scrapes exporters
* Loki collects logs
* Grafana shows dashboards
* Alerts fire via Alertmanager

Zero manual setup required.

---

## 7. Typical Customizations

* Add new exporter → new role
* Add new log path → promtail config
* Add alerts → rules.yml.j2
* Add dashboards → Grafana templates

---

## 8. Summary

This repo is a **production‑ready monitoring stack** fully automated with Ansible.

It is:

* Scalable
* Repeatable
* Idempotent
* Environment‑agnostic

If you want, I can:

* Create a **README.md**
* Draw **architecture diagrams**
* Add **blue/green monitoring separation**
* Harden it for **production security**
