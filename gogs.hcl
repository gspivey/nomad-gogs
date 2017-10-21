job "gogs" {
  datacenters = ["dc1"]

  type = "service"


  update {

    max_parallel = 1

    min_healthy_time = "10s"
    healthy_deadline = "3m"
    auto_revert = false
    canary = 0
  }

  group "db" {

    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    ephemeral_disk {

      size = 300
    }

    task "gogs" {
      driver = "docker"
      
      # Enviornemt Variable Managment (via vault?)
      env {
        POSTGRES_PASSWORD = "pg1234!"
        POSTGRES_USER = "gogs"
        POSTGRES_DB = "gogs" 
      }



      config {
        image = "postgres:9.6.5-alpine"
        port_map {
          db = 5432
        }
        network_mode = "gogs"
        network_aliases = [
          "postgres",
          "postgres-${NOMAD_ALLOC_INDEX}"
        ]
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
        tags = ["global", "cache"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }

    task "postgres" {
      driver = "docker"
      
      # Enviornemt Variable Managment (via vault?)
      env {
        POSTGRES_PASSWORD = "pg1234!"
        POSTGRES_USER = "gogs"
        POSTGRES_DB = "gogs" 
      }



      config {
        image = "postgres:9.6.5-alpine"
        port_map {
          db = 5432
        }
        network_mode = "gogs"
        network_aliases = [
          "postgres",
          "postgres-${NOMAD_ALLOC_INDEX}"
        ]
        volumes = [
          # Use named volume created outside nomad.
          "postgres-gogs:/var/lib/postgresql/data"
        ]

      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
        }
      }

    }






  }
}