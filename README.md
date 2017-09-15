# Repository Manager (Repoman)

## What does it do?

Repoman assists the configuration of custom repository clients as well as providing tools to mirror said repositories to a local server. 

## Installation

* Clone the repository to `/opt/repoman/`

```bash
cd /opt/
git clone https://github.com/alces-software/repoman.git
```

## Usage

* To setup a client (include files can be found under `templates/`)

```bash
/opt/repoman/repoman.rb generate --distro centos7 --include base.upstream,lustre.upstream --outfile /etc/yum.repos.d/myrepo.conf
```

* To setup a server

```bash
/opt/repoman/repoman.rb mirror --distro rhel7 --include base.local --reporoot /opt/alces/repo
```

* To resync and existing repository

```bash
/opt/repoman/repoman.rb mirror --reporoot /opt/alces/repo --no-conf
```
