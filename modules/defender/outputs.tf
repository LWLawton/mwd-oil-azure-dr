output "defender_servers_tier"  { value = azurerm_security_center_subscription_pricing.servers.tier }
output "defender_storage_tier"  { value = azurerm_security_center_subscription_pricing.storage.tier }
output "defender_dns_tier"      { value = azurerm_security_center_subscription_pricing.dns.tier }
