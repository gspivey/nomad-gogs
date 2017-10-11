job "gogs" {
  datacenters = ["dc1"]

  type = "service"

    task "gitServer" {

      driver = "docker" 
      # Enviornemt Variable Managment (via vault?)
      env {
        POSTGRES_PASSWORD = "pg1234!"
        POSTGRES_USER = "gogs"
        POSTGRES_DB = "gogs" 
      }

      config {
        image = "postgres:9.5"
        # requires gogs network to exist
        network_mode = "gogs"
        network_aliases = [
          "postgres",
          "postgres-${NOMAD_ALLOC_INDEX}"
        ]
        # Name of the Docker Volume Driver used by the container
        volume_driver = "postgres-gogs"
        volumes = [
          # Use named volume created outside nomad.
          "postgres-gogs:/var/lib/postgresql/data"
        ]


        image = "gogs/gogs"
        port_map {
          ssh = 22
          http = 3000
        }
        network_mode = "gogs"
        network_aliases = [
          "gogs",
          "gogs-${NOMAD_ALLOC_INDEX}"
        ]
        # Name of the Docker Volume Driver used by the container
        volume_driver = "gogs-data"
        volumes = [
          # Use named volume created outside nomad.
          "gogs-data:/data"
        ]

      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "ssh" {}
          port "http" {}
        }
      }

      service {
        name = "global-gogs-check"
        tags = ["global", "git"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
