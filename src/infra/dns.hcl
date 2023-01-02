dependency "dns" {
    config_path = "../../global/dns"

    mock_outputs = {
        zone_id = {}
        zone_arn = {}
        name_servers = {}
        zone_name = {}
    }
    mock_outputs_allowed_terraform_commands = ["init", "validate"]
}