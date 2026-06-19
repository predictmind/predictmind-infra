locals {
  name = "predictmind-${var.environment}"

  # All deployable container services and the port they listen on.
  # The gateway is public (behind the ALB); domain services are internal.
  services = {
    gateway   = { port = 3001, public = true }
    auth      = { port = 3002, public = false }
    market    = { port = 3003, public = false }
    news      = { port = 3004, public = false }
    strategy  = { port = 3005, public = false }
    backtest  = { port = 3006, public = false }
    paper     = { port = 3007, public = false }
    reporting = { port = 3008, public = false }
    ai        = { port = 8000, public = false }
    web       = { port = 3000, public = true }
  }
}
